# Rio Grande Project Drought Resilience Efforts (DRE) Initiative

Modeling for the Rio Grande Project Drought Resilience Efforts (DRE) Initiative

## Repo overview

This repo contains a minimal setup for running a rainfall/runoff workflow with gridded inputs.

- `run.sh`  
  main runner script containing the shell commands for running grass modules in sequence.

- `data/`  
  rainfall depth inputs (text files), e.g. `rain_1h_depths.txt`, `rain_24h_depths.txt`.

- `spatial_data/`  
  geospatial rasters used by the workflow:
  - `dem.tif`: original dem
  - `dem_modified.tif`: processed dem used for modeling
  - `esa.tif`: land cover raster
  - `n_low.tif`: manning n (low roughness) raster
  - `hsg.md`: notes/metadata for hydrologic soil group inputs

- `LICENSE`  
  project license.
