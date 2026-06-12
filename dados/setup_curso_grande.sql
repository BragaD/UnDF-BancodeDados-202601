-- setup_curso_grande.sql
-- Cria o banco curso_grande e carrega os CSVs completos da UnDF.

-- ─── DDL ─────────────────────────────────────────────────────────────────────

CREATE TABLE centro (
  id_centro   INTEGER      PRIMARY KEY,
  sigla       VARCHAR(10)  NOT NULL UNIQUE,
  nome_centro VARCHAR(100) NOT NULL
);

CREATE TABLE escola (
  id_escola   INTEGER      PRIMARY KEY,
  sigla       VARCHAR(10)  NOT NULL UNIQUE,
  nome_escola VARCHAR(100) NOT NULL,
  id_centro   INTEGER      REFERENCES centro(id_centro)
);

CREATE TABLE curso (
  id_curso      INTEGER      PRIMARY KEY,
  sigla_curso   VARCHAR(5)   NOT NULL UNIQUE,
  nome_curso    VARCHAR(100) NOT NULL,
  id_escola     INTEGER      REFERENCES escola(id_escola),
  n_semestres   INTEGER      NOT NULL,
  carga_horaria INTEGER      NOT NULL,
  tipo_curso    VARCHAR(20)  NOT NULL
);

CREATE TABLE professor (
  id_prof    INTEGER       PRIMARY KEY,
  nome       VARCHAR(50)   NOT NULL,
  id_escola  INTEGER       REFERENCES escola(id_escola),
  ch_semanal INTEGER       NOT NULL,
  salario    NUMERIC(10,2) NOT NULL
);

CREATE TABLE aluno (
  id_aluno     INTEGER     PRIMARY KEY,
  nome         VARCHAR(50) NOT NULL,
  id_curso     INTEGER     REFERENCES curso(id_curso),
  ano_ingresso INTEGER     NOT NULL
);

CREATE TABLE disciplina (
  id_disciplina   INTEGER  PRIMARY KEY,
  nome_disciplina TEXT     NOT NULL,
  id_curso        INTEGER  REFERENCES curso(id_curso),
  semestre        INTEGER  NOT NULL,
  carga_horaria   INTEGER  NOT NULL CHECK (carga_horaria >= 0)
);

CREATE TABLE prereq (
  id_disciplina INTEGER REFERENCES disciplina(id_disciplina),
  id_prereq     INTEGER REFERENCES disciplina(id_disciplina),
  PRIMARY KEY (id_disciplina, id_prereq)
);

CREATE TABLE ministra (
  id_disciplina INTEGER REFERENCES disciplina(id_disciplina),
  ano           INTEGER NOT NULL,
  semestre      INTEGER NOT NULL,
  turma         INTEGER NOT NULL,
  id_prof       INTEGER REFERENCES professor(id_prof),
  horario       VARCHAR(50),
  sala          VARCHAR(20),
  PRIMARY KEY (id_disciplina, ano, semestre, turma)
);

CREATE TABLE matricula_disciplina (
  id_disciplina INTEGER NOT NULL,
  ano           INTEGER NOT NULL,
  semestre      INTEGER NOT NULL,
  turma         INTEGER NOT NULL,
  id_aluno      INTEGER REFERENCES aluno(id_aluno),
  nota          NUMERIC(4,1),
  aprovado      SMALLINT,
  PRIMARY KEY (id_disciplina, ano, semestre, turma, id_aluno),
  FOREIGN KEY (id_disciplina, ano, semestre, turma)
    REFERENCES ministra(id_disciplina, ano, semestre, turma)
);

-- ─── Carga de dados (ordem respeita FKs) ─────────────────────────────────────

COPY centro               FROM '/Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/centros.csv'              DELIMITER ';' CSV HEADER;
COPY escola               FROM '/Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/escolas.csv'              DELIMITER ';' CSV HEADER;
COPY curso                FROM '/Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/cursos.csv'               DELIMITER ';' CSV HEADER;
COPY professor            FROM '/Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/professores.csv'          DELIMITER ';' CSV HEADER;
COPY aluno                FROM '/Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/alunos.csv'               DELIMITER ';' CSV HEADER;
COPY disciplina           FROM '/Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/disciplinas.csv'          DELIMITER ';' CSV HEADER;
COPY prereq               FROM '/Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/prereq.csv'               DELIMITER ';' CSV HEADER;
COPY ministra             FROM '/Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/ministra.csv'             DELIMITER ';' CSV HEADER;
COPY matricula_disciplina FROM '/Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/matricula_disciplina.csv' DELIMITER ';' CSV HEADER;

-- ─── Verificação rápida ───────────────────────────────────────────────────────

SELECT
  'aluno'                AS tabela, COUNT(*) AS linhas FROM aluno
UNION ALL SELECT 'disciplina',               COUNT(*) FROM disciplina
UNION ALL SELECT 'ministra',                 COUNT(*) FROM ministra
UNION ALL SELECT 'matricula_disciplina',     COUNT(*) FROM matricula_disciplina
ORDER BY linhas DESC;
