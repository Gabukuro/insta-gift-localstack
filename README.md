# insta-gift-localstack

## Visão Geral

O projeto `insta-gift-localstack` fornece uma infraestrutura local para o desenvolvimento e teste de componentes que interagem com serviços da AWS, utilizando o LocalStack e o Terraform.

Este projeto utiliza o Docker e o Docker Compose para facilitar o ambiente local, e o Terraform v1.6.3 para gerenciar a infraestrutura.

## Pré-requisitos

Certifique-se de ter as seguintes ferramentas instaladas em sua máquina:

- Docker (versão 24.0.7 ou superior)
- Docker Compose
- Terraform (versão 1.6.3)

## Instalação

1. Clone o repositório:

  ```bash
    git clone https://github.com/Gabukurp/insta-gift-localstack.git
  ```
  ```bash
    cd insta-gift-localstack
  ```

2. Adicione as credenciais do localstack:
  ```bash
  mkdir -p ~/.aws
  ```

  ```bash
  cat <<EOT >> ~/.aws/config
  [default]
  region=us-east-2
  output=json
  EOT
  ```

  ```bash
  cat <<EOT >> ~/.aws/config
  [localstack-profile]
  aws_access_key_id=test
  aws_secret_access_key=test
  EOT
  ```

3. Inicie os contêineres Docker usando o Docker Compose:

  ```bash
    docker-compose up -d
  ```
  Isso iniciará os serviços necessários, incluindo o LocalStack, em contêineres Docker.

4. Inicialize e aplique as configurações do Terraform:

  ```bash
    terraform init
    terraform apply
  ```
  Isso criará a infraestrutura local usando o LocalStack de acordo com as configurações fornecidas pelo Terraform.

## Como Parar
  Para parar e remover os contêineres Docker e recursos do LocalStack:

  ```bash
    docker-compose down
  ```
