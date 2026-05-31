# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Quarto book** (type: `book`) for the course *Bases de Dados IV* — Bacharelado em Engenharia de Software at UnDF. Content is in Brazilian Portuguese. The book is published automatically to GitHub Pages on every push to `main`.

Reference: Silberschatz, Korth & Sudarshan — *Database System Concepts*, 7th ed.

## Main Source of contents

The book/webpage is based on the slides of the Database System Concepts available on the folder `slides-db-book`
The chapters are constructed based on those slides.

## Common Commands

```bash
# Preview the book locally (hot-reload)
quarto preview

# Render the full book to docs/
quarto render

# Restore R dependencies (after cloning or when renv.lock changes)
Rscript -e "renv::restore()"
```

> `execute: freeze: auto` is set in `_quarto.yml`, so Quarto only re-executes R/Python chunks when their source changes. Cached outputs live in `_freeze/` (gitignored).

## Architecture

### Content Structure

All content lives under `content/capXX/` — one directory per chapter, with one `.qmd` file per book section:

```
content/
└── cap01/
    ├── index.qmd          # Chapter overview/landing page (required)
    ├── 01-o-que-e-bd.qmd  # One file per section
    ├── 02-aplicacoes.qmd
    └── ...
```

Every new chapter needs its own subdirectory following this pattern.

### Adding Content

**Every new chapter or section file must be registered in `_quarto.yml`** under `book.chapters`. The YAML defines the full sidebar and navigation order. Files not listed there won't appear in the book.

New chapters follow the `part` + `chapters` nesting already used for Cap. 1.

### Key Files

| File | Purpose |
|---|---|
| `_quarto.yml` | Master config: chapter list, theme, output dir, site URL |
| `index.qmd` | Book home page (`.unnumbered`) |
| `references.bib` | BibTeX bibliography; cite with `@silberschatz2019` |
| `styles.css` | Custom CSS — defines `.conceito` and `.exemplo` callout classes |
| `renv.lock` | Pinned R package versions (managed by renv) |

### Custom CSS Classes

Use these Quarto div classes defined in `styles.css`:

```markdown
::: {.conceito}
Texto destacado em azul (conceito importante).
:::

::: {.exemplo}
Texto destacado em verde (exemplo).
:::
```

### CI/CD

`.github/workflows/quarto-render.yaml` runs on push to `main`:
1. Sets locale to `pt_BR.UTF-8`
2. Installs Quarto and R via official Actions
3. Restores renv packages (`r-lib/actions/setup-renv@v2`)
4. Starts a PostgreSQL service container (`POSTGRES_DB: curso`, `POSTGRES_PASSWORD` via secret)
5. Publishes to the `gh-pages` branch via `quarto-dev/quarto-actions/publish@v2`

The `docs/` directory and `_freeze/` are gitignored locally — the CI handles all rendering.

## Banco de Dados Universitário — Schema Real (dados/amostra/)

Os exemplos dos capítulos 1, 2 e 3 usam dados reais carregados de CSVs em `dados/amostra/` para um banco PostgreSQL chamado **`curso`**.

### Padrão de chaves primárias (hierárquico)

Todas as PKs são inteiros. Chaves de entidades filhas **herdam o prefixo** da entidade pai:

| Tabela | Padrão da PK | Exemplo |
|---|---|---|
| `centro` | sequencial simples (1 dígito) | `1` = COCHCMA |
| `escola` | `id_centro(1d)` + seq(1d) | `11` = ESG (centro 1, seq 1) |
| `curso` | `id_escola(2d)` + seq(1d) | `111` = ECO (escola 11, seq 1) |
| `professor` | `id_escola(2d)` + `ch_semanal(2d)` + seq(4d) | `21200001` = Eduarda (EEMA, 20h, seq 1) |
| `aluno` | `ano(4d)` + `id_curso(3d)` + seq(3d) | `2024311001` = Pedro (ENS/311, 2024, seq 1) |
| `disciplina` | `id_curso(3d)` + `semestre(2d)` + seq(2d) | `3110401` = BES4 (ENS/311, sem 4, seq 1) |
| `ministra` | PK composta: `id_disciplina`, `ano`, `semestre`, `turma` (int) | turma `'A'` → `1` |
| `prereq` | PK composta: `id_disciplina`, `id_prereq` | — |
| `matricula_disciplina` | PK composta: `id_disciplina`, `ano`, `semestre`, `turma`, `id_aluno` | — |

**Regra do professor:** o seq é global por escola (independente de ch_semanal). Exemplo: Bruno(40h) é o 1º da escola 11 → `11400001`; Carla(40h) é a 2ª → `11400002`.

### Tabelas e schema

| Tabela | Colunas principais |
|---|---|
| `centro` | `id_centro` INT (PK), `sigla`, `nome_centro` |
| `escola` | `id_escola` INT (PK), `sigla`, `nome_escola`, `id_centro` (FK→centro) |
| `curso` | `id_curso` INT (PK), `sigla_curso`, `nome_curso`, `id_escola` (FK→escola), `n_semestres`, `carga_horaria`, `tipo_curso` |
| `professor` | `id_prof` INT (PK), `nome`, `id_escola` (FK→escola), `ch_semanal`, `salario` |
| `aluno` | `id_aluno` INT (PK), `nome`, `id_curso` (FK→curso), `ano_ingresso` |
| `disciplina` | `id_disciplina` INT (PK), `nome_disciplina`, `id_curso` (FK→curso), `semestre`, `carga_horaria` |
| `ministra` | `id_disciplina`, `ano`, `semestre`, `turma` (PK composta), `id_prof` (FK→professor), `horario`, `sala` |
| `prereq` | `id_disciplina` (PK+FK→disciplina), `id_prereq` (PK+FK→disciplina) |
| `matricula_disciplina` | `id_disciplina`, `ano`, `semestre`, `turma`, `id_aluno` (PK composta), `nota`, `aprovado` |

