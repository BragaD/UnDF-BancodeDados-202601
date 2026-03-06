# Banco de Dados para Engenharia de Software

Material de apoio da disciplina **Bases de Dados IV** do Bacharelado em Engenharia de Software — UnDF.

O site do curso é publicado automaticamente via GitHub Actions em:
**https://dbraga.github.io/BasesIV_EngSoft_BD**

## Estrutura do Repositório

```
.
├── _quarto.yml              # Configuração do projeto Quarto
├── index.qmd                # Página inicial
├── 01-introducao.qmd        # Cap. 1 — Introdução a Bancos de Dados
├── styles.css               # Estilos customizados
├── references.bib           # Referências bibliográficas
├── slides-db-book/          # Slides originais (Silberschatz et al.)
│   ├── ch1.pdf
│   ├── ch2.pdf
│   └── ch3.pdf
└── .github/
    └── workflows/
        └── quarto-render.yaml   # CI/CD: render e deploy no GitHub Pages
```

## Referência Principal

Silberschatz, Abraham; Korth, Henry F.; Sudarshan, S. **Database System Concepts**, 7th ed. McGraw-Hill, 2019.

## Como Contribuir / Executar Localmente

1. Instale o [Quarto](https://quarto.org/docs/get-started/)
2. Clone o repositório
3. Execute `quarto preview` para visualizar localmente
4. Execute `quarto render` para gerar o site em `docs/`

## Deploy

O site é publicado automaticamente no GitHub Pages a cada push na branch `main` via GitHub Actions.

Para habilitar o deploy:
1. Vá em **Settings > Pages** do repositório
2. Selecione a branch `gh-pages` como fonte

## Licença

O material produzido neste repositório está disponível para fins educacionais.
Os slides originais são de autoria de Silberschatz, Korth e Sudarshan — consulte [db-book.com](https://www.db-book.com) para condições de uso.
