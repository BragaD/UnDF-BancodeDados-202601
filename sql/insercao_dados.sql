TRUNCATE matricula_disciplina, ministra, disciplina,
         aluno, professor, curso, escola, centro CASCADE;

INSERT INTO centro (centro, nome_centro) VALUES
    ('COCHCMA', 'CIÊNCIAS HUMANAS, CIDADANIA E MEIO AMBIENTE'),
    ('COEMAG',  'CENTRO DE EDUCAÇÃO, MAGISTÉRIO E ARTES'),
    ('COETI',   'CENTRO DE ENGENHARIAS, TECNOLOGIA E INOVAÇÃO');

INSERT INTO escola (escola, nome_escola, centro) VALUES
    ('ESG',   'Escola Superior de Gestão',                               'COCHCMA'),
    ('EEMA',  'Escola de Educação, Magistério e Arte',                   'COEMAG'),
    ('ESETI', 'Escola Superior de Engenharias, Tecnologia e Inovação',   'COETI');

INSERT INTO curso (sigla_curso, nome_curso, escola, n_semestres, carga_horaria, tipo_curso) VALUES
    ('ENS', 'Engenharia de Software', 'ESETI', 8, 3200, 'bacharelado'),
    ('ECO', 'Ciências Econômicas',    'ESG',   8, 3000, 'bacharelado'),
    ('PED', 'Pedagogia',              'EEMA',  8, 3410, 'licenciatura');

INSERT INTO professor (matricula_prof, nome, escola, ch_semanal, salario) VALUES
    ('PROF20230005', 'Eduarda Souza',   'EEMA',  20, 3200),
    ('PROF20230006', 'Felipe Araujo',   'EEMA',  40, 6400),
    ('PROF20230031', 'Gustavo Costa',   'ESETI', 20, 3300),
    ('PROF20230032', 'Helena Carvalho', 'ESETI', 40, 6700),
    ('PROF20230033', 'Igor Melo',       'ESETI', 20, 3100),
    ('PROF20230042', 'Bruno Teixeira',  'ESG',   40, 6500),
    ('PROF20230043', 'Carla Pinto',     'ESG',   40, 6600);

INSERT INTO aluno (matricula, nome, sigla_curso, ano_ingresso) VALUES
    ('2023007001', 'Beatriz Carvalho', 'ECO', 2023),
    ('2023007002', 'Lucas Santos',     'ECO', 2023),
    ('2024007001', 'Gabriel Ribeiro',  'ECO', 2024),
    ('2024007002', 'Fernanda Martins', 'ECO', 2024),
    ('2025007001', 'Rodrigo Lima',     'ECO', 2025),
    ('2025007002', 'Camila Teixeira',  'ECO', 2025),
    ('2023002001', 'Matheus Silva',    'ENS', 2023),
    ('2023002002', 'Larissa Araújo',   'ENS', 2023),
    ('2024002001', 'Pedro Carvalho',   'ENS', 2024),
    ('2024002002', 'Isabela Freitas',  'ENS', 2024),
    ('2025002001', 'Diego Correia',    'ENS', 2025),
    ('2025002002', 'Juliana Nunes',    'ENS', 2025),
    ('2023009001', 'Amanda Moreira',   'PED', 2023),
    ('2023009002', 'Thiago Gomes',     'PED', 2023),
    ('2024009001', 'Carolina Lima',    'PED', 2024),
    ('2024009002', 'Rafael Costa',     'PED', 2024),
    ('2025009001', 'Vinícius Pereira', 'PED', 2025),
    ('2025009002', 'Letícia Souza',    'PED', 2025);

INSERT INTO disciplina (codigo, nome_disciplina, sigla_curso, semestre, carga_horaria) VALUES
    ('ECO-201', 'História Econômica Geral',            'ECO', 2,  75),
    ('ECO-202', 'Culturas Digitais',                   'ECO', 2,  60),
    ('ECO-401', 'Microeconomia 2',                     'ECO', 4,  75),
    ('ECO-402', 'Macroeconomia 2',                     'ECO', 4,  95),
    ('ECO-601', 'Economia Brasileira',                 'ECO', 6,  75),
    ('ECO-602', 'Orçamento e Finanças Públicas',       'ECO', 6,  75),
    ('ECO-801', 'Monografia',                          'ECO', 8, 100),
    ('ECO-802', 'Desenvolvimento Econômico',           'ECO', 8,  90),
    ('ENS-201', 'Bases da Engenharia de Software 2',                   'ENS', 2, 150),
    ('ENS-202', 'Projeto Aplicado 2 (site WEB)',                       'ENS', 2, 120),
    ('ENS-401', 'Bases da Engenharia de Software 4',                   'ENS', 4, 180),
    ('ENS-402', 'Projeto Aplicado 4 (blockchain)',                     'ENS', 4, 120),
    ('ENS-601', 'Bases da Engenharia de Software 6',                   'ENS', 6, 150),
    ('ENS-602', 'Projeto Aplicado 6 (Machine Learning)',               'ENS', 6, 120),
    ('ENS-801', 'Bases da Engenharia de Software 8',                   'ENS', 8, 100),
    ('ENS-802', 'Projeto Aplicado 8 (Sistema em Tempo Real)',          'ENS', 8, 160),
    ('PED-203', 'Desenvolvimento Humano',              'PED', 2,  60),
    ('PED-204', 'Didática Geral',                      'PED', 2,  60),
    ('PED-403', 'Eletiva I',                           'PED', 4,  80),
    ('PED-404', 'Fundamentos e Orientações Metodológicas - Ed. Infantil - BNCC', 'PED', 4, 80),
    ('PED-603', 'Eletiva II',                          'PED', 6,  80),
    ('PED-604', 'Educação do Campo, Indígena e Quilombola', 'PED', 6, 40),
    ('PED-803', 'Tecnologia Educacional - Design',     'PED', 8,  60),
    ('PED-804', 'Estatística Aplicada',                'PED', 8,  50);

/* Inserção de dados na tabela ministra */
/* utiliza leitor de csv do postgreSQL para inserir os dados do arquivo csv localizado em /Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/amostra/ministra_amostra.csv */

COPY ministra (cod_disciplina, ano, semestre, turma, matricula_prof, horario, sala)
FROM '/Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/amostra/ministra_amostra.csv' DELIMITER ';' CSV HEADER;

SELECT * FROM ministra

COPY matricula_disciplina (cod_disciplina, ano, semestre, turma, cod_matricula, nota)
FROM '/Users/douglasbraga/Documents/UnDF/202601/BasesIV_EngSoft_BD/dados/amostra/matricula_disciplina_amostra.csv' DELIMITER ';' CSV HEADER;
