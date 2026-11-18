# Segurança e configuração local

Nunca publique senhas, tokens, contas de serviço ou chaves privadas em código,
issues, logs ou relatórios de falha. Use o gerenciador de segredos do serviço
responsável e conceda somente as permissões necessárias.

## Firebase no Android

Na branch com integração Firebase, use a configuração privada atualizada fornecida
na rotação e execute:

```sh
node tool/configure-firebase.cjs /caminho/privado/google-services.json
```

Opcionalmente, defina `FIREBASE_ANDROID_CONFIG` somente no ambiente local e
execute o mesmo comando sem argumento. O script valida o projeto e o pacote Android e não imprime
a chave. O pacote esperado é `com.example.more_devs_do_zero`.
O arquivo é local e ignorado pelo Git. Não mantenha uma cópia na raiz.

O plugin Google Services gera os recursos nativos usados por
`Firebase.initializeApp()`. Não é necessário um `lib/firebase_options.dart`.
Um clone novo precisa desse arquivo local antes de compilar para Android.
As demais plataformas precisam de sua própria configuração antes de usar Firebase.
Não adicione configurações reais a este repositório com `git add -f`.

A configuração privada permanece somente no computador do responsável.
Não foi salva em GitHub Secrets, código, logs ou artefatos do GitHub.
O workflow de verificação de segredos não precisa dessa configuração.

Chaves de cliente Firebase são públicas no aplicativo distribuído. Removê-las
do Git não as torna confidenciais e não substitui as proteções no servidor.

## Proteções no projeto Firebase/Google Cloud

O administrador deve confirmar no console:

1. Restrições da chave para as APIs Firebase necessárias e restrições de aplicativo
   compatíveis com os SDKs utilizados. Use chaves separadas para outros serviços;
   nunca habilite Generative Language API em uma chave pública de cliente.
2. Security Rules com acesso mínimo, testadas para usuários autenticados e não
   autenticados, nos produtos de banco/armazenamento efetivamente usados.
3. App Check: registrar o app, acompanhar métricas e validar clientes antes de
   ativar enforcement, para não bloquear usuários legítimos.
4. Quotas e alertas de consumo, logs de uso anormal e permissões IAM mínimas.
5. Caso exista abuso ou a chave permita APIs indevidas: criar uma chave restrita,
   atualizar e validar os clientes e revogar a anterior. Em incidente ativo,
   priorizar contenção, mesmo que interrompa clientes antigos.

Não armazenar segredos no Remote Config nem usá-lo como mecanismo de autorização.

## Detecção automática

O workflow `Secret scan` usa Gitleaks 8.30.1 com valores ocultos nos logs,
permissão somente de leitura e downloads verificados por SHA-256.
Ele verifica todos os arquivos atuais e os commits novos do push/PR.
A lista `.gitleaksignore` contém somente três fingerprints dos commits históricos auditados
com a chave revogada em 18/11/2026; ela só se aplica à varredura de commits.
Reintroduzir uma chave em outro commit ou nos arquivos atuais continua gerando
alerta. Não amplie essa lista sem uma nova auditoria. A execução
manual verifica os arquivos atuais. Não executa código da aplicação nem precisa
de segredos. Um alerta impede o sucesso do check, mas impedir o merge exige que
o administrador torne `Secret scan` obrigatório nas regras de proteção da branch.

O scanner pode ter falsos negativos e não substitui revisão de código.
Para uma auditoria histórica local (incluindo as exposições anteriores):

```sh
gitleaks git . --log-opts="--all --no-textconv" --redact=100
```

## Histórico e resposta a incidentes

A chave anterior foi revogada no Google Cloud em 18/11/2026.
Esta correção retira a configuração dos arquivos atuais; os commits antigos
continuam contendo a chave já revogada. A varredura histórica deve continuar reportando isso.
Não foi criada uma exceção global para ignorar chaves Google/Firebase.

Revogar/rotacionar um segredo real vem antes de limpar o histórico. Se necessário,
coordene uma reescrita com git-filter-repo, atualização das referências afetadas e
novos clones para os colaboradores. PRs, forks e caches podem conservar cópias.
Não faça force-push sem coordenar o impacto nos trabalhos em andamento.

Referências:
- https://firebase.google.com/docs/projects/api-keys
- https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository

## Configuração substituta

A chave criada em 18/11/2026 está limitada às APIs Firebase Management, Cloud
Logging, Firebase Installations, Remote Config e Remote Config Realtime.
Não habilite outras APIs sem revisar a necessidade. O projeto ainda não tem
certificado Android cadastrado: a restrição por pacote e assinatura depende
do certificado real de cada variante distribuída e deve ser testada antes de
ser aplicada. APKs antigos precisam ser recompilados com a configuração nova
pois a chave anterior foi revogada.
