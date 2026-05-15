-- =============================================================
-- Parte 4 — Verificação dos Dados
-- Atividade Prática 1 — Bases de Dados IV / UnDF 2026.1
-- =============================================================
-- Execute após a carga para confirmar que os dados estão corretos.

-- Todos os cursos (esperado: 3 registros)
SELECT id_curso, sigla_curso, nome_curso, id_escola, tipo_curso
FROM curso
ORDER BY id_curso;

-- Professores por escola (esperado: 11→2, 21→2, 31→3)
SELECT id_escola, COUNT(*) AS n_professores
FROM professor
GROUP BY id_escola
ORDER BY id_escola;

-- Disciplinas com carga horária acima de 100h (esperado: 7 registros, todas de ENS)
SELECT id_disciplina, nome_disciplina, id_curso, carga_horaria
FROM disciplina
WHERE carga_horaria > 100
ORDER BY carga_horaria DESC;

-- Alunos de Engenharia de Software ingressantes em 2023 (esperado: 2 registros)
SELECT id_aluno, nome, ano_ingresso
FROM aluno
WHERE id_curso = 311 AND ano_ingresso = 2023;
