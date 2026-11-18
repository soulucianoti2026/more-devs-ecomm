# Tracking da jornada

Eventos implementados: `screen_view`, `login`, `login_failed`,
`password_reset_request`, `sign_up`, `sign_up_failed`, `view_item_list`,
`view_item`, `search`, `filter_brand`, `load_error`, `add_to_cart`,
`remove_from_cart`, `view_cart`, `begin_checkout` e `purchase`.

Todas as chamadas passam por AppAnalytics. As sete páginas da jornada usam
AnalyticsMixin no initState, preservando a rota em screen_name. O observer não é
instalado no Navigator para evitar eventos duplicados e telas fora do escopo.

Adaptações ao código atual:

- Produtos já possuem IDs; item_id usa esse ID, com nome como fallback.
- Busca remota aguarda 1 segundo sem digitação e registra o resultado da resposta
  atual, ignorando respostas obsoletas e cancelando o timer ao sair da página.
- Erros de cadastro preservam a mensagem exibida, mas enviam apenas
  SignupExceptionType.name. Termos recusados enviam `terms_not_accepted`.
- O carrinho carrega da API antes de enviar view_cart, uma vez por abertura.
- Continuar abre a confirmação e envia begin_checkout. Confirmar Pedido envia
  purchase somente após a API criar o pedido, com transaction_id e cópia dos
  itens anterior à limpeza do carrinho. Falhas não geram purchase.
- Alterações de quantidade (+/-) não geram eventos, conforme a regra explícita
  do PDF. Remoção confirmada registra a quantidade inteira removida.
- A recuperação atual tem três etapas; password_reset_request corresponde ao
  envio inicial do código, sem email, senha ou código nos parâmetros.

## Validação no dispositivo

O Android requer um `android/app/google-services.json` local, ignorado pelo Git
(consulte [SECURITY.md](../SECURITY.md)), e o plugin
Google Services no Gradle. A inicialização usa os recursos nativos gerados pelo
plugin, sem precisar de firebase_options.dart para esse fluxo Android.
A configuração iOS ainda depende de GoogleService-Info.plist.

Em 12/11/2026, o APK debug foi compilado e instalado no Moto G84. Os logs
confirmaram `FirebaseApp initialization successful`, screen_view da rota
`/login` e upload do pacote `com.example.more_devs_do_zero` ao Google Analytics
com resposta HTTP 204. O modo de debug ficou habilitado no aparelho.
Isso valida a inicialização e o transporte; a visualização no console e a
jornada completa de compra ainda precisam de confirmação no DebugView.

O applicationId Android deste projeto é `com.example.more_devs_do_zero`:

```sh
adb shell setprop debug.firebase.analytics.app com.example.more_devs_do_zero
```

Percorra login → produto → adicionar ao carrinho → carrinho → Continuar →
Confirmar Pedido e confira a sequência e os parâmetros no Firebase DebugView.
Confira também login inválido, termos recusados, busca rápida, remoção e falha
de checkout. Capture a evidência no projeto Firebase configurado; testes locais
não substituem essa verificação de entrega. Nenhuma evidência de DebugView foi
gerada nesta implementação.
