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
4. Publishes to the `gh-pages` branch via `quarto-dev/quarto-actions/publish@v2`

The `docs/` directory and `_freeze/` are gitignored locally — the CI handles all rendering.

## Banco de Dados Universitário — Convenções

### Tabelas e colunas em português
| Tabela original | Nome em PT |
|---|---|
| `instructor` | `professor` |
| `student` | `aluno` |
| `course` | `disciplina` |
| `department` | `departamento` |

Colunas: `id`, `nome`, `nome_depto`, `salario`, `cred_total`, `id_disciplina`, `titulo`, `creditos`, `predio`, `orcamento`.

### Nomes das pessoas
Usar **somente nomes próprios** (primeiro nome), tipicamente brasileiros. Não usar sobrenomes.

### Departamentos (centros da UnDF)
Os departamentos do banco de dados universitário correspondem aos centros da UnDF:

| Sigla    | Nome completo                                        | Áreas cobertas |
|----------|------------------------------------------------------|----------------|
| COCBS    | Centro de Ciências Biológicas e da Saúde             | Biologia, Física |
| COETI    | Centro de Engenharia, Tecnologia e Inovação          | Ciência da Comp., Eng. Elétrica |
| COCHCMA  | Centro de Ciências Humanas, Cidadania e Meio Ambiente| Finanças, História |
| COEMAG   | Centro de Educação, Magistério e Artes               | Música |

Usar sempre a **sigla** (COCBS, COETI, COCHCMA, COEMAG) como valor da coluna `nome_centro`.

### Coluna `nome_depto` renomeada para `nome_centro`
Em todas as tabelas (`professor`, `aluno`, `disciplina`), a coluna de vínculo com o centro é `nome_centro`.

### Códigos de disciplina por curso
Seguem o padrão `PREFIX NNN` (prefixo + período + sequencial, igual ao MTI de Gestão Pública):

| Curso            | Prefixo | Exemplo  |
|------------------|---------|----------|
| Gestão Pública   | MTI     | MTI 101  |
| Eng. de Software | BES     | BES 301  |
| Nutrição         | NUT     | NUT 401  |
| Pedagogia        | PED     | PED 601  |

### Disciplinas reais das matrizes curriculares (3 por curso, períodos diferentes)
| id_disciplina | titulo                                 | nome_centro |
|---------------|----------------------------------------|-------------|
| MTI 101       | Introdução à Pesquisa Científica       | COCHCMA     |
| MTI 202       | Gestão de Pessoas na Adm. Pública      | COCHCMA     |
| MTI 402       | Políticas Públicas e Sociais           | COCHCMA     |
| BES 101       | Introdução à Engenharia de Software    | COETI       |
| BES 301       | Bases da Engenharia de Software 3      | COETI       |
| BES 601       | Projeto Aplicado 6: Machine Learning   | COETI       |
| NUT 101       | Bioquímica e Biofísica                 | COCBS       |
| NUT 401       | Epidemiologia Geral                    | COCBS       |
| NUT 701       | Nutrição em Saúde Coletiva             | COCBS       |
| PED 101       | História da Educação                   | COEMAG      |
| PED 301       | Jogos e Brincadeiras na Infância       | COEMAG      |
| PED 601       | Alfabetização e Práticas de Letramento | COEMAG      |
