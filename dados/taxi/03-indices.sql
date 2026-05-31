-- =============================================================================
-- Demonstração de Índices com Dados Reais — NYC Yellow Taxi (Janeiro 2024)
-- =============================================================================
-- 2.964.606 corridas de táxi em Nova York, janeiro de 2024.
-- Execute conectado ao banco 'nyc_taxi':
--   psql -U postgres -d nyc_taxi -f 03-indices.sql
--
-- O que observar em cada EXPLAIN ANALYZE:
--
--   Seq Scan          → tabela inteira percorrida — O(n)
--   Index Scan        → percorre B-tree + acessa páginas diretamente — O(log n)
--   Bitmap Index Scan → localiza páginas via índice, depois as agrupa e lê
--   Index Only Scan   → resposta sai do índice sem tocar a tabela
--
--   actual time=X..Y  → Y = tempo real em ms até retornar todas as linhas
--   rows=N            → linhas efetivamente retornadas
--   Rows Removed      → linhas lidas mas descartadas (custo desperdiçado)
-- =============================================================================

-- Atualiza as estatísticas da tabela para que o otimizador estime corretamente.
-- O COPY não dispara ANALYZE automaticamente.
ANALYZE viagem;

-- Desabilita paralelismo para tornar a comparação seq × index mais clara.
-- Em produção, o paralelismo é benéfico — mas mascara o custo real do Seq Scan
-- quando o objetivo é demonstrar índices.
SET max_parallel_workers_per_gather = 0;

-- Visão geral do dataset
SELECT COUNT(*)                                   AS total_corridas FROM viagem;
SELECT MIN(pickup_datetime)::DATE                 AS primeiro_dia,
       MAX(pickup_datetime)::DATE                 AS ultimo_dia     FROM viagem;
SELECT COUNT(DISTINCT pu_location_id)             AS zonas_distintas FROM viagem;


-- =============================================================================
-- 1. O PROBLEMA: Seq Scan em tabela com 2,96 MILHÕES de linhas
-- =============================================================================
-- Queremos todas as corridas na hora do rush da manhã de uma segunda-feira.
-- Sem índice, o PostgreSQL não tem como "pular" para as linhas certas.

EXPLAIN ANALYZE
SELECT id, pickup_datetime, fare_amount, total_amount
FROM   viagem
WHERE  pickup_datetime BETWEEN '2024-01-15 07:00:00'
                           AND '2024-01-15 07:59:59';

-- Resultado esperado:
--   Seq Scan on viagem  (rows≈2.964.606 percorridas para retornar ~1.361)
--   Execution Time ≈ 130–180 ms
--
-- O banco leu DOIS MILHÕES E MEIO DE LINHAS para encontrar 1.361.
-- Isso é O(n) — tempo cresce linearmente com o tamanho da tabela.


-- =============================================================================
-- 2. A SOLUÇÃO: Índice B-tree em pickup_datetime
-- =============================================================================

CREATE INDEX idx_viagem_pickup_dt ON viagem (pickup_datetime);

EXPLAIN ANALYZE
SELECT id, pickup_datetime, fare_amount, total_amount
FROM   viagem
WHERE  pickup_datetime BETWEEN '2024-01-15 07:00:00'
                           AND '2024-01-15 07:59:59';

-- Resultado esperado:
--   Index Scan using idx_viagem_pickup_dt
--   Execution Time ≈ 0.5–2 ms   ← ~100–200× mais rápido
--
-- O banco percorreu a B-tree em O(log 2.964.606) ≈ 22 comparações,
-- encontrou as entradas de 07:00–07:59 e acessou diretamente as 1.361 páginas.

-- O mesmo ganho vale para qualquer janela temporal:
EXPLAIN ANALYZE
SELECT DATE(pickup_datetime)  AS dia,
       COUNT(*)               AS corridas,
       SUM(total_amount)      AS receita
FROM   viagem
WHERE  pickup_datetime >= '2024-01-08'
  AND  pickup_datetime <  '2024-01-09'
GROUP  BY 1;

-- ≈ 102.000 corridas em um único dia — o índice faz um range scan eficiente.


-- =============================================================================
-- 3. ALTA CARDINALIDADE: pu_location_id (260 valores distintos)
-- =============================================================================
-- Zona 132 = Aeroporto JFK — origem frequente, ~145 mil corridas (5% da tabela).

