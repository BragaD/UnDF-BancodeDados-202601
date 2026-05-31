EXPLAIN ANALYZE (SELECT p.nome AS nome_professor,
		e.nome_escola
FROM professor p, escola e
WHERE e.id_escola IN(
	SELECT c.id_escola 
	FROM curso c
	WHERE c.id_curso IN
		(SELECT d.id_curso
		FROM disciplina d
		WHERE d.carga_horaria > 150)
	) AND
	e.id_escola = p.id_escola)

EXPLAIN ANALYZE (
	SELECT DISTINCT p.nome AS nome_professor, e.nome_escola
	FROM professor p
	JOIN escola e ON p.id_escola = e.id_escola
	JOIN curso c ON e.id_escola = c.id_escola
	JOIN disciplina d ON c.id_curso = d.id_curso
	WHERE d.carga_horaria > 150
)