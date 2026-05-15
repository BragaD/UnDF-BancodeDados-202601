-- =============================================================
-- Parte 5 — Exercícios de Manipulação e Restrições
-- Atividade Prática 1 — Bases de Dados IV / UnDF 2026.1
-- =============================================================
-- Este arquivo pressupõe que DDL_curso.sql e insercao_dados.sql
-- já foram executados com sucesso.


-- =============================================================
-- Exercício 1 — Inspecionando a estrutura do banco
-- =============================================================

-- a) Lista todas as tabelas do banco no schema público
-- information_schema.tables é uma visão padrão SQL com metadados do banco
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- b) Colunas da tabela professor: nome, tipo e se aceita NULL
-- is_nullable = 'NO' indica restrição NOT NULL
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'professor'
ORDER BY ordinal_position;

-- c) DESAFIO: todas as constraints das tabelas com nome e tipo
-- JOIN necessário porque table_constraints não lista as colunas diretamente
SELECT tc.table_name, tc.constraint_name, tc.constraint_type,
       kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
 AND tc.table_schema    = kcu.table_schema
WHERE tc.table_schema = 'public'
ORDER BY tc.table_name, tc.constraint_type;


-- =============================================================
-- Exercício 2 — Adicionando restrição de nota válida
-- =============================================================

-- a) Sem restrição, o banco aceita nota = 15.0 (inválida pela regra de negócio)
INSERT INTO matricula_disciplina
    (id_disciplina, ano, semestre, turma, id_aluno, nota, aprovado)
VALUES (1110201, 2025, 2, 1, 2024111001, 15.0, 1);

-- Confirma a inserção inválida
SELECT id_disciplina, ano, semestre, turma, id_aluno, nota
FROM matricula_disciplina
WHERE id_aluno = 2024111001 AND nota = 15.0;

-- Remove o registro inválido antes de criar a restrição
DELETE FROM matricula_disciplina
WHERE id_aluno = 2024111001 AND nota = 15.0;

-- b) Adiciona CHECK: nota deve estar entre 0 e 10
-- ALTER TABLE adiciona restrição sem recriar a tabela
ALTER TABLE matricula_disciplina
ADD CONSTRAINT chk_nota CHECK (nota >= 0 AND nota <= 10);

-- c) Tentativas inválidas — ambas devem gerar erro de violação do chk_nota
-- Nota acima de 10:
INSERT INTO matricula_disciplina
    (id_disciplina, ano, semestre, turma, id_aluno, nota, aprovado)
VALUES (1110201, 2025, 2, 1, 2024111001, 15.0, 1);

-- Nota negativa:
INSERT INTO matricula_disciplina
    (id_disciplina, ano, semestre, turma, id_aluno, nota, aprovado)
VALUES (1110201, 2025, 2, 1, 2024111001, -1.0, 0);

-- d) Nota válida — deve ser aceita normalmente
INSERT INTO matricula_disciplina
    (id_disciplina, ano, semestre, turma, id_aluno, nota, aprovado)
VALUES (1110201, 2025, 2, 1, 2024111001, 7.5, 1);


-- =============================================================
-- Exercício 3 — Adicionando coluna de nível de formação
-- =============================================================

-- a) Adiciona coluna com CHECK limitando os valores aceitos
-- ALTER TABLE ADD COLUMN não afeta linhas existentes (ficam NULL)
ALTER TABLE professor
ADD COLUMN nivel_formacao VARCHAR(20)
    CHECK (nivel_formacao IN ('especializacao', 'mestrado', 'doutorado'));

-- b) Verifica estado atual — todos aparecerão como NULL
-- NULL porque a coluna foi criada sem DEFAULT e sem NOT NULL
SELECT id_prof, nome, nivel_formacao FROM professor ORDER BY id_prof;

-- c) Atualiza o nível de formação de cada professor
UPDATE professor
SET nivel_formacao = 'doutorado'
WHERE id_prof IN (11400001, 21200001, 31200001, 31400002);

UPDATE professor
SET nivel_formacao = 'mestrado'
WHERE id_prof IN (11400002, 21400002);

UPDATE professor
SET nivel_formacao = 'especializacao'
WHERE id_prof = 31200003;

-- Confirma os valores após as atualizações
SELECT id_prof, nome, nivel_formacao FROM professor ORDER BY id_prof;

-- d) Valor inválido — deve falhar com erro de violação de CHECK
UPDATE professor
SET nivel_formacao = 'graduacao'
WHERE id_prof = 31200003;


-- =============================================================
-- Exercício 4 — Inserindo curso com escola inexistente
-- =============================================================

-- a) Tentativa com id_escola = 99 (não existe) — deve falhar com erro de FK
INSERT INTO curso (id_curso, sigla_curso, nome_curso, id_escola,
                   n_semestres, carga_horaria, tipo_curso)
VALUES (411, 'DIR', 'Direito', 99, 10, 4000, 'bacharelado');

-- c) Inserção correta: criar a escola antes e depois o curso
-- Primeiro a escola (pai da FK)
INSERT INTO escola (id_escola, sigla, nome_escola, id_centro)
VALUES (99, 'EJUR', 'Escola de Ciências Jurídicas', 1);

-- Agora o curso pode referenciar a escola recém-criada
INSERT INTO curso (id_curso, sigla_curso, nome_curso, id_escola,
                   n_semestres, carga_horaria, tipo_curso)
