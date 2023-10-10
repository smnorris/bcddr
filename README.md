# Drainage Density Ruggedness (DDR)

> The dimensionless product of drainage density (stream length per unit area – km/km2) and total elevation relief.

— Melton, 1957

> The difference between the highest and lowest points in the watershed, relative to watershed length (in km).

— Schumm, 1956


> The potential for rapid runoff delivery to and through streams, which may contribute to harmful flood events 

— Patton and Baker, 1976

 
## Method

1. Generate relief for [BC FWA Assessment Watersheds](https://catalogue.data.gov.bc.ca/dataset/freshwater-atlas-assessment-watersheds) by overlaying with the BC 1:20k DEM

2. Calculate drainage density per watershed polygon (km of streams / km2 of watershed) using this definition of 'stream':

	- FWA river polygon centerlines 
	- FWA primary/secondary flow lines (ie, `edge_type IN (1000,1100,2000,2300)` and not within a lake/reservoir/wetland waterbody)

3. Calculate DDR as  drainage density * relief

4. Classify DDR:

	- class 1: less than 2000 km/km2
	- class 2: 2000-4000 km/km2
	- class 3: greater than 4000 km/km2


## Requirements

- BC FWA loaded to postgres database defined by `$DATABASE_URL` via `fwapg`
- `jq`, `parallel`
- BC DEM

## Processing

	./ddr.sh

## Output

`ddr.csv`

| column                       | description                                                |
|------------------------------|------------------------------------------------------------|
| `watershed_feature_id`         | Assessment watershed unique id                             |
| `elevation_min`                | Minimum elevation in the watershed (m)                     |
| `elevation_max`                | Maximum elevation in the watershed (m)                     |
| `elevation_relief`             | The elevation relief in the watershed (m)                  |
| `stream_length_km`             | Length of stream in the watershed (km)                     |
| `watershed_area_km2`           | Area of the watershed (km2)                                |
| `drainage_density`             | Total length of streams / total area of watershed (km/km2) |
| `drainage_density_ruggedness`  | Stream density as a function of relief (km of streams / km2 of watershed) * relief |
| `drainage_dens_rugged_cls_num` | Numeric classification of DDR: (1: <2000; 2: 2000-4000; 3: >= 4000) |

