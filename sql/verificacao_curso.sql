SELECT sigla_curso, nome_curso, escola, tipo_curso
FROM curso
ORDER BY sigla_curso;

SELECT escola, COUNT(*) AS n_professores
FROM professor
GROUP BY escola
ORDER BY escola;

SELECT codigo, nome_disciplina, sigla_curso, carga_horaria
FROM disciplina
WHERE carga_horaria > 100
ORDER BY carga_horaria DESC;

SELECT matricula, nome, ano_ingresso
FROM aluno
WHERE sigla_curso = 'ENS' AND ano_ingresso = 2023;
