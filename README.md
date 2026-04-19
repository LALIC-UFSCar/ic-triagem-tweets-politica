# Triagem inteligente de tweets para o Processamento de Linguagem Natural (PLN)

Este repositório contém o código-fonte e os recursos desenvolvidos durante o projeto de Iniciação Científica focado na criação de um modelo computacional para a triagem qualitativa de tweets, com ênfase no domínio da política brasileira. 

O sistema atua como uma etapa de pré-processamento, utilizando a extração de pistas linguísticas para ranquear a utilidade de publicações para tarefas posteriores de PLN, como análise de sentimentos e sumarização.

## 🎯 Objetivo
Avaliar e pontuar textos curtos (tweets) baseando-se em aspectos extraídos da dimensão retórica da argumentação:
- **Credibilidade:** Identificação de autoridades públicas, dados quantitativos e termos técnicos.
- **Apelo emocional:** Detecção de emojis, caixa alta, hashtags, repetição de pontuação e uso de primeira pessoa.
- **Clareza:** Penalização por erros de língua portuguesa e avaliação de métricas de legibilidade.

## 📂 Estrutura do repositório

A arquitetura do projeto foi desenhada para separar claramente códigos de experimentação, dados e recursos linguísticos:

* `src/`: Scripts Python contendo a lógica de filtragem, extração de amostras e a implementação das heurísticas das pistas linguísticas.
* `data/`: Amostras de dados e arquivos `.csv` resultantes do ranqueamento. *(Nota: Por questões de privacidade e volume, as bases originais completas do Twitter/X não são versionadas).*
* `resources/`: Léxicos, dicionários e ferramentas auxiliares adaptadas para o projeto (incluindo `PortiLexicon-UD`, bases do IBGE, listas de exceção ortográfica e léxicos de toxicidade para trabalhos futuros).
* `docs/`: Documentação complementar, infográficos e representações visuais dos critérios adotados.

## 🛠️ Tecnologias e dependências principais

O fluxo de processamento de texto utiliza uma combinação de ferramentas abertas e algoritmos desenvolvidos internamente:
* **Python 3.12 ou 3.13** *(Atenção: Evite versões mais recentes (3.14+) para garantir a compatibilidade com os pacotes pré-compilados do `gensim` e do `spaCy` e evitar erros de compilação C++).*
* **spaCy:** Reconhecimento de Entidades Nomeadas (NER) e marcação POS.
* **pyspellchecker:** Correção ortográfica adaptada para o "internetês".
* **PortiLexicon-UD:** Validação de termos técnicos a partir de exclusão de léxico geral.
  * **Nota:** O arquivo original `UDlexPT.py` fornecido pelo PortiLexicon sofreu pequenas adaptações neste repositório para garantir compatibilidade e estabilidade em ambientes Windows:
    1. Foi adicionado o parâmetro explícito `encoding='utf-8'` na função `open()` para evitar erros de leitura de caracteres especiais.
    2. Implementou-se a normalização `unicodedata.normalize('NFC', key)` nas chaves do dicionário para garantir o matching exato com as strings extraídas dos tweets.
    3. O método de separação de quebra de linhas foi substituído por `.rstrip('\n')` e `.split(",", 1)` para lidar com os padrões CRLF e evitar perdas de caracteres na leitura do `.tsv`.
* **NILC-Metrix:** Extração de métricas de complexidade textual (requer instanciamento via Docker para uso local). *Caso o contêiner não esteja rodando na porta 8080, o algoritmo ignora as métricas graciosamente sem interromper a execução.*

## 🚀 Como executar

1. Clone este repositório:
   ```bash
   git clone https://github.com/LALIC-UFSCar/ic-triagem-tweets-politica.git
   cd ic-triagem-tweets-politica
   ```
2. Crie e ative um ambiente virtual:
   ```bash
   python -m venv .venv
   
   # No Linux/macOS:
   source .venv/bin/activate  
   
   # No Windows: 
   .venv\Scripts\activate
   ```
3. Instale as dependências:
   ```bash
   pip install -r requirements.txt
   ```
4. Baixe o modelo do spaCy para português:
   ```bash
   python -m spacy download pt_core_news_lg
   ```
5. Execute o script principal de filtragem:
   ```bash
   python src/filtragem.py
   ```
   *Os resultados da triagem serão salvos em `data/resultados_tweets.csv`.*

## 🤝 Créditos e fontes de dados

Grande parte dos recursos léxicos e bases de dados utilizados na pasta `resources/` provém de contribuições valiosas da comunidade open-source. Deixo aqui os devidos agradecimentos e créditos aos autores originais:

* **Municípios e estados brasileiros (`estados.csv`, `municipios.csv`):** [kelvins/municipios-brasileiros](https://github.com/kelvins/municipios-brasileiros)
* **Nomes próprios do Censo IBGE (`ibge-fem-10000.csv`, `ibge-mas-10000.csv`):** [MedidaSP/nomes-brasileiros-ibge](https://github.com/MedidaSP/nomes-brasileiros-ibge)
* **Lista de países (`paises-array.json`):** [juliolvfilho/lista-paises](https://github.com/juliolvfilho/lista-paises)
* **Léxico de palavrões/termos ofensivos (`pt.txt`):** [LDNOOBW](https://github.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words)
* **Léxico geral e morfológico:** [PortiLexicon-UD](https://github.com/LuceleneL/PortiLexicon-UD)
* **Outros recursos:** O repositório também inclui compilações manuais de sobrenomes políticos, dicionários de verbos psicológicos baseados no LIWC e listas de exceções ortográficas.

## 👩‍💻 Autoria e instituição

* **Pesquisadora:** Laura Pessine Teixeira
* **Orientadora:** Profa. Dra. Helena de Medeiros Caseli
* **Laboratório:** Laboratório de Linguística e Inteligência Computacional (LALIC) - Universidade Federal de São Carlos (UFSCar)