# Triagem Inteligente de Tweets para Processamento de Linguagem Natural (PLN)

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
* `notebooks/`: Jupyter Notebooks utilizados para experimentação, validação e prototipação das análises.
* `data/`: Amostras de dados e arquivos `.csv` resultantes do ranqueamento. *(Nota: Por questões de privacidade e volume, as bases originais completas do Twitter/X não são versionadas).*
* `resources/`: Léxicos, dicionários e ferramentas auxiliares adaptadas para o projeto (incluindo `PortiLexicon-UD` e dicionários de correção para o `enelvo`).
* `docs/`: Documentação complementar, infográficos e representações visuais dos critérios adotados.

## 🛠️ Tecnologias e dependências principais

O fluxo de processamento de texto utiliza uma combinação de ferramentas abertas e algoritmos desenvolvidos internamente:
* **Python 3.x**
* **spaCy:** Reconhecimento de Entidades Nomeadas (NER) e marcação POS.
* **Enelvo & pyspellchecker:** Normalização lexical e correção ortográfica adaptada para o "internetês".
* **PortiLexicon-UD:** Validação de termos técnicos a partir de exclusão de léxico geral.
* **NILC-Metrix:** Extração de métricas de complexidade textual (requer instanciamento via Docker para uso local).

## 🚀 Como Executar

1. Clone este repositório:
   ```bash
   git clone [https://github.com/LALIC-UFSCar/nome-do-seu-repositorio.git](https://github.com/LALIC-UFSCar/nome-do-seu-repositorio.git)
   ```
2. Crie e ative um ambiente virtual:
   ```bash
   python -m venv venv
   source venv/bin/activate  # No Windows: venv\Scripts\activate
   ```
3. Instale as dependências:
   ```bash
   pip install -r requirements.txt
   ```
4. Baixe o modelo do spaCy para português:
   ```bash
   python -m spacy download pt_core_news_lg
   ```

## 👩‍💻 Autoria e Instituição

* **Pesquisadora:** Laura Pessine Teixeira
* **Orientadora:** Profa. Dra. Helena de Medeiros Caseli
* **Laboratório:** Laboratório de Linguística e Inteligência Computacional (LALIC) - Universidade Federal de São Carlos (UFSCar)