-- Sem índice (executar ANTES do CREATE INDEX abaixo):
EXPLAIN ANALYZE
SELECT COUNT(*), ROUND(AVG(fare_amount), 2) AS tarifa_media
FROM   viagem
WHERE  pu_location_id = 132;

-- Com 5% de seletividade, o otimizador pode preferir Seq Scan mesmo com índice.
-- Para zonas raras, a diferença é dramática:
EXPLAIN ANALYZE
SELECT id, pickup_datetime, fare_amount
FROM   viagem
WHERE  pu_location_id = 1;   -- EWR / Newark: apenas 295 corridas (0,01%)

-- Esperado: Index Scan (ou o plano já usa o índice criado na seção 2).


CREATE INDEX idx_viagem_pu_loc ON viagem (pu_location_id);

-- Com índice, a busca por zona rara é instantânea:
EXPLAIN ANALYZE
SELECT id, pickup_datetime, fare_amount
FROM   viagem
WHERE  pu_location_id = 1;
-- Execution Time ≈ 0,1–0,5 ms vs. >100 ms do Seq Scan


-- =============================================================================
-- 4. BAIXA CARDINALIDADE: o índice que o otimizador IGNORA
-- =============================================================================
-- payment_type tem apenas 5 valores. Com 78% das linhas sendo type=1,
-- o índice causaria mais I/O aleatório do que um Seq Scan linear.

EXPLAIN ANALYZE
SELECT COUNT(*), ROUND(AVG(tip_amount), 2) AS gorjeta_media
FROM   viagem
WHERE  payment_type = 1;   -- 2.319.046 linhas (78%)

CREATE INDEX idx_viagem_payment ON viagem (payment_type);

EXPLAIN ANALYZE
SELECT COUNT(*), ROUND(AVG(tip_amount), 2) AS gorjeta_media
FROM   viagem
WHERE  payment_type = 1;

-- O plano provàvelmente AINDA usa Seq Scan — o otimizador calculou que
-- acessar 78% das linhas via índice seria mais lento que ler tudo de uma vez.

-- Para o valor raro (contestação: ~1,6% das linhas), o índice é usado:
EXPLAIN ANALYZE
SELECT id, fare_amount, total_amount
FROM   viagem
WHERE  payment_type = 4;   -- ~46.000 linhas (1,6%)


-- =============================================================================
-- 5. ÍNDICE COMPOSTO — filtra por duas colunas ao mesmo tempo
-- =============================================================================
-- Corridas de dinheiro partindo do JFK.

-- Com apenas idx_viagem_pu_loc, o plano usa o índice em pu_location_id
-- e filtra payment_type em memória:
EXPLAIN ANALYZE
SELECT id, fare_amount, tip_amount
FROM   viagem
WHERE  pu_location_id = 132
  AND  payment_type   = 2;

-- Com índice composto, ambas as condições são resolvidas dentro da B-tree:
CREATE INDEX idx_viagem_loc_pay ON viagem (pu_location_id, payment_type);

EXPLAIN ANALYZE
SELECT id, fare_amount, tip_amount
FROM   viagem
WHERE  pu_location_id = 132
  AND  payment_type   = 2;

-- Regra do prefixo: o índice composto (a, b) serve para:
--   WHERE a = ?            ← usa o prefixo
--   WHERE a = ? AND b = ?  ← usa ambas as colunas
-- Mas NÃO para:
--   WHERE b = ?            ← não usa; a coluna 'a' precisa estar no filtro

EXPLAIN ANALYZE SELECT COUNT(*) FROM viagem WHERE pu_location_id = 132;  -- usa prefixo ✓
EXPLAIN ANALYZE SELECT COUNT(*) FROM viagem WHERE payment_type   = 2;    -- não usa composto


-- =============================================================================
-- 6. ÍNDICE PARCIAL — indexa só um subconjunto das linhas
-- =============================================================================
-- Corridas com gorjeta: ~1,7 M de linhas (57% da tabela).
-- Um índice parcial só para esse subconjunto ocupa menos espaço e é mais rápido
-- para consultas que já filtram por tip_amount > 0.

CREATE INDEX idx_viagem_gorjeta ON viagem (tip_amount)
WHERE  tip_amount > 0;

EXPLAIN ANALYZE
SELECT id, pickup_datetime, tip_amount
FROM   viagem
WHERE  tip_amount > 3.00;   -- corridas com gorjeta acima de $3

