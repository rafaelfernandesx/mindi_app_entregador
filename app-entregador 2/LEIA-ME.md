# Como gerar o APK sem instalar nada no seu Mac

Tudo é feito pelo navegador. Leva uns 15 minutos na primeira vez.

---

## Passo 1 — Criar uma conta no GitHub (grátis)

Acesse **github.com** e crie uma conta, se ainda não tiver.

---

## Passo 2 — Criar um repositório

1. Clique no **+** no canto superior direito → **New repository**
2. Nome: `app-entregador`
3. Marque **Private** (para o código ficar só seu)
4. Clique em **Create repository**

---

## Passo 3 — Enviar os arquivos

Na tela do repositório vazio:

1. Clique em **uploading an existing file**
2. Arraste **todo o conteúdo desta pasta** para a área de upload
   (o GitHub aceita arrastar pastas inteiras pelo navegador Chrome)
3. Clique em **Commit changes**

> ⚠️ A pasta `.github` é oculta no Mac. Para vê-la no Finder, aperte
> **Cmd + Shift + Ponto**. Ela precisa ser enviada junto — é ela que
> manda o GitHub montar o APK.

---

## Passo 4 — Esperar o APK ficar pronto

1. Clique na aba **Actions** (no topo do repositório)
2. Você vai ver um item chamado **Gerar APK** rodando (bolinha amarela)
3. Espere de 5 a 10 minutos, até virar um **✓ verde**

Se der erro (✗ vermelho), clique nele, copie a mensagem e me mande.

---

## Passo 5 — Baixar o APK

1. Ainda dentro do item que terminou, role a página até o fim
2. Em **Artifacts**, clique em **app-entregador-apk**
3. Vai baixar um `.zip` — descompacte e dentro está o `app-release.apk`

---

## Passo 6 — Instalar no celular Android

1. Mande o arquivo `.apk` para o celular (WhatsApp, e-mail, Google Drive)
2. Abra o arquivo no celular
3. O Android vai avisar *"instalação de fontes desconhecidas"* — autorize
4. Pronto, o app abre

---

## Sempre que quiser uma versão nova

Edite o arquivo `app_src/tela_aguardando.dart` direto pelo site do GitHub
(clique no arquivo → ícone de lápis → editar → **Commit changes**).
O APK novo é gerado automaticamente. É só voltar na aba **Actions** e baixar.

---

## O que tem nesta pasta

| Arquivo | Para que serve |
|---|---|
| `app_src/tela_aguardando.dart` | A tela em si (design, animação, tab bar) |
| `app_src/main.dart` | Ponto de partida do app |
| `pubspec.yaml` | Nome e versão do app |
| `.github/workflows/build-apk.yml` | A receita que manda o GitHub montar o APK |

---

## Observações

- Este APK é de **teste**. Para publicar na Play Store é preciso conta de
  desenvolvedor (US$ 25, pagamento único) e assinar o app com uma chave.
- **iPhone não instala APK.** Para iOS o caminho é outro (conta Apple,
  US$ 99 por ano).
- O GitHub Actions é grátis para repositórios privados até 2.000 minutos
  por mês. Cada APK consome uns 8 minutos.
