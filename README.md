# more_devs_do_zero

A new Flutter project.

## Autenticação

Login, cadastro e recuperação de senha usam Dio e o contrato em
[Swagger](https://api-production-c0289.up.railway.app/docs/).

- `POST /auth/login`: e-mail e senha; recebe usuário e token.
- `POST /auth/register`: nome, e-mail, senha, confirmação e aceite dos termos;
  abre a sessão retornada pela API.
- `POST /auth/password/forgot`: solicita o código por e-mail.
- `POST /auth/password/verify-code`: troca o código por um `resetToken`.
- `POST /auth/password/reset`: envia o `resetToken` e a nova senha.

Com “Lembrar-me” marcado, o token e sua validade são persistidos com
`flutter_secure_storage`; a senha nunca é salva. O e-mail continua em
`SharedPreferences`. Ao abrir o app, `AuthService.restoreSession` consulta
`GET /users/me` com o token salvo e abre a Home somente após a validação pela API.
Logout, token expirado e HTTP 401 removem a sessão salva. Falhas temporárias de
rede preservam o token para uma próxima abertura, mas exibem o login.
Sem “Lembrar-me”, a sessão permanece somente em memória.
O arquivo antigo
`mock_auth.json` não é mais lido nem atualizado; contas locais do mock precisam
ser cadastradas na API.

## Catálogo, conta, carrinho e pedidos

`StoreService` usa a mesma URL base (incluindo `/api/v1`). Categorias e produtos
são públicos; usuário, carrinho e pedidos recebem `Authorization: Bearer <token>`.
O servidor identifica a conta pelo token, sem receber um ID de usuário do app.

- A Home carrega `/users/me`, `/categories`, `/products` e `/cart`.
- A tela de categoria usa `categoryId`, busca por `search` e filtro `brand`;
  as marcas vêm de `/categories/{categoryId}/brands`.
- O detalhe do produto carrega `/products/{productId}`, incluindo a descrição.
- Adicionar, diminuir e remover itens atualiza `/cart/items` pelo ID do produto.
  Quantidades, subtotais e total exibidos vêm da resposta da API.
- “Finalizar Compra” cria um pedido em `/orders`. Após o sucesso, o carrinho
  fica vazio e o app abre o detalhe do pedido. Criar um pedido não confirma pagamento.
- Os ícones “Minha conta” e “Meus pedidos” na Home abrem `/profile` e `/orders`
  (rotas Flutter). A lista e o detalhe consultam somente os pedidos da sessão atual.

Logout/troca de conta limpa o carrinho local. Respostas atrasadas de outra sessão
são descartadas. Um HTTP 401 encerra a sessão e retorna ao login.
Os banners promocionais continuam sendo imagens locais.

A URL padrão já aponta para a API Railway. Para usar outro ambiente:

```sh
flutter run --dart-define=API_BASE_URL=https://sua-api.example.com/api/v1
```

Validação local (requisições simuladas, sem criar contas na API):

```sh
flutter analyze
flutter test
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Camada HTTP e exceções

`ApiClient` define a abstração de transporte em `lib/shared/http`.
`DioApiClient` centraliza GET, POST, PUT, PATCH, DELETE, URL base, timeouts
 e conversão de falhas. `AuthService` e `StoreService` recebem `ApiClient`
 por injeção; o parâmetro `dio` permanece compatível com os testes existentes.

O tratamento segue `Error` em https://api-production-c0289.up.railway.app/docs/json:
`code` e `message`, com `details` opcional contendo `{field, message}`.
`ApiException` preserva esses campos, o status HTTP e a categoria da falha.
Respostas sem o contrato recebem mensagem de fallback; falhas de timeout,
conexão, cancelamento e certificado recebem mensagens específicas.
`AuthExeception` herda `ApiException` e mantém os mesmos metadados.
HTTP 401 em requisições autenticadas continua expirando apenas a sessão
que iniciou a chamada. Não há repetição automática de requisições de escrita.

```dart
try {
  await store.addItem(productId);
} on ApiException catch (error) {
  // error.message: mensagem para o usuário
  // error.code: código estável para decisões do aplicativo
  // error.details: erros por campo (field/message)
  // error.statusCode e error.kind: status HTTP e categoria da falha
}
```

## Segurança e configuração Firebase

Antes de compilar para Android, forneça a configuração local conforme
[SECURITY.md](SECURITY.md). Chaves e configurações reais não devem ser commitadas.