-- Corridas suspeitas (fare_amount negativo — ~37.000 linhas, 1,2%):
CREATE INDEX idx_viagem_fare_neg ON viagem (id, fare_amount)
WHERE  fare_amount < 0;

EXPLAIN ANALYZE
SELECT id, pickup_datetime, fare_amount
FROM   viagem
WHERE  fare_amount < 0;
-- O índice parcial tem apenas ~37.000 entradas — muito menor que o total.


-- =============================================================================
-- 7. COVERING INDEX — Index Only Scan (sem tocar a tabela)
-- =============================================================================
-- VACUUM atualiza o mapa de visibilidade, permitindo Index Only Scan.
-- Sem ele, o PostgreSQL ainda acessa o heap para verificar linhas recentes.
VACUUM ANALYZE viagem;
-- Quando todas as colunas da consulta estão no índice (via INCLUDE),
-- o PostgreSQL responde sem acessar a tabela principal.

CREATE INDEX idx_viagem_loc_dt_fare
    ON viagem (pu_location_id, pickup_datetime)
    INCLUDE (fare_amount, total_amount);

EXPLAIN ANALYZE
SELECT pickup_datetime, fare_amount, total_amount
FROM   viagem
WHERE  pu_location_id = 132
  AND  pickup_datetime >= '2024-01-20';

-- Procure "Index Only Scan" — nenhuma página da tabela foi lida.
-- A resposta saiu inteiramente do índice, que é muito menor que a tabela.


-- =============================================================================
-- 8. TAMANHO DOS ÍNDICES vs. TABELA
-- =============================================================================
SELECT
    indexname                                            AS indice,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS tamanho
FROM   pg_indexes
WHERE  schemaname = 'public'
  AND  tablename  = 'viagem'
ORDER  BY pg_relation_size(indexname::regclass) DESC;

SELECT
    'tabela (dados)'    AS objeto,
    pg_size_pretty(pg_relation_size('viagem'))              AS tamanho
UNION ALL
SELECT
    'todos os índices',
    pg_size_pretty(
        pg_total_relation_size('viagem') - pg_relation_size('viagem')
    )
UNION ALL
SELECT
    'total (dados + índices)',
    pg_size_pretty(pg_total_relation_size('viagem'));

-- Índices ocupam espaço em disco e precisam ser mantidos atualizados
-- a cada INSERT / UPDATE / DELETE — o tradeoff de quem usa muitos índices.


-- =============================================================================
-- 9. IMPACTO EM ESCRITAS: índices tornam INSERT mais lento
-- =============================================================================
-- Registra o tempo de uma inserção em massa COM todos os índices presentes.

\timing on

INSERT INTO viagem (vendor_id, pickup_datetime, dropoff_datetime,
                    pu_location_id, do_location_id, fare_amount, total_amount)
SELECT 1::SMALLINT,
       '2024-01-31 23:00:00'::timestamp + (n || ' seconds')::interval,
       '2024-01-31 23:20:00'::timestamp + (n || ' seconds')::interval,
       (50 + n % 200)::smallint,
       (100 + n % 200)::smallint,
       (10 + n % 50)::numeric,
       (15 + n % 50)::numeric
FROM   generate_series(1, 50000) t(n);

-- Agora compara sem índices:
DROP INDEX idx_viagem_pickup_dt;
DROP INDEX idx_viagem_pu_loc;
DROP INDEX idx_viagem_payment;
DROP INDEX idx_viagem_loc_pay;
DROP INDEX idx_viagem_gorjeta;
DROP INDEX idx_viagem_fare_neg;
DROP INDEX idx_viagem_loc_dt_fare;

INSERT INTO viagem (vendor_id, pickup_datetime, dropoff_datetime,
                    pu_location_id, do_location_id, fare_amount, total_amount)
SELECT 2::SMALLINT,
       '2024-01-31 23:00:00'::timestamp + (n || ' seconds')::interval,
       '2024-01-31 23:20:00'::timestamp + (n || ' seconds')::interval,
       (50 + n % 200)::smallint,
       (100 + n % 200)::smallint,
       (10 + n % 50)::numeric,
       (15 + n % 50)::numeric
FROM   generate_series(1, 50000) t(n);

\timing off

-- Em cargas massivas de dados (ETL, import inicial):
--   1. DROP INDEX em todos os índices secundários
--   2. COPY / INSERT em massa
--   3. REINDEX TABLE viagem  (recria todos os índices de uma vez)
-- Essa sequência é significativamente mais rápida que inserir com índices ativos.
