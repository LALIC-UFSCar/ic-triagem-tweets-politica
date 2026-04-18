import argparse
import urllib.request
import json
import logging
import os
import re
import string
import sys
from functools import lru_cache
from itertools import groupby

import emoji
import nltk
import pandas as pd
import spacy
import unicodedata
from nltk.corpus import stopwords
from spellchecker import SpellChecker

# Configuração de logging para monitorar execução
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Constantes de caminhos dos recursos
CAMINHO_BASE_PADRAO = r'D:\IC-Tweets'

CAMINHOS_RECURSOS = {'nomes_fem': ('resources/ibge-fem-10000.csv', 'csv'),
                     'nomes_mas': ('resources/ibge-mas-10000.csv', 'csv'),
                     'paises': ('resources/paises-array.json', 'json'),
                     'estados': ('resources/estados.csv', 'csv'),
                     'municipios': ('resources/municipios.csv', 'csv')}

# Remove pontuações extras
PONTUACOES_EXTRA = str.maketrans('', '', string.punctuation.replace('-', '') + '‘“”ºª°…—–«»¯´')
IGNORAR_INICIAL = {'A', 'O', 'É', 'E'}
SOBRENOMES_POLITICOS = {'alckmin', 'beltrão', 'bernardes', 'bettencourt', 'bolsonaro', 'buarque', 'casagrande',
                         'gianetti', 'gusmão', 'marshall', 'meireles', 'perez', 'pádua'}
# --------------------------------------------------
# Padrões de Regex
# --------------------------------------------------
PADRAO_HIFEN = re.compile(r'^(vice|pós|pré|pró)(?=[a-záàâãéèêíïóôõöúçñ])', flags=re.IGNORECASE)
PADRAO_RISADA = re.compile(r'([hH][ae]*|[kK]+|rs)+', flags=re.IGNORECASE)

# URL da API do NILC-Metrix
NILC_METRIX_API_URL = 'http://localhost:8080/api/v1/metrix/_min/yyy?format=json'  # Substitua yyy pelo seu token, se necessário.


# Funções utilitárias
def carregar_recurso(caminho, formato):
    if formato == 'csv':
        return pd.read_csv(caminho, usecols=['nome'])
    return pd.read_json(caminho)


def remover_acentos(texto):
    return ''.join(c for c in unicodedata.normalize('NFD', texto) if unicodedata.category(c) != 'Mn')


def eh_risada(palavra):
    return bool(PADRAO_RISADA.fullmatch(palavra))


def corrigir_hifen(palavra):
    return PADRAO_HIFEN.sub(r'\1-', palavra)


# Carregamento de recursos
def preparar_conjuntos(caminho_base):
    conjuntos = {}
    for nome, (caminho_relativo, formato) in CAMINHOS_RECURSOS.items():
        caminho_completo = os.path.join(caminho_base, caminho_relativo)
        df = carregar_recurso(caminho_completo, formato)
        conjuntos[nome] = set(df['nome'].str.lower())
    # Atualizações manuais em países
    # ⇾ Biomas, continentes, penínsulas, bairros, cidades, estados, países
    paises_extra = ['amazónia', 'américa', 'arábia', 'bombain', 'copacabana', 'croácia', 'eua', 'estocolmo', 'europa',
                    'haia', 'inglaterra', 'nebraska', 'princeton', 'rússia']
    conjuntos['paises'].update(paises_extra)
    return conjuntos


# --------------------------------------------------
# Inicialização de ferramentas
# --------------------------------------------------
def inicializar_ambiente():
    logger.info('Inicializando spaCy e outras ferramentas...')
    nlp = spacy.load('pt_core_news_lg')
    corretor = SpellChecker(language='pt')
    nltk.download('stopwords', quiet=True)
    stopwords_pt = set(stopwords.words('portuguese'))
    sys.path.append(f'{CAMINHO_BASE_PADRAO}/resources/PortiLexicon-UD')
    from UDlexPT import UDlexPT
    ud_lex = UDlexPT()
    sys.path.append(f'{CAMINHO_BASE_PADRAO}/resources')
    return nlp, corretor, stopwords_pt, ud_lex


# --------------------------------------------------
# Funções de extração de pistas linguísticas
# --------------------------------------------------
def extrair_autoridades(doc):
    ents = [ent.text.strip() for ent in doc.ents]
    return ents if ents else None


def extrair_emojis(texto):
    emojis = [c for c in texto if emoji.is_emoji(c)]
    return emojis if emojis else None


