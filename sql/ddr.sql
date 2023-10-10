-- calculate ddr
create table temp.ddr as
with stream_length as (
  select
    w.watershed_feature_id,
    sum(st_length(s.geom)) / 1000 as stream_length_km
  from whse_basemapping.fwa_assessment_watersheds_poly w
  left outer join whse_basemapping.fwa_assessment_watersheds_streams_lut lut
    on w.watershed_feature_id = lut.assmnt_watershed_id
  inner join whse_basemapping.fwa_stream_networks_sp s
    on lut.linear_feature_id = s.linear_feature_id
  left outer join whse_basemapping.fwa_waterbodies wb
    on s.waterbody_key = wb.waterbody_key
  where wb.waterbody_type = 'R' OR (wb.waterbody_type IS NULL AND s.edge_type IN (1000,1100,2000,2300))
  group by w.watershed_feature_id
),

drainage_density as (
  select
    w.watershed_feature_id,
    a.elevation_min,
    a.elevation_max,
    a.elevation_max - a.elevation_min as elevation_relief,
    round(l.stream_length_km::numeric, 4) as stream_length_km,
    round((st_area(w.geom) / 1000000)::numeric, 4) as watershed_area_km2,
    l.stream_length_km / ((st_area(w.geom) / 1000000)) as drainage_density
  from whse_basemapping.fwa_assessment_watersheds_poly w
  left outer join temp.fwa_assessment_watersheds_relief a
    on w.watershed_feature_id = a.watershed_feature_id
  left outer join stream_length l
    on a.watershed_feature_id = l.watershed_feature_id
)

select
  watershed_feature_id,
  elevation_min,
  elevation_max,
  elevation_relief,
  stream_length_km,
  watershed_area_km2,
  round(drainage_density::numeric, 4) as drainage_density,
  round((a.drainage_density * elevation_relief)::numeric, 4) as drainage_density_ruggedness,
  case
    when drainage_density * elevation_relief < 2000 then 1
    when drainage_density * elevation_relief >= 2000 and
         drainage_density * elevation_relief < 4000 then 2
    when drainage_density * elevation_relief >= 4000 then 3
  end as drainage_dens_rugged_cls_num
from drainage_density a;