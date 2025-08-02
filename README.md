# Poupe.AI - Repositório de Infraestrutura

Este repositório contém toda a configuração de infraestrutura para o ecossistema de serviços do **Poupe.AI**. A orquestração dos contêineres é gerenciada via **Docker Compose**, fornecendo um ambiente de desenvolvimento local consistente e uma base para implantações automatizadas em produção.

A stack de tecnologia inclui:

  * **Gateway de API:** Kong
  * **Autenticação e Autorização:** Keycloak
  * **Bancos de Dados:** PostgreSQL
  * **Cache:** Redis
  * **Mensageria:** RabbitMQ
  * **Observabilidade:** Grafana, Loki e Promtail

## Estrutura de Diretórios

A organização do projeto segue uma abordagem modular para separar as responsabilidades de cada componente da infraestrutura.

```
.
├── .github/workflows/            # Contém o pipeline de CI/CD para deploy da infra no servidor de produção
├── .env.example                  # Arquivo de exemplo com todas as variáveis de ambiente necessárias
├── .gitignore                    # Arquivos e pastas ignorados pelo Git
├── docker-compose-local.yml      # Orquestração de contêineres para o ambiente de DESENVOLVIMENTO
├── docker-compose-production.yml # Orquestração de contêineres para o ambiente de PRODUÇÃO
├── README.md                     # Esta documentação
├── keycloak/                     # Configurações do Keycloak. Inclui o realm "poupe-ai" e temas customizados
├── kong/                         # Configuração declarativa do Kong e plugins customizados
├── logging/                      # Configurações da stack de observabilidade (Loki, Promtail, Grafana)
└── services/                     # (IGNORADO PELO GIT) Diretório local para clonar os repositórios dos microsserviços
```

## Guia de Setup para Desenvolvimento Local

Siga estes passos para configurar e executar todo o ambiente em sua máquina.

