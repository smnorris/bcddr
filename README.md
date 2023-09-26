# Drainage Density Ruggedness (DDR)

Melton, 1957: the dimensionless product of drainage density (stream length per unit area – km/km2) and total elevation relief.

Schumm, 1956: the difference between the highest and lowest points in the watershed, relative to watershed length (in km).

DDR is binned into 3 classes:

1. less than 2000 km/km2
2. 2000-4000
3. greater than 4000
 
Drainage density ruggedness indicates the potential for rapid runoff delivery to and through streams, which may contribute to harmful flood events (Patton and Baker, 1976).

## Requirements

- BC FWA loaded to postgres database defined by `$DATABASE_URL` via `fwapg`
- `jq`, `parallel`
- BC DEM

## Processing

	./ddr.sh > ddr.csv

## Output

`ddr.csv`

| column                       | description                                                |
|------------------------------|------------------------------------------------------------|
| watershed_feature_id         | Assessment watershed unique id                             |
| elevation_min                | Minimum elevation in the watershed (m)                     |
| elevation_max                | Maximum elevation in the watershed (m)                     |
| elevation_relief             | The elevation relief in the watershed (m)                  |
| stream_length_km             | Length of stream in the watershed (km)                     |
| watershed_area_km2           | Area of the watershed (km2)                                |
| stream_density               | Total length of streams / total area of watershed (km/km2) |
| drainage_density_ruggedness  | Stream density as a function of relief (km of streams / km2 of watershed) * relief |
| drainage_dens_rugged_cls_num | Numeric classification of DDR: (1: <2000; 2: 2000-4000; 3: >= 4000)


