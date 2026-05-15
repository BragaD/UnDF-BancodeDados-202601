-- =============================================================
-- Parte 3 — Carga de Dados
-- Atividade Prática 1 — Bases de Dados IV / UnDF 2026.1
-- =============================================================
-- Ordem de inserção importa: tabelas pai devem ser populadas antes das filhas.
-- centro → escola → curso → professor → aluno → disciplina → prereq → ministra → matricula_disciplina

-- Limpa todos os dados em ordem inversa (CASCADE propaga para filhas)
TRUNCATE matricula_disciplina, ministra, prereq, disciplina,
         aluno, professor, curso, escola, centro CASCADE;

-- ---------------------------------------------------------------
-- centro (3 linhas) — INSERT INTO: tabela pequena, dados fixos
-- ---------------------------------------------------------------
INSERT INTO centro (id_centro, sigla, nome_centro) VALUES
    (1, 'COCHCMA', 'Ciências Humanas, Cidadania e Meio Ambiente'),
    (2, 'COEMAG',  'Centro de Educação, Magistério e Artes'),
    (3, 'COETI',   'Centro de Engenharias, Tecnologia e Inovação');

-- ---------------------------------------------------------------
-- escola (3 linhas) — FK id_centro referencia centro
-- id_escola: prefixo = id_centro + sequencial
-- ---------------------------------------------------------------
INSERT INTO escola (id_escola, sigla, nome_escola, id_centro) VALUES
    (11, 'ESG',   'Escola Superior de Gestão',                              1),
    (21, 'EEMA',  'Escola de Educação, Magistério e Arte',                  2),
    (31, 'ESETI', 'Escola Superior de Engenharias, Tecnologia e Inovação',  3);

-- ---------------------------------------------------------------
-- curso (3 linhas) — FK id_escola referencia escola
-- ---------------------------------------------------------------
INSERT INTO curso (id_curso, sigla_curso, nome_curso, id_escola,
                   n_semestres, carga_horaria, tipo_curso) VALUES
    (111, 'ECO', 'Ciências Econômicas',    11, 8, 3000, 'bacharelado'),
    (211, 'PED', 'Pedagogia',              21, 8, 3410, 'licenciatura'),
    (311, 'ENS', 'Engenharia de Software', 31, 8, 3200, 'bacharelado');

-- ---------------------------------------------------------------
-- professor (7 linhas) — FK id_escola referencia escola
-- id_prof: id_escola(2d) + ch_semanal(2d) + seq(4d)
-- ---------------------------------------------------------------
INSERT INTO professor (id_prof, nome, id_escola, ch_semanal, salario) VALUES
    (11400001, 'Bruno Teixeira',  11, 40, 6500.00),
    (11400002, 'Carla Pinto',     11, 40, 6600.00),
    (21200001, 'Eduarda Souza',   21, 20, 3200.00),
    (21400002, 'Felipe Araujo',   21, 40, 6400.00),
    (31200001, 'Gustavo Costa',   31, 20, 3300.00),
    (31400002, 'Helena Carvalho', 31, 40, 6700.00),
    (31200003, 'Igor Melo',       31, 20, 3100.00);

-- ---------------------------------------------------------------
-- Tabelas grandes — COPY a partir dos CSVs em dados/amostra/
-- Ajuste o caminho absoluto conforme necessário.
-- ---------------------------------------------------------------

-- aluno (18 linhas) — id_aluno: ano(4d) + id_curso(3d) + seq(3d)
COPY aluno (id_aluno, nome, id_curso, ano_ingresso)
FROM '/Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/amostra/alunos_amostra.csv'
DELIMITER ';' CSV HEADER;

-- disciplina (24 linhas) — id_disciplina: id_curso(3d) + semestre(2d) + seq(2d)
COPY disciplina (id_disciplina, nome_disciplina, id_curso, semestre, carga_horaria)
FROM '/Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/amostra/disciplinas_amostra.csv'
DELIMITER ';' CSV HEADER;

-- prereq (16 linhas) — pares (id_disciplina, id_prereq)
COPY prereq (id_disciplina, id_prereq)
FROM '/Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/amostra/prereq_amostra.csv'
DELIMITER ';' CSV HEADER;

-- ministra (36 linhas) — turmas ofertadas
COPY ministra (id_disciplina, ano, semestre, turma, id_prof, horario, sala)
FROM '/Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/amostra/ministra_amostra.csv'
DELIMITER ';' CSV HEADER;

-- matricula_disciplina (56 linhas) — matrículas de alunos em turmas
COPY matricula_disciplina (id_disciplina, ano, semestre, turma, id_aluno, nota, aprovado)
FROM '/Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/amostra/matricula_disciplina_amostra.csv'
DELIMITER ';' CSV HEADER;