### Pré-requisitos

  * [Git](https://git-scm.com/)
  * [Docker](https://www.docker.com/products/docker-desktop/) e Docker Compose

### 1\. Clone o Repositório de Infraestrutura

Primeiro, clone este repositório para sua máquina local.

```bash
git clone <url-do-repositorio-poupeai-infra>
cd poupeai-infra
```

### 2\. Clone os Microsserviços

O ambiente local constrói as imagens a partir do código-fonte. Clone cada repositório de microsserviço **dentro** da pasta `services/`. O conteúdo desta pasta é intencionalmente ignorada pelo `.gitignore` para manter o código da aplicação separado da infra.

```bash
# Clone os repositórios dos serviços necessários para o seu desenvolvimento
git clone <url-do-repo-finance-service> services/poupeai-finance-service
git clone <url-do-repo-notification-service> services/poupeai-notification-service
git clone <url-do-repo-report-service> services/poupeai-report-service
```

### 3\. Configure as Variáveis de Ambiente

Crie seu arquivo de ambiente pessoal (`.env`) a partir do exemplo fornecido.

```bash
cp .env.example .env
```

Abra o arquivo `.env` e preencha as variáveis com os valores apropriados para o seu ambiente. Preste atenção especial às chaves de API (`GEMINI_API_KEY`, etc.) e segredos.

**Atenção:** O arquivo `.env` contém informações sensíveis. Ele já está no `.gitignore` e **NUNCA** deve ser comitado no repositório.

### 4\. Suba os Contêineres

Com tudo configurado, use o arquivo `docker-compose-local.yml` para construir e iniciar todos os serviços.

```bash
# Use --build para garantir que as imagens dos serviços sejam reconstruídas a partir do código local
docker compose -f docker-compose-local.yml up --build -d
```

  * A flag `--build` força a reconstrução das imagens. Use-a na primeira vez ou sempre que alterar um `Dockerfile` ou código que precise ser copiado para a imagem.
  * A flag `-d` (detached) executa os contêineres em segundo plano.
  * Para **parar** os serviços, execute: `docker compose -f docker-compose-local.yml down`.
  * Para ver os **logs** de todos os serviços, use: `docker compose -f docker-compose-local.yml logs -f`.

## Acessando os Serviços Localmente

Após iniciar os contêineres, os seguintes serviços estarão disponíveis em seu `localhost`:

| Serviço | URL de Acesso Local | Credenciais Padrão (`.env`) |
| :--- | :--- | :--- |
| Gateway (API) | `http://localhost:8000` | N/A (usa tokens JWT) |
| Kong Admin GUI | `http://localhost:8002` | N/A |
| Keycloak | `http://localhost:8080` | `admin` / `admin` |
| Grafana (Logs) | `http://localhost:3000` | `admin` / `admin` |
| RabbitMQ Mgmt | `http://localhost:15672` | `guest` / `guest` |
| Flower (Celery) | `http://localhost:5555` | `admin` / `admin` |
| API de Finanças | `http://localhost:8005` | N/A (acessado via Gateway) |

## Acesso ao Banco de Dados com DBeaver

Para facilitar o desenvolvimento, o banco de dados `finances-db` já vem com sua porta `5432` exposta para a máquina host no arquivo `docker-compose-local.yml`. O acesso é restrito a `127.0.0.1` (localhost), garantindo que ele não fique acessível pela rede.

Para conectar-se usando uma ferramenta de GUI como o DBeaver:

1.  **Configure a Conexão no DBeaver:**
      * Abra o DBeaver e clique em **"Nova Conexão"** (`+`).
      * Selecione **PostgreSQL**.
      * Na aba "Principal", preencha os seguintes campos com os valores do seu arquivo `.env`:
          * **Host:** `localhost` (ou `127.0.0.1`)
          * **Porta:** `5432`
          * **Base de Dados:** O valor de `FINANCE_DB` (ex: `poupeai_finance_db`)
          * **Usuário:** O valor de `FINANCE_DB_USER` (ex: `finance_user`)
          * **Senha:** O valor de `FINANCE_DB_PASSWORD` (ex: `finance_user_password`)
      * Clique em **"Testar Conexão"** para verificar se tudo está correto e depois em **"Finalizar"**.

## Ambientes: Local vs. Produção

Existem diferenças cruciais entre os arquivos `docker-compose-local.yml` e `docker-compose-production.yml`.

| Característica | `docker-compose-local.yml` (Desenvolvimento) | `docker-compose-production.yml` (Produção) |
| :--- | :--- | :--- |
| **Fonte da Imagem** | `build: .` (Constrói a partir do código-fonte local) | `image:` (Puxa de um registro, ex: Docker Hub) |
| **Volumes de Código** | Mapeados (`./services/..:/app`) para live reload | Não mapeados (código contido na imagem) |
| **Política de Restart** | Nenhuma (padrão `no`) | `unless-stopped` para alta disponibilidade |
| **Kong Admin** | Habilitado em `localhost:8001/8002` | Desabilitado (`KONG_ADMIN_LISTEN: 'off'`) |
| **Backup de Dados**| Não configurado | Serviços `*-db-backup` para backups diários |
| **Logs** | Saída para o console, coletado pelo Promtail | Saída para o console, coletado pelo Promtail |

-----

## CI/CD - Deploy da Infraestrutura

O pipeline de Continuous Deployment está configurado em `.github/workflows/ci.yml` e é acionado a cada `push` na branch `main`.

**Importante:** Este pipeline é responsável por implantar as **configurações de infraestrutura** (os arquivos `docker-compose`, etc.), e não por construir as imagens dos microsserviços.

### Como Funciona o Deploy

1.  **Trigger:** Um `push` na branch `main` deste repositório inicia o workflow.
2.  **Conexão SSH:** O GitHub Actions se conecta ao servidor de produção via SSH.
3.  **Atualização do Repositório:** O script no servidor verifica o estado do diretório `poupeai-infra`:
      * Se não existe, ele clona o repositório.
      * Se existe e está íntegro, ele executa `git pull` para obter a versão mais recente.
      * Se está corrompido, ele faz um backup seguro do arquivo `.env`, recria o repositório e restaura o `.env`.
4.  **Aplicação da Configuração:** Após garantir que o código está atualizado, o comando `sudo docker compose -f docker-compose-production.yml up -d` é executado.

### O que o comando `docker compose up` faz em Produção?

  * **Puxa as Imagens:** Ele verifica no registro de contêineres (ex: Docker Hub) se há versões mais recentes das imagens especificadas (ex: `franciscopaulinoq/poupeai-finance-service:latest`).
  * **Reconciliação:** O Docker Compose compara os contêineres em execução com a nova configuração do arquivo `.yml` e recria apenas os serviços que foram alterados.

> Cada microsserviço tem seu próprio pipeline de CI/CD em seu respectivo repositório, responsável por construir e publicar sua imagem Docker no registro. Este repositório de infraestrutura apenas consome essas imagens prontas.