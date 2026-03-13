DROP TABLE IF EXISTS matricula_disciplina, ministra,
                     disciplina, aluno, professor,
                     curso, escola, centro CASCADE;

CREATE TABLE IF NOT EXISTS centro (
    centro     VARCHAR(10)  PRIMARY KEY,
    nome_centro VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS escola (
    escola      VARCHAR(10)  PRIMARY KEY,
    nome_escola VARCHAR(100) NOT NULL,
    centro      VARCHAR(10)  REFERENCES centro(centro)
);

CREATE TABLE IF NOT EXISTS curso (
    sigla_curso   VARCHAR(5)   PRIMARY KEY,
    nome_curso    VARCHAR(100) NOT NULL,
    escola        VARCHAR(10)  REFERENCES escola(escola),
    n_semestres   INTEGER      NOT NULL,
    carga_horaria INTEGER      NOT NULL,
    tipo_curso    VARCHAR(20)  NOT NULL
);

CREATE TABLE IF NOT EXISTS professor (
    matricula_prof VARCHAR(15)    PRIMARY KEY,
    nome           VARCHAR(50)    NOT NULL,
    escola         VARCHAR(10)    REFERENCES escola(escola),
    ch_semanal     INTEGER        NOT NULL,
    salario        NUMERIC(10,2)  NOT NULL
);

CREATE TABLE IF NOT EXISTS aluno (
    matricula    VARCHAR(15)  PRIMARY KEY,
    nome         VARCHAR(50)  NOT NULL,
    sigla_curso  VARCHAR(5)   REFERENCES curso(sigla_curso),
    ano_ingresso INTEGER      NOT NULL
);

CREATE TABLE IF NOT EXISTS disciplina (
    codigo         VARCHAR(10)  PRIMARY KEY,
    nome_disciplina VARCHAR(100) NOT NULL,
    sigla_curso    VARCHAR(5)   REFERENCES curso(sigla_curso),
    semestre       INTEGER      NOT NULL,
    carga_horaria  INTEGER      NOT NULL
);

CREATE TABLE IF NOT EXISTS ministra (
    cod_disciplina  VARCHAR(10)  REFERENCES disciplina(codigo),
    ano             INTEGER      NOT NULL,
    semestre        INTEGER      NOT NULL,
    turma           CHAR(1)      NOT NULL,
    matricula_prof  VARCHAR(15)  REFERENCES professor(matricula_prof),
    horario         VARCHAR(50),
    sala            VARCHAR(20),
    PRIMARY KEY (cod_disciplina, ano, semestre, turma)
);

CREATE TABLE IF NOT EXISTS matricula_disciplina (
    cod_disciplina VARCHAR(10) NOT NULL,
    ano            INTEGER     NOT NULL,
    semestre       INTEGER     NOT NULL,
    turma          CHAR(1)     NOT NULL,
    cod_matricula  VARCHAR(15) REFERENCES aluno(matricula),
    nota           NUMERIC(4,1),
    aprovado       SMALLINT,
    PRIMARY KEY (cod_disciplina, ano, semestre, turma, cod_matricula),
    FOREIGN KEY (cod_disciplina, ano, semestre, turma)
        REFERENCES ministra(cod_disciplina, ano, semestre, turma)
);