### Dados de referência

**centro** (3 linhas):

| id_centro | sigla | nome_centro |
|---|---|---|
| 1 | COCHCMA | Ciências Humanas, Cidadania e Meio Ambiente |
| 2 | COEMAG  | Centro de Educação, Magistério e Artes |
| 3 | COETI   | Centro de Engenharias, Tecnologia e Inovação |

**escola** (3 linhas):

| id_escola | sigla | nome_escola | id_centro |
|---|---|---|---|
| 11 | ESG   | Escola Superior de Gestão | 1 |
| 21 | EEMA  | Escola de Educação, Magistério e Arte | 2 |
| 31 | ESETI | Escola Superior de Engenharias, Tecnologia e Inovação | 3 |

**curso** (3 linhas):

| id_curso | sigla_curso | nome_curso | id_escola |
|---|---|---|---|
| 111 | ECO | Ciências Econômicas | 11 |
| 211 | PED | Pedagogia | 21 |
| 311 | ENS | Engenharia de Software | 31 |

**professor** (7 linhas): ESG(11) → Bruno Teixeira `11400001` (40h, R$6.500), Carla Pinto `11400002` (40h, R$6.600); EEMA(21) → Eduarda Souza `21200001` (20h, R$3.200), Felipe Araujo `21400002` (40h, R$6.400); ESETI(31) → Gustavo Costa `31200001` (20h, R$3.300), Helena Carvalho `31400002` (40h, R$6.700), Igor Melo `31200003` (20h, R$3.100)

**aluno** (18 linhas): 6 por curso (ECO/111, PED/211, ENS/311), ingressantes 2023–2025; id_aluno = `ano × 10^7 + id_curso × 10^3 + seq`

**disciplina** (24 linhas): 8 por curso (semestres 2,4,6,8); `carga_horaria` varia de 40 a 180h; id_disciplina = `id_curso × 10^4 + semestre × 10^2 + seq`

### Nomes das pessoas
Usar **nome e sobrenome**, tipicamente brasileiros.

### Códigos de disciplina (legível)
Os ids são numéricos. Para exibição textual em material didático, usar `SIGLA-SSNN`: ex. `ENS-0401` (id 3110401), `ECO-0201` (id 1110201). Nos CSVs usar apenas o `id_disciplina` inteiro.

### Conexão R nos arquivos .qmd

Cada arquivo `.qmd` que contém chunks `{sql}` inclui um chunk R oculto no topo:

```r
#| label: setup-con
#| include: false
suppressWarnings(library(DBI))
suppressWarnings(library(RPostgres))
con <- dbConnect(
  RPostgres::Postgres(),
  dbname   = "curso",
  host     = "localhost",
  port     = 5432,
  user     = "postgres",
  password = Sys.getenv("POSTGRES_PASSWORD", "postgres")
)
```

Chunks SQL usam `--| connection: con` (prefixo `--`, não `#|`).

### Carregamento dos dados

O arquivo `content/cap01/13-hands-on-postgresql.qmd` cria todas as tabelas via DDL e carrega os CSVs com `dbWriteTable(con, tabela, df, append=TRUE)`, lendo de `dados/amostra/`. A limpeza antes do reload usa `DELETE FROM` em ordem reversa de FK (dentro de `tryCatch`). **Não usar `overwrite=TRUE`** — isso derrubaria as constraints FK.

## Dados Completos (dados/ vs dados/amostra/)

Em `dados/` existem CSVs completos da UnDF (sem `/amostra/`):
- `alunos.csv` — 2.720 linhas; `matricula_disciplina.csv` — 71.053 linhas
- Separador `;` (igual aos CSVs de amostra)
- Usar para demos de performance (índices, EXPLAIN ANALYZE)

DDL diferente do banco `curso` ao usar esses CSVs:
- `nome_disciplina TEXT` — alguns nomes têm até 209 caracteres (não `VARCHAR(100)`)
- `CHECK (carga_horaria >= 0)` — "Atividades Complementares" tem `carga_horaria = 0`

## Caminho Relativo em Chunks R

O diretório de trabalho de cada `.qmd` é o diretório do **arquivo**, não a raiz do projeto. Um arquivo em `content/cap04/` deve referenciar os CSVs como `../../dados/arquivo.csv`.

## Banco Separado para Demos de Performance

Padrão usado em `content/cap04/06-indices.qmd`: criar `curso_grande` com o dataset completo, conectar via `con_grande`, e destruir as tabelas ao final. Todo o setup fica em chunks `include: false`. Conectar ao banco `postgres` (admin) para emitir `CREATE DATABASE`. Use `dbGetQuery` (não `dbExecute`) para `pg_terminate_backend`, que retorna linhas.

## Saída de Chunks SQL — Limite de Linhas

Por padrão o knitr trunca a saída SQL em ~10 linhas. Para mostrar EXPLAIN ANALYZE completo, adicionar ao chunk de setup da página: `knitr::opts_chunk$set(max.print = NA)`

## Reordenar Seções de um Capítulo

Usar `git mv` para renomear arquivos numerados e atualizar `_quarto.yml` na mesma operação. A ordem no sidebar é definida por `_quarto.yml`, não pelo nome do arquivo.
