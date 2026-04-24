# Triagem inteligente de tweets para o Processamento de Linguagem Natural (PLN)

Este repositório contém o código-fonte e os recursos desenvolvidos durante o projeto de Iniciação Científica focado na criação de um modelo computacional para a triagem qualitativa de publicações textuais de redes sociais (como textos curtos e tweets), com ênfase no domínio da política brasileira. 

O sistema atua como uma etapa de pré-processamento, utilizando a extração de pistas linguísticas para ranquear a utilidade das publicações para tarefas posteriores de PLN, como análise de sentimentos e sumarização.

## 🎯 Objetivo
Avaliar e pontuar as publicações baseando-se em aspectos extraídos da dimensão retórica da argumentação:

- **Credibilidade:** Identificação de autoridades públicas, dados quantitativos, termos técnicos, relatos pessoais e uso de hashtags.
- **Apelo emocional:** Detecção de emojis, caixa alta, repetição de pontuação e uso de primeira pessoa.
- **Clareza:** Penalização por erros de língua portuguesa e avaliação de métricas de legibilidade.

## 📂 Estrutura do repositório

A arquitetura do projeto foi desenhada para separar claramente códigos, dados e recursos linguísticos:

* `src/`: Scripts Python contendo a lógica de filtragem, extração de amostras e a implementação das heurísticas das pistas linguísticas.
* `data/`: Amostras de dados e arquivos `.csv` resultantes do ranqueamento. *(Nota: Por questões de privacidade e volume, as bases originais completas não são versionadas. Este projeto utilizou os dados do [Interfaces Twitter Elections Dataset (ITED-Br)](https://github.com/Interfaces-UFSCAR/ITED-Br)).*
* `resources/`: Léxicos, dicionários e ferramentas auxiliares adaptadas para o projeto (incluindo `PortiLexicon-UD`, bases do IBGE e listas de exceção ortográfica).
* `docs/`: Documentação complementar, infográficos e representações visuais dos critérios adotados.

## 🛠️ Tecnologias e dependências principais

O fluxo de processamento de texto utiliza uma combinação de ferramentas abertas e algoritmos desenvolvidos internamente:
* **Python 3.12 ou 3.13** *(Atenção: Evite versões mais recentes para garantir a compatibilidade das dependências instaladas).*
* **spaCy:** Reconhecimento de Entidades Nomeadas (NER) e marcação POS.
* **pyspellchecker:** Correção ortográfica adaptada para o "internetês".
* **PortiLexicon-UD:** Validação de termos técnicos a partir de exclusão de léxico geral.
  * **Nota:** O arquivo original `UDlexPT.py` fornecido pelo PortiLexicon sofreu pequenas adaptações neste repositório para garantir compatibilidade e estabilidade em ambientes Windows:
    1. Foi adicionado o parâmetro explícito `encoding='utf-8'` na função `open()` para evitar erros de leitura de caracteres especiais.
    2. Implementou-se a normalização `unicodedata.normalize('NFC', key)` nas chaves do dicionário para garantir o matching exato com as strings extraídas dos tweets.
    3. O método de separação de quebra de linhas foi substituído por `.rstrip('\n')` e `.split(",", 1)` para lidar com os padrões CRLF e evitar perdas de caracteres na leitura do `.tsv`.
* **NILC-Metrix:** Extração de métricas de complexidade textual (requer instanciamento via Docker para uso local). *Caso o contêiner não esteja rodando na porta 8080, o algoritmo ignora as métricas sem interromper a execução da triagem.*

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
* **Léxico geral e morfológico:** [PortiLexicon-UD](https://github.com/LuceleneL/PortiLexicon-UD)
* **Outros recursos:** O repositório também inclui compilações manuais de sobrenomes políticos e listas de exceções ortográficas.

## 📚 Publicações relacionadas

Os resultados e metodologias desenvolvidos neste projeto foram documentados e publicados nos seguintes veículos acadêmicos:

* **Congresso de Iniciação Científica e Tecnológica (CIC) UFSCar 2025:** Resumo publicado nos anais do congresso (pág. 519). [Acessar Anais](https://www.propq.ufscar.br/pt-br/assets/arquivos/iniciacao-cientifica/congressos/anais_cic_25-1.pdf)
* **UNIGOU Proceedings:** Artigo técnico detalhando a abordagem do projeto. [Acessar Publicação](https://www.incbac.org/unigou-proceedings/?article_id=809#extract-809)

## 🙏 Agradecimentos

Este trabalho foi realizado com o apoio do Programa Institucional de Bolsas de Iniciação Científica (PIBIC) e financiado pelo Conselho Nacional de Desenvolvimento Científico e Tecnológico (CNPq) durante o período de 2024 a 2025.

## 👩‍💻 Autoria e instituição

* **Pesquisadora:** Laura Pessine Teixeira
* **Orientadora:** Profa. Dra. Helena de Medeiros Caseli
* **Laboratório:** Laboratório de Linguística e Inteligência Computacional (LALIC) - Universidade Federal de São Carlos (UFSCar)