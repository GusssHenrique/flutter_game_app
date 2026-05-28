# 🎮 GameRank

Catálogo de jogos digitais com sistema de avaliações. Permite que usuários autenticados cadastrem jogos, escrevam reviews e visualizem a média de notas de cada título.

---

## Funcionalidades principais

- **Autenticação** — cadastro e login com e-mail e senha
- **Listagem de jogos** — visualização em cards com busca por nome e filtro por gênero
- **Cadastro e edição de jogos** — título, gênero, plataforma, desenvolvedor, ano de lançamento, imagem e descrição
- **Avaliações** — cada usuário pode criar, editar ou excluir sua própria review com nota (0–10) e comentário
- **Média de notas** — calculada automaticamente a partir de todas as reviews do jogo
- **Tema escuro** — interface com design escuro e fontes Poppins

---

## Tecnologias utilizadas

| Tecnologia | Uso |
|---|---|
| [Flutter](https://flutter.dev/) | Framework principal (mobile, web e desktop) |
| [Dart](https://dart.dev/) | Linguagem de programação |
| [Supabase](https://supabase.com/) | Backend: autenticação e banco de dados |
| [supabase_flutter](https://pub.dev/packages/supabase_flutter) | SDK do Supabase para Flutter |
| [google_fonts](https://pub.dev/packages/google_fonts) | Fonte Poppins |
| [flutter_rating_bar](https://pub.dev/packages/flutter_rating_bar) | Componente de avaliação por estrelas |
| [cached_network_image](https://pub.dev/packages/cached_network_image) | Carregamento e cache de imagens remotas |
| [url_launcher](https://pub.dev/packages/url_launcher) | Abertura de links externos |

---

## Como executar o projeto

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado
- VS Code com a extensão **Flutter** (da Dart Code)

### Passo a passo

**1. Clone ou abra o projeto no VS Code**

**2. Instale as dependências**

No terminal integrado do VS Code (`` Ctrl + ` ``):

```bash
flutter pub get
```

**3. Execute o app**

```bash
flutter run
```

Para rodar especificamente no Chrome:

```bash
flutter run -d chrome
```

Ou pressione **F5** no VS Code com um dispositivo selecionado na barra inferior.

> **Nota:** o projeto já está configurado e conectado a um banco de dados Supabase ativo — basta executar. Nenhuma configuração adicional é necessária para rodá-lo como está.

### Usando seu próprio banco de dados (opcional)

Caso queira conectar o projeto a um Supabase próprio, abra `lib/supabase_config.dart` e substitua as credenciais pelas do seu projeto (encontradas em *Supabase Dashboard → Project Settings → API*):

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://SEU_PROJETO.supabase.co';
  static const String supabaseAnonKey = 'SUA_ANON_KEY';
}
```

Será necessário também criar as tabelas `games` e `reviews` no seu banco — a estrutura está descrita na seção abaixo.

---

## Autenticação e banco de dados

### Autenticação

A autenticação é gerenciada inteiramente pelo **Supabase Auth**. Os dados de login (e-mail e senha criptografada) são armazenados na tabela interna `auth.users`, controlada pelo próprio Supabase — não é necessário criar nenhuma tabela de usuários manualmente.

### Banco de dados

O projeto utiliza duas tabelas no Supabase:

**`games`** — armazena os jogos cadastrados

| Coluna | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Chave primária gerada automaticamente |
| `title` | TEXT | Nome do jogo |
| `genre` | TEXT | Gênero (ex: RPG, FPS) |
| `platform` | TEXT | Plataforma (ex: PC, PS5) |
| `image_url` | TEXT | URL da imagem de capa (opcional) |
| `description` | TEXT | Descrição do jogo (opcional) |
| `release_year` | INTEGER | Ano de lançamento (opcional) |
| `developer` | TEXT | Desenvolvedora (opcional) |
| `created_at` | TIMESTAMPTZ | Data de criação |

**`reviews`** — armazena as avaliações dos usuários

| Coluna | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Chave primária gerada automaticamente |
| `game_id` | UUID | Referência ao jogo avaliado |
| `user_id` | UUID | Referência ao usuário autor |
| `user_email` | TEXT | E-mail do autor (opcional) |
| `rating` | NUMERIC | Nota de 0 a 10 |
| `comment` | TEXT | Comentário (opcional) |
| `created_at` | TIMESTAMPTZ | Data de criação |
| `updated_at` | TIMESTAMPTZ | Data da última edição |

> Cada usuário pode ter apenas uma review por jogo.