def extrair_caixa_alta(doc):
    tokens = []
    for token in doc:
        if not token.text.isupper():
            continue
        if token.is_sent_start and token.text in IGNORAR_INICIAL:
            continue
        tokens.append(token.text)
    return tokens or None


def extrair_hashtags(texto):
    tags = list(set(re.findall(r'#\S+', texto)))
    return tags if tags else None


def extrair_repeticoes_pontuacao(texto):
    seq = texto.replace(' ', '')
    reps = {}
    for ch, grp in groupby(seq):
        if ch not in '?!':
            continue
        run = list(grp)
        if len(run) > 1:
            reps[ch] = len(run)
    return reps if reps else None


# --------------------------------------------------
# Identificação de termos técnicos
# --------------------------------------------------
@lru_cache(maxsize=10000)
def corrigir_palavra(word, corretor):
    cor = corretor.correction(word)
    return cor if cor is not None else word


def identificar_termos_tecnicos_e_erros(texto, nlp, corretor, ud_lex, stopwords_pt, conjuntos, sobrenomes):
    doc = nlp(texto)
    termos_tecnicos, erros_lingua_portuguesa = set(), set()
    cache = {}
    for token in doc:
        palavra = corrigir_hifen(token.text.translate(PONTUACOES_EXTRA)).strip().lower()
        palavra_sem_acento = remover_acentos(palavra)
        # Filtros
        if (
            token.text.startswith('@') or
            len(palavra) < 2 or
            not palavra.isalnum() or
            palavra.isnumeric() or
            token.pos_ in {'ADP', 'SCONJ', 'PRON', 'DET'} or
            palavra in stopwords_pt or
            palavra in nlp.Defaults.stop_words or
            eh_risada(palavra) or
            token.like_url or
            ud_lex.exists(unicodedata.normalize('NFC', palavra)) or
            palavra in sobrenomes or
            palavra in conjuntos['paises'] or
            palavra in conjuntos['estados'] or
            palavra in conjuntos['municipios'] or
            palavra_sem_acento in conjuntos['nomes_fem'] or
            palavra_sem_acento in conjuntos['nomes_mas']
        ):
            continue
        # Correção ortográfica
        palavra_corrigida = cache.setdefault(palavra, corrigir_palavra(palavra, corretor)).lower()
        if palavra_corrigida != palavra:
            erros_lingua_portuguesa.add(palavra)
            if ud_lex.exists(palavra_corrigida):
                continue
        termos_tecnicos.add(palavra_corrigida)
    lista_termos = sorted(termos_tecnicos) if termos_tecnicos else None
    lista_erros = sorted(erros_lingua_portuguesa) if erros_lingua_portuguesa else None
    return lista_termos, lista_erros


# Identificação de relatos pessoais
def identificar_relatos_pessoais(doc):
    verbos = [token.text for token in doc if token.pos_ == 'VERB' and token.morph.get('Person') == ['1']]
    pronomes = [token.text for token in doc if token.pos_ == 'PRON' and token.morph.get('Person') == ['1']]
    return verbos, pronomes


def get_nilc_metrix_data(text: str) -> dict:
    try:
        encoded_text = bytearray(text, encoding='utf-8')
        req = urllib.request.Request(NILC_METRIX_API_URL, data=encoded_text, headers={'content-type': 'text/plain'})
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode('utf8'))
    except Exception as e:
        logger.error(f"Erro ao obter métricas do NILC-Metrix para o texto '{text[:50]}...': {e}")
        return {}


def pontuar_credibilidade(d):
    score = 0
    if d.get('autoridades'): score += len(d['autoridades'].split(', '))
    if d.get('dados'): score += len(d['dados'].split(', '))
    if d.get('hashtags'): score += len(d['hashtags'].split(', '))
    if d.get('termos_tecnicos'): score += len(d['termos_tecnicos'].split(', '))
    vp = d.get('verbos_primeira_pessoa', '').split(', ') if d.get('verbos_primeira_pessoa') else []
    pp = d.get('pronomes_primeira_pessoa', '').split(', ') if d.get('pronomes_primeira_pessoa') else []
    score += len(vp) + len(pp)
    return score


def pontuar_apelo_emocional(d):
    score = 0
    if d.get('emojis'): score += len(d['emojis'].split(', '))
    if d.get('caixa_alta'): score += len(d['caixa_alta'].split(', '))
    if d.get('repeticoes_pontuacao'): score += len(d['repeticoes_pontuacao'].split(', '))
    vp = d.get('verbos_primeira_pessoa', '').split(', ') if d.get('verbos_primeira_pessoa') else []
    pp = d.get('pronomes_primeira_pessoa', '').split(', ') if d.get('pronomes_primeira_pessoa') else []
    score += len(vp) + len(pp)
    return score


