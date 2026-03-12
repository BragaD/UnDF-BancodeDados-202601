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

### Tabelas e schema

| Tabela | Colunas principais |
|---|---|
| `centro` | `centro` (PK), `nome_centro` |
| `escola` | `escola` (PK), `nome_escola`, `centro` (FK→centro) |
| `curso` | `sigla_curso` (PK), `nome_curso`, `escola` (FK→escola), `n_semestres`, `carga_horaria`, `tipo_curso` |
| `professor` | `matricula_prof` (PK), `nome`, `escola` (FK→escola), `ch_semanal`, `salario` |
| `aluno` | `matricula` (PK), `nome`, `sigla_curso` (FK→curso), `ano_ingresso` |
| `disciplina` | `codigo` (PK), `nome_disciplina`, `sigla_curso` (FK→curso), `semestre`, `carga_horaria` |
| `ministra` | `cod_disciplina`, `ano`, `semestre`, `turma` (PK composta), `matricula_prof` (FK→professor) |
| `matricula_disciplina` | `cod_disciplina`, `ano`, `semestre`, `turma`, `cod_matricula` (PK composta), `nota`, `aprovado` |

### Dados de referência

**centro** (3 linhas):

| centro | nome_centro |
|---|---|
| COCHCMA | Ciências Humanas, Cidadania e Meio Ambiente |
| COEMAG  | Centro de Educação, Magistério e Artes |
| COETI   | Centro de Engenharias, Tecnologia e Inovação |

**escola** (3 linhas):

| escola | nome_escola | centro |
|---|---|---|
| ESG   | Escola Superior de Gestão | COCHCMA |
| EEMA  | Escola de Educação, Magistério e Arte | COEMAG |
| ESETI | Escola Superior de Engenharias, Tecnologia e Inovação | COETI |

**curso** (3 linhas): `ENS` (Engenharia de Software, ESETI), `ECO` (Ciências Econômicas, ESG), `PED` (Pedagogia, EEMA)

**professor** (7 linhas): EEMA → Eduarda Souza (20h, R$3.200), Felipe Araujo (40h, R$6.400); ESETI → Gustavo Costa (20h, R$3.300), Helena Carvalho (40h, R$6.700), Igor Melo (20h, R$3.100); ESG → Bruno Teixeira (40h, R$6.500), Carla Pinto (40h, R$6.600)

**aluno** (18 linhas): 6 por curso (ENS/ECO/PED), ingressantes 2023–2025

**disciplina** (24 linhas): 8 por curso (semestres 2,4,6,8); `carga_horaria` varia de 40 a 180h

### Nomes das pessoas
Usar **nome e sobrenome**, tipicamente brasileiros.

### Códigos de disciplina
Padrão `SIGLA-SSS` (sigla do curso + semestre + sequencial): ex. `ENS-201`, `ECO-401`, `PED-801`.

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
