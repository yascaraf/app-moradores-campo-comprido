# App da Associação de Moradores do Campo Comprido

Aplicativo móvel que centraliza a divulgação das ações comunitárias da Associação de Moradores do Bairro Campo Comprido (Curitiba, PR) e facilita a inscrição de moradores como voluntários.

Projeto da disciplina Projeto de Software (Análise e Desenvolvimento de Sistemas).

## Problema

Hoje, os avisos sobre as ações da associação circulam em grupos de WhatsApp, onde se misturam a outras conversas e acabam se perdendo. Isso dificulta a divulgação das atividades e o recrutamento de voluntários.

## O que o MVP faz

- Login de moradores e de representantes da associação, com perfis de acesso diferentes.
- Representante: cadastra, encerra e cancela ações e consulta os inscritos.
- Morador: consulta as ações abertas, vê os detalhes, se inscreve e cancela a própria inscrição.
- Notificação aos moradores quando uma nova ação é cadastrada.

Ficam fora do MVP: chat, integração com WhatsApp e redes sociais, relatórios e dashboards.

## Tecnologias

- Flutter 3.50.0 (Dart), apenas Android nesta primeira versão
- Firebase: Authentication, Cloud Firestore e Cloud Messaging
- provider (estado), flutter_test e mocktail (testes)

## Arquitetura

Monolito em três camadas: apresentação (telas), lógica de negócio (regras e validações) e acesso a dados (Firebase).

## Como executar

Pré-requisitos: Git, Flutter 3.50.0, Android SDK e um celular Android com depuração USB.

1. Clone o repositório e entre na pasta:
   ```
   git clone https://github.com/yascaraf/app-moradores-campo-comprido.git
   cd app-moradores-campo-comprido
   flutter pub get
   ```
2. Crie um projeto no Firebase, registre um app Android com o identificador `br.com.campocomprido.app_moradores_campo_comprido` e coloque o arquivo `google-services.json` baixado em `android/app/`. Esse arquivo não é versionado.
3. Conecte o celular e execute:
   ```
   flutter run
   ```

## Testes

```
flutter test
```

## Status

Em desenvolvimento.