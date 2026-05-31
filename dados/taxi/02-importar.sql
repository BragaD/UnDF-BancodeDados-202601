-- =============================================================================
-- Importação — NYC Yellow Taxi (Janeiro 2024) via COPY FROM
-- =============================================================================
-- Pré-requisito: banco 'nyc_taxi' e tabela 'viagem' criados por 01-ddl.sql
--
-- Como executar (substitua o caminho pelo caminho real do arquivo no seu sistema):
--
--   Linux / macOS:
--     psql -U postgres -d nyc_taxi \
--       -v csvpath="$(pwd)/dados/taxi/viagens_taxi_jan2024.csv" \
--       -f dados/taxi/02-importar.sql
--
--   Windows (PowerShell):
--     psql -U postgres -d nyc_taxi `
--       -v csvpath="$PWD\dados\taxi\viagens_taxi_jan2024.csv" `
--       -f dados\taxi\02-importar.sql
--
-- A variável :csvpath é substituída pelo psql antes de enviar ao servidor.
-- =============================================================================

-- Remove dados de carga anterior (seguro re-executar)
TRUNCATE viagem RESTART IDENTITY;

-- Importa o CSV diretamente para a tabela
COPY viagem (
    vendor_id,
    pickup_datetime,
    dropoff_datetime,
    passenger_count,
    trip_distance,
    ratecode_id,
    store_fwd_flag,
    pu_location_id,
    do_location_id,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    congestion_surcharge,
    airport_fee
)
FROM :'csvpath'
WITH (FORMAT CSV, HEADER true, NULL 'NULL');

-- Verificação após importação
SELECT COUNT(*)                   AS total_corridas FROM viagem;
SELECT MIN(pickup_datetime)::DATE AS primeiro_dia,
       MAX(pickup_datetime)::DATE AS ultimo_dia      FROM viagem;
