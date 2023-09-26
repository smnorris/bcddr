#!/bin/bash
set -euxo pipefail

DATABASE_URL=postgresql://postgres@localhost:5432/bcfishpass_dev
PSQL="psql $DATABASE_URL -v ON_ERROR_STOP=1"
WSGS=$($PSQL -AXt -c "SELECT watershed_group_code FROM whse_basemapping.fwa_watershed_groups_poly order by watershed_group_code")
DEM=~/data/bc/raster/dem/bc_dem.tif

$PSQL -c "CREATE SCHEMA IF NOT EXISTS temp"
$PSQL -c "DROP TABLE IF EXISTS temp.fwa_assessment_watersheds_relief"
$PSQL -c "CREATE TABLE temp.fwa_assessment_watersheds_relief (watershed_feature_id integer PRIMARY KEY, watershed_group_code text, elevation_max numeric, elevation_min numeric)"

# load relief
parallel --no-run-if-empty \
  "echo 'Processing {1} '; \
  $PSQL -X -t -v wsg={1} <<< \"SELECT
    json_build_object(
      'type', 'FeatureCollection',
      'features', json_agg(ST_AsGeoJSON(t.*)::json)
    )
  FROM
    (
      SELECT
        watershed_feature_id,
        watershed_group_code,
        geom
      FROM whse_basemapping.fwa_assessment_watersheds_poly
      WHERE watershed_group_code = :'wsg'
    ) as t\" | \
    rio zonalstats \
        -r $DEM \
        --all-touched \
        --prefix 'elevation_' | \
    jq '.features[].properties | [.watershed_feature_id, .watershed_group_code, .elevation_max, .elevation_min]' | \
    jq -r --slurp '.[] | @csv' | \
    $PSQL -c \"\copy temp.fwa_assessment_watersheds_relief FROM STDIN delimiter ',' csv\"" ::: $WSGS

# calculate ddr
$PSQL --csv -f sql/ddr.sql > ddr.csv