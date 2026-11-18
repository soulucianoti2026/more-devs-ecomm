# Firebase Remote Config

Implementação do guia `Guia Firebase Remote Config no Fluter.pdf`.

## Configuração do console

No projeto Firebase `ecomfirebaseapp-73b2a`, abra Run → Remote Config,
crie os parâmetros abaixo e selecione **Publish changes**:

| Parâmetro | Tipo | Padrão no app |
| --- | --- | --- |
| `welcome_message` | String | `Olá!` |
| `new_checkout_enabled` | Boolean | `false` |
| `max_items` | Number (inteiro) | `10` |

A mensagem é exibida na Home. A flag e o limite estão disponíveis no
contrato `AppRemoteConfig`. O PDF não define o novo checkout nem a operação
limitada por `max_items`; esses comportamentos de negócio não foram inventados.

## Plataformas e inicialização

O Android usa os recursos nativos gerados a partir do arquivo local
`android/app/google-services.json`, ignorado pelo Git. Forneça esse arquivo
antes do build seguindo [SECURITY.md](../SECURITY.md). A inicialização usa
`Firebase.initializeApp()`; não há chave embutida em um arquivo Dart versionado.
Outras plataformas precisam de sua própria configuração.

O Firebase é inicializado antes do serviço e de `runApp`. O fetch tem timeout
de 10 segundos, intervalo zero em debug e uma hora em release, conforme o
exemplo da seção 4 do PDF. Falhas de fetch preservam padrões ou cache.
Sem Firebase configurado, o aplicativo usa os padrões locais.

O listener ativa mudanças e notifica a UI. Na Web, não se registra listener;
o fetch ocorre na inicialização e ao atualizar a Home. O serviço singleton
é disponibilizado por Provider. Testes podem injetar uma implementação de
`AppRemoteConfig` pelo parâmetro `MyApp(remoteConfig: ...)`.

## Operação

Não armazenar segredos nem usar flags como autorização. Antes de conectar
uma flag a um novo fluxo, definir responsável e data de remoção e testar os
dois estados. Publicação de parâmetros, segmentação, rollout e experimentos
A/B são configurados no Console Firebase e não foram executados aqui.

Referência complementar: https://firebase.google.com/docs/remote-config/flutter/get-started
