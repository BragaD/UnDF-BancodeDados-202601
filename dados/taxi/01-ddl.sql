-- =============================================================================
-- NYC Yellow Taxi Trip Data — Janeiro 2024
-- Fonte: NYC Taxi & Limousine Commission (TLC)
--        https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page
--
-- 2.964.606 corridas de táxi registradas em janeiro de 2024.
-- Usado para demonstrar o impacto de índices em tabelas com milhões de linhas.
--
-- Como executar:
--   psql -U postgres -d postgres -f 01-ddl.sql
-- =============================================================================

-- Encerra conexões ativas ao banco (caso já exista de uma execução anterior)
SELECT pg_terminate_backend(pid)
FROM   pg_stat_activity
WHERE  datname = 'nyc_taxi'
  AND  pid <> pg_backend_pid();

DROP DATABASE IF EXISTS nyc_taxi;
CREATE DATABASE nyc_taxi;

-- Conecte ao banco recém-criado para criar a tabela:
--   \c nyc_taxi          (psql interativo)
-- ou execute o bloco abaixo como segundo passo:
--   psql -U postgres -d nyc_taxi -f 01-ddl.sql    (na prática usa a flag -d)
--
-- O psql pode mudar de banco com o meta-comando \connect (ou \c):
\connect nyc_taxi

-- =============================================================================
-- Tabela principal
-- =============================================================================
CREATE TABLE viagem (
    id                    SERIAL        PRIMARY KEY,

    -- Fornecedor (1 = Creative Mobile Technologies, 2 = VeriFone)
    vendor_id             SMALLINT,

    -- Horários de embarque e desembarque
    pickup_datetime       TIMESTAMP     NOT NULL,
    dropoff_datetime      TIMESTAMP,

    -- Número de passageiros informado pelo motorista (pode ser NULL)
    passenger_count       SMALLINT,

    -- Distância percorrida em milhas (inclui outliers de teste no dataset)
    trip_distance         NUMERIC(10,3),

    -- Tarifa aplicada: 1=padrão 2=JFK 3=Newark 4=Nassau/Westchester
    --                  5=negociada 6=grupo 99=inválido
    ratecode_id           SMALLINT,

    -- Corrida registrada localmente e enviada depois? (Y/N)
    store_fwd_flag        VARCHAR(1),

    -- Zonas de embarque e desembarque (1–263, conforme mapa TLC)
    pu_location_id        SMALLINT      NOT NULL,
    do_location_id        SMALLINT      NOT NULL,

    -- Forma de pagamento: 1=cartão 2=dinheiro 3=sem cobrança
    --                     4=contestação 0=desconhecido
    payment_type          SMALLINT,

    -- Valores em USD
    fare_amount           NUMERIC(10,2),
    extra                 NUMERIC(8,2),
    mta_tax               NUMERIC(8,2),
    tip_amount            NUMERIC(8,2),
    tolls_amount          NUMERIC(8,2),
    improvement_surcharge NUMERIC(8,2),
    total_amount          NUMERIC(10,2),
    congestion_surcharge  NUMERIC(8,2),
    airport_fee           NUMERIC(8,2)
);
