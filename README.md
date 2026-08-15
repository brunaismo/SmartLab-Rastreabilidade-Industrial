# SmartLab-Rastreabilidade-Industrial

Sistema desenvolvido foi feito como parte de uma tarefa para a cadeira de Análise e Processamento de Sinais para **automatizar a criação e organização de pontos de inspeção de SPDA (Sistema de Proteção contra Descargas Atmosféricas)**, utilizando arquivos estáticos, Bash e armazenamento em nuvem.
A solução permite gerar automaticamente a estrutura de diretórios, arquivos de inspeção e **QR Codes** vinculados a cada ponto físico, facilitando o acesso e o registro das informações durante as atividades de campo.

## Arquitetura

O sistema utiliza uma arquitetura **serverless e baseada em arquivos estáticos**, sem a necessidade de um banco de dados ou de uma aplicação web complexa.

A solução é composta por scripts **Bash**, responsáveis pela automação da geração da estrutura de dados, enquanto o **Google Drive** atua como camada de armazenamento e colaboração.

Essa abordagem permite que os dados sejam acessados tanto em **computadores quanto em dispositivos móveis**.

## 🧩 Camadas do Sistema

O sistema é dividido em três camadas principais:

### 1. Camada de Configuração

O arquivo `config_pontos.csv` contém os parâmetros utilizados para a geração dos pontos, incluindo:

* Cliente
* Unidade
* Área
* Tipo de estrutura
* Siglas
* Descrições

O usuário define nesse arquivo a quantidade de pontos desejada para cada combinação de **área e tipo de equipamento**.

---

### 2. Camada de Processamento

O script `gerar_pontos.sh` funciona como o **gerador de instâncias do sistema** interpretando os dados do arquivo .CSV  e criando a árvore
de diretórios dinamicamente.

---

### 3. Camada de Persistência

O diretório raiz `SPDA_Pontos/` armazena toda a estrutura gerada pelo sistema.

Cada ponto de inspeção possui uma pasta exclusiva, seguindo um padrão de nomenclatura baseado nas informações cadastradas.

Exemplo:

```text
[SiglaCliente]-[SiglaArea]-[SiglaTipo]-[SiglaUnidade]
```

---

# Geração Automática dos Pontos

O processo começa com o preenchimento do arquivo:

```text
config_pontos.csv
```

Após a execução do script principal, três etapas são realizadas.

### 1. Validação dos Dados

O sistema verifica a integridade das informações de entrada, garantindo que os campos obrigatórios estejam preenchidos corretamente e que os valores de quantidade sejam **numéricos e válidos**.

### 2. Criação da Estrutura de Diretórios

Para cada registro do CSV, o sistema calcula a quantidade de pontos e cria automaticamente suas respectivas pastas.

### 3. Geração dos Ativos de Campo

Dentro de cada pasta são criados automaticamente:

| Arquivo/Pasta   | Função                                            |
| --------------- | ------------------------------------------------- |
| `ponto.txt`     | Ficha técnica contendo os metadados do ponto      |
| `inspecoes.csv` | Histórico das inspeções realizadas                |
| `fotos/`        | Armazenamento de imagens e registros fotográficos |

O arquivo `inspecoes.csv` já é criado com os cabeçalhos necessários para o registro das inspeções, como:

* Responsável
* Condição visual
* Medições
* Observações
* Outros dados técnicos

---

# Geração de QR Codes

Para facilitar a identificação dos pontos físicos, o sistema utiliza a ferramenta de linha de comando **`qrencode`**.

Durante a execução, o script identifica as pastas recém-criadas e gera automaticamente um arquivo:

```text
QR.png
```

Cada QR Code contém uma **URL pública direcionada diretamente para a pasta correspondente ao ponto no Google Drive**. Dessa forma, o código pode ser afixado fisicamente no ponto de inspeção.

---

# Fluxo de Trabalho em Campo

O processo de utilização pelo técnico é simplificado para facilitar as atividades de inspeção.

### 1. Identificação

O técnico escaneia o **QR Code** instalado no ponto físico de SPDA utilizando seu smartphone.

### 2. Acesso

O dispositivo abre automaticamente a pasta correspondente no **Google Drive**.

### 3. Registro da Inspeção

O técnico acessa o arquivo:

```text
inspecoes.csv
```

e registra as informações da nova inspeção.

### 4. Atualização

Após preencher os dados, o arquivo atualizado é enviado novamente para a mesma pasta. Dessa forma, o histórico de inspeções permanece centralizado e acessível à equipe responsável pela manutenção.

---

# Questionamentos:

### O sistema pode utilizar Microsoft em vez do Google?

**Sim.**

Uma das principais características da solução é sua **simplicidade e facilidade de adaptação**. Como o sistema utiliza arquivos e diretórios como base para armazenamento, a principal alteração necessária seria a forma como os links são construídos pelo script.

Atualmente, o sistema utiliza URLs do Google Drive, como:

```text
https://drive.google.com/...
```

Em uma implementação utilizando OneDrive, os links poderiam ser direcionados para:

```text
https://onedrive.live.com/...
```
---

### Duas empresas diferentes podem utilizar o sistema?

**Sim.**

O sistema não depende de um banco de dados centralizado. Dessa forma, cada empresa pode possuir sua própria estrutura de armazenamento. Cada empresa mantém seus dados isolados em sua própria estrutura de armazenamento, reduzindo o risco de mistura de informações.

A mesma abordagem pode ser utilizada com **OneDrive ou outro serviço de armazenamento compatível**.
