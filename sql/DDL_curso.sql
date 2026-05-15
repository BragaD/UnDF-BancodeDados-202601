-- =============================================================
-- Parte 2 — DDL: criação das tabelas do banco curso
-- Atividade Prática 1 — Bases de Dados IV / UnDF 2026.1
-- =============================================================
-- Ordem: tabelas referenciadas devem existir antes das que as referenciam.
-- centro → escola → curso/professor/aluno → disciplina → prereq/ministra → matricula_disciplina

-- Remove tudo em ordem inversa para evitar erro de FK
DROP TABLE IF EXISTS matricula_disciplina, ministra, prereq, disciplina,
                     aluno, professor, curso, escola, centro CASCADE;

-- ---------------------------------------------------------------
-- centro: entidade raiz, sem FK
-- sigla é UNIQUE para evitar duplicatas de código
-- ---------------------------------------------------------------
CREATE TABLE centro (
    id_centro   INTEGER      PRIMARY KEY,
    sigla       VARCHAR(10)  NOT NULL UNIQUE,
    nome_centro VARCHAR(100) NOT NULL
);

-- ---------------------------------------------------------------
-- escola: pertence a um centro (FK obrigatória)
-- ---------------------------------------------------------------
CREATE TABLE escola (
    id_escola   INTEGER      PRIMARY KEY,
    sigla       VARCHAR(10)  NOT NULL UNIQUE,
    nome_escola VARCHAR(100) NOT NULL,
    id_centro   INTEGER      NOT NULL REFERENCES centro(id_centro)
);

-- ---------------------------------------------------------------
-- curso: ofertado por uma escola
-- CHECK garante tipos e valores positivos
-- ---------------------------------------------------------------
CREATE TABLE curso (
    id_curso      INTEGER      PRIMARY KEY,
    sigla_curso   VARCHAR(5)   NOT NULL UNIQUE,
    nome_curso    VARCHAR(100) NOT NULL,
    id_escola     INTEGER      NOT NULL REFERENCES escola(id_escola),
    n_semestres   INTEGER      NOT NULL CHECK (n_semestres > 0),
    carga_horaria INTEGER      NOT NULL CHECK (carga_horaria > 0),
    tipo_curso    VARCHAR(20)  NOT NULL
                               CHECK (tipo_curso IN ('bacharelado', 'licenciatura', 'tecnólogo'))
);

-- ---------------------------------------------------------------
-- professor: lotado em uma escola
-- ch_semanal > 0 e salario >= 0 por regra de negócio
-- ---------------------------------------------------------------
CREATE TABLE professor (
    id_prof    INTEGER       PRIMARY KEY,
    nome       VARCHAR(50)   NOT NULL,
    id_escola  INTEGER       NOT NULL REFERENCES escola(id_escola),
    ch_semanal INTEGER       NOT NULL CHECK (ch_semanal > 0),
    salario    NUMERIC(10,2) NOT NULL CHECK (salario >= 0)
);

-- ---------------------------------------------------------------
-- aluno: matriculado em um curso
-- ---------------------------------------------------------------
CREATE TABLE aluno (
    id_aluno     INTEGER     PRIMARY KEY,
    nome         VARCHAR(50) NOT NULL,
    id_curso     INTEGER     NOT NULL REFERENCES curso(id_curso),
    ano_ingresso INTEGER     NOT NULL
);

-- ---------------------------------------------------------------
-- disciplina: pertence a um curso, em um semestre específico
-- carga_horaria > 0 impede disciplinas sem carga
-- ---------------------------------------------------------------
CREATE TABLE disciplina (
    id_disciplina   INTEGER      PRIMARY KEY,
    nome_disciplina VARCHAR(100) NOT NULL,
    id_curso        INTEGER      NOT NULL REFERENCES curso(id_curso),
    semestre        INTEGER      NOT NULL CHECK (semestre > 0),
    carga_horaria   INTEGER      NOT NULL CHECK (carga_horaria > 0)
);

-- ---------------------------------------------------------------
-- prereq: relacionamento autorreferencial — pré-requisito entre disciplinas
-- PK composta impede a mesma relação duplicada
-- ---------------------------------------------------------------
CREATE TABLE prereq (
    id_disciplina INTEGER NOT NULL REFERENCES disciplina(id_disciplina),
    id_prereq     INTEGER NOT NULL REFERENCES disciplina(id_disciplina),
    PRIMARY KEY (id_disciplina, id_prereq)
);

-- ---------------------------------------------------------------
-- ministra: turma ofertada (professor + disciplina + ano/semestre/turma)
-- semestre IN (1,2) e turma > 0 por regra acadêmica
-- id_prof pode ser NULL se a turma ainda não tiver professor designado
-- ---------------------------------------------------------------
CREATE TABLE ministra (
    id_disciplina INTEGER    NOT NULL REFERENCES disciplina(id_disciplina),
    ano           INTEGER    NOT NULL,
    semestre      INTEGER    NOT NULL CHECK (semestre IN (1, 2)),
    turma         INTEGER    NOT NULL CHECK (turma > 0),
    id_prof       INTEGER    REFERENCES professor(id_prof),
    horario       VARCHAR(50),
    sala          VARCHAR(20),
    PRIMARY KEY (id_disciplina, ano, semestre, turma)
);

-- ---------------------------------------------------------------
-- matricula_disciplina: agregação — aluno matriculado em uma turma
-- FK composta para ministra garante que a turma existe
-- aprovado: 0 = reprovado, 1 = aprovado, NULL = cursando
-- ---------------------------------------------------------------
CREATE TABLE matricula_disciplina (
    id_disciplina INTEGER     NOT NULL,
    ano           INTEGER     NOT NULL,
    semestre      INTEGER     NOT NULL,
    turma         INTEGER     NOT NULL,
    id_aluno      INTEGER     NOT NULL REFERENCES aluno(id_aluno),
    nota          NUMERIC(4,1),
    aprovado      SMALLINT    CHECK (aprovado IN (0, 1)),
    PRIMARY KEY (id_disciplina, ano, semestre, turma, id_aluno),
    FOREIGN KEY (id_disciplina, ano, semestre, turma)
        REFERENCES ministra(id_disciplina, ano, semestre, turma)
);