def pontuar_clareza(d: dict, nilc_metrix_data: dict) -> int:
    """
    Pontua a clareza do texto, considerando erros de português e métricas do NILC-Metrix.
    Valores mais altos indicam maior clareza, valores mais baixos indicam menor clareza.
    A pontuação final é um número inteiro.
    """
    score_clareza = 0

    # Pista: Erros de língua portuguesa (contribuição negativa para a clareza)
    if d.get('erros_lingua_portuguesa'):
        score_clareza -= len(d['erros_lingua_portuguesa'].split(', ')) * 1 # Reduz por cada erro

    # Média de palavras por sentença (words_per_sentence)
    words_per_sentence = nilc_metrix_data.get('words_per_sentence', 0)
    if words_per_sentence > 17: # Limiar ajustado com base na média do Adapt2Kids (17.17)
        score_clareza -= 1
    elif words_per_sentence > 12: # Transição de médio para longo
        score_clareza -= 0
    else: # Sentenças mais curtas são geralmente mais claras
        score_clareza += 1

    # Índice de Flesch Reading Ease (flesch)
    flesch_score = nilc_metrix_data.get('flesch', 0)
    if flesch_score < 51.72: # Muito difícil
        score_clareza -= 2
    elif flesch_score < 76.35: # Moderadamente difícil
        score_clareza -= 1
    else: # Mais fácil de ler
        score_clareza += 1

    # Média de sílabas por palavra de conteúdo (syllables_per_content_word)
    syllables_per_word = nilc_metrix_data.get('syllables_per_content_word', 0)
    if syllables_per_word > 2.0: # Palavras mais longas
        score_clareza -= 1
    elif syllables_per_word > 1.8:
        score_clareza -= 0
    else: # Palavras mais curtas
        score_clareza += 1

    # Frequência mínima de palavras de conteúdo do BrWaC ('min_cw_freq_brwac')
    # Valores menores (palavras mais raras) indicam menos clareza
    min_cw_freq_brwac = nilc_metrix_data.get('min_cw_freq_brwac', 10.0)
    if min_cw_freq_brwac < 4.5: # Palavras muito raras
        score_clareza -= 2
    elif min_cw_freq_brwac < 5.0: # Palavras raras
        score_clareza -= 1
    else: # Palavras mais comuns
        score_clareza += 1

    # Yngve (yngve) - Índice de complexidade sintática. Valores mais altos = mais complexo
    yngve_index = nilc_metrix_data.get('yngve', 0)
    if yngve_index > 2.0: # Estrutura sintática muito complexa
        score_clareza -= 1
    elif yngve_index > 1.5:
        score_clareza -= 0
    else: # Estrutura sintática mais simples
        score_clareza += 1

    # Frazier (frazier) - Índice de complexidade sintática. Valores mais altos = mais complexo
    frazier_index = nilc_metrix_data.get('frazier', 0)
    if frazier_index > 6.0: # Estrutura sintática muito complexa
        score_clareza -= 1
    elif frazier_index > 5.0:
        score_clareza -= 0
    else: # Estrutura sintática mais simples
        score_clareza += 1

    # Cross Entropy (cross_entropy) - Valores mais altos = menor coesão semântica
    cross_entropy = nilc_metrix_data.get('cross_entropy', 0)
    if cross_entropy > 0.8: # Baixa coesão
        score_clareza -= 1
    elif cross_entropy > 0.6:
        score_clareza -= 0
    else: # Alta coesão
        score_clareza += 1

    # Densidade de Palavras de Conteúdo (content_words) - Proporção de palavras de conteúdo.
    content_words_ratio = nilc_metrix_data.get('content_words', 0)
    if content_words_ratio < 0.5 or content_words_ratio > 0.8: # Extremos podem indicar falta de clareza
        score_clareza -= 1

    # Ambiguidade de Adjetivos (adjectives_ambiguity)
    adjectives_ambiguity = nilc_metrix_data.get('adjectives_ambiguity', 0)
    if adjectives_ambiguity > 5.0:
        score_clareza -= 1

    # Ambiguidade de Verbos (verbs_ambiguity)
    verbs_ambiguity = nilc_metrix_data.get('verbs_ambiguity', 0)
    if verbs_ambiguity > 10.0:
        score_clareza -= 1

    # Densidade de Palavras Funcionais (function_words)
    function_words_ratio = nilc_metrix_data.get('function_words', 0)
    if function_words_ratio > 0.4:
        score_clareza -= 1

    return int(score_clareza) # Garante que o retorno seja um inteiro