VALUES (411, 'DIR', 'Direito', 99, 10, 4000, 'bacharelado');

-- Confirma com JOIN para mostrar o nome da escola
SELECT c.id_curso, c.sigla_curso, c.nome_curso, e.sigla AS escola
FROM curso c
JOIN escola e ON c.id_escola = e.id_escola
ORDER BY c.id_curso;


-- =============================================================
-- Exercício 5 — Violação de chave primária e de unicidade
-- =============================================================

-- a) id_centro = 1 já existe — viola a PRIMARY KEY
INSERT INTO centro (id_centro, sigla, nome_centro)
VALUES (1, 'CNOVO', 'Centro Novo');

-- b) id_centro diferente, mas sigla 'COETI' já existe — viola UNIQUE
INSERT INTO centro (id_centro, sigla, nome_centro)
VALUES (9, 'COETI', 'Outro Centro');

-- Erro a) referencia "centro_pkey"; erro b) referencia "centro_sigla_key".
-- Ambos são "duplicate key", mas violam constraints diferentes.


-- =============================================================
-- Exercício 6 — Violação de NOT NULL
-- =============================================================

-- a) Inserção sem nome — deve falhar com "null value in column nome"
INSERT INTO aluno (id_aluno, nome, id_curso, ano_ingresso)
VALUES (9999999999, NULL, 311, 2026);

-- c) Inserção correta seguindo o padrão hierárquico de id_aluno:
-- id_aluno = ano(4d) × 10^6 + id_curso(3d) × 10^3 + seq
-- 2026 × 10^6 + 311 × 10^3 + 1 = 2026311001
INSERT INTO aluno (id_aluno, nome, id_curso, ano_ingresso)
VALUES (2026311001, 'Mariana Andrade', 311, 2026);

-- Confirma
SELECT id_aluno, nome, id_curso, ano_ingresso
FROM aluno WHERE id_aluno = 2026311001;


-- =============================================================
-- Exercício 7 — Excluindo professor com turmas ativas
-- =============================================================

-- a) DELETE direto — deve falhar porque ministra.id_prof referencia professor.id_prof
DELETE FROM professor WHERE id_prof = 31200001;

-- b) Exclusão correta em cascata manual (ordem inversa das FKs):

-- 1. Remove matrículas das turmas do professor
DELETE FROM matricula_disciplina
WHERE (id_disciplina, ano, semestre, turma) IN (
    SELECT id_disciplina, ano, semestre, turma
    FROM ministra
    WHERE id_prof = 31200001
);

-- 2. Remove as turmas do professor
DELETE FROM ministra WHERE id_prof = 31200001;

-- 3. Agora o professor pode ser removido sem violar FK
DELETE FROM professor WHERE id_prof = 31200001;

-- Confirma que o professor foi removido
SELECT * FROM professor WHERE id_prof = 31200001;


-- =============================================================
-- Exercício 8 — CHECK em INSERT e UPDATE
-- =============================================================

-- a) carga_horaria = 0 deve falhar (CHECK: carga_horaria > 0)
INSERT INTO disciplina (id_disciplina, nome_disciplina, id_curso, semestre, carga_horaria)
VALUES (3119999, 'Disciplina Teste', 311, 1, 0);

-- carga_horaria negativa também deve falhar
INSERT INTO disciplina (id_disciplina, nome_disciplina, id_curso, semestre, carga_horaria)
VALUES (3119998, 'Disciplina Teste 2', 311, 1, -60);

-- c) UPDATE com carga negativa também é bloqueado pelo CHECK
-- A constraint vale para qualquer operação que altere o valor da coluna
UPDATE disciplina
SET carga_horaria = -10
WHERE id_disciplina = 3110201;


-- =============================================================
-- Exercício 9 (BÔNUS) — Pré-requisito circular
-- =============================================================

-- a) Consulta os pré-requisitos de ENS-0401 (3110401) e ENS-0601 (3110601)
-- Dois JOINs na mesma tabela disciplina: d1 = disciplina, d2 = seu pré-requisito
SELECT p.id_disciplina,
       d1.nome_disciplina AS disciplina,
       p.id_prereq,
       d2.nome_disciplina AS prereq
FROM prereq p
JOIN disciplina d1 ON p.id_disciplina = d1.id_disciplina
JOIN disciplina d2 ON p.id_prereq     = d2.id_disciplina
WHERE p.id_disciplina IN (3110401, 3110601)
ORDER BY p.id_disciplina;

-- b) Tentativa de criar ciclo: ENS-0401 exige ENS-0601 (que já exige ENS-0401)
-- O banco ACEITA porque prereq só tem restrições de PK e FK, sem detecção de ciclo
INSERT INTO prereq (id_disciplina, id_prereq)
VALUES (3110401, 3110601);

-- e) Remove o pré-requisito circular criado acima
DELETE FROM prereq
WHERE id_disciplina = 3110401 AND id_prereq = 3110601;

-- Confirma que ENS-0401 voltou ao estado original (só exige ENS-0201)
SELECT p.id_disciplina, d1.nome_disciplina AS disciplina,
       p.id_prereq,     d2.nome_disciplina AS prereq
FROM prereq p
JOIN disciplina d1 ON p.id_disciplina = d1.id_disciplina
JOIN disciplina d2 ON p.id_prereq     = d2.id_disciplina
WHERE p.id_disciplina = 3110401;