def processar_tweet(texto, deps):
    nlp = deps['nlp']
    doc = nlp(texto)
    autoridades = extrair_autoridades(doc)
    caixa_alta = extrair_caixa_alta(doc)
    emojis = extrair_emojis(texto)
    hashtags = extrair_hashtags(texto)
    repeticoes = extrair_repeticoes_pontuacao(texto)
    termos_tecnicos, erros = identificar_termos_tecnicos_e_erros(texto, nlp, deps['corretor'], deps['ud_lex'],
                                                                  deps['stopwords'], deps['conjuntos'],
                                                                  deps['sobrenomes'])
    verbos, pronomes = identificar_relatos_pessoais(doc)

    # Obter métricas do NILC-Metrix
    nilc_metrix_data = get_nilc_metrix_data(texto)

    data = {
        'tweet': texto,
        'autoridades': ', '.join(autoridades) if autoridades else None,
        'emojis': ', '.join(emojis) if emojis else None,
        'caixa_alta': ', '.join(caixa_alta) if caixa_alta else None,
        'hashtags': ', '.join(hashtags) if hashtags else None,
        'termos_tecnicos': ', '.join(termos_tecnicos) if termos_tecnicos else None,
        'erros_lingua_portuguesa': ', '.join(erros) if erros else None,
        'repeticoes_pontuacao': ', '.join(f'"{c}": {n}' for c, n in repeticoes.items()) if repeticoes else None,
        'verbos_primeira_pessoa': ', '.join(verbos) if verbos else None,
        'pronomes_primeira_pessoa': ', '.join(pronomes) if pronomes else None,
        # Armazenar as métricas do NILC-Metrix diretamente no dicionário de dados, se desejar
        # para análise posterior ou para debug.
        'nilc_metrix_raw_data': json.dumps(nilc_metrix_data) # Armazena como string JSON
    }

    data['credibilidade'] = str(pontuar_credibilidade(data))
    data['apelo_emocional'] = str(pontuar_apelo_emocional(data))
    # Passa as métricas do NILC-Metrix para a função de pontuação de clareza
    data['clareza'] = str(pontuar_clareza(data, nilc_metrix_data))
    # data['clareza'] = str(pontuar_clareza(data, {}))
    return data

# Função principal
def main():
    parser = argparse.ArgumentParser(description='Processa tweets e extrai features')
    parser.add_argument('--base', default=CAMINHO_BASE_PADRAO, help='Caminho base dos recursos')
    parser.add_argument('--input', default=r'data/amostra_10.csv', help='Arquivo com tweets')
    parser.add_argument('--sample', type=int, default=None, help='Quantidade de tweets a processar (None = todos)')
    args = parser.parse_args()
    input_caminho = os.path.join(args.base, args.input)
    logger.info(f'Lendo {input_caminho}')
    # Detecta extensão e lê apropriadamente
    ext = os.path.splitext(input_caminho)[1].lower()
    if ext == '.parquet':
        tweets = pd.read_parquet(str(input_caminho))['text']
    elif ext in ('.xls', '.xlsx'):
        tweets = pd.read_excel(input_caminho)['text']
    elif ext == '.csv':
        tweets = pd.read_csv(str(input_caminho))['text']
    else:
        raise ValueError(f'Formato de arquivo não suportado: {ext}')
    if args.sample:
        tweets = tweets.sample(args.sample, random_state=42)
    nlp, corretor, stopwords_pt, ud_lex = inicializar_ambiente()
    deps = {'nlp': nlp, 'corretor': corretor, 'stopwords': stopwords_pt, 'ud_lex': ud_lex,
            'conjuntos': preparar_conjuntos(args.base), 'sobrenomes': None}
    with open(os.path.join(args.base, 'resources/sobrenomes.txt'), encoding='utf-8') as arquivo:
        deps['sobrenomes'] = {linha.strip().lower().replace('"', '').replace(',', '') for linha in arquivo}
    deps['sobrenomes'].update(SOBRENOMES_POLITICOS)
    logger.info(f'Processando {len(tweets)} tweets...')
    df_resultados = pd.DataFrame([processar_tweet(tweet, deps) for tweet in tweets])
    arquivo_resultados = os.path.join(args.base, 'data/resultados_tweets.csv')
    df_resultados.to_csv(arquivo_resultados, index=False, encoding='utf-8')
    logger.info(f'Saída salva em {arquivo_resultados}')


if __name__ == '__main__':
    main()