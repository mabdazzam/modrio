#!/bin/sh

set -e

#  import inputs
r.in.gdal input=dem.tif output=dem --o
r.in.gdal input=esa.tif output=esa --o
r.in.gdal input=hysogs250m_5070.tif output=hsg --o

# set region
g.region raster=dem -p

# dem derivatives
r.slope.aspect elevation=dem slope=slope aspect=aspect dx=dx dy=dy --o

# fdr and fac 
r.watershed -sa elevation=dem drainage=fdr accumulation=fac --o
r.flowaccumulation input=fdr out=fac type=FCELL --o nprocs=8

#  outlet point (epsg:5070 coords)
printf '%s\n' "-1030400.9992177339|1124736.5528888374" > outlet.txt
v.in.ascii input=outlet.txt output=outlet separator=pipe x=1 y=2 --o

# watershed delineation
r.hydrobasin direction=fdr outlets=outlet output=watershed nprocs=8 --o

# clip processing to watershed
g.region raster=watershed -p

# curve number rasters
for hc in p f g; do
  for arc in i ii iii; do
    r.cn landcover=esa soil=hsg ls=esa hc="$hc" arc="$arc" out="cn_${hc}_${arc}" nprocs=4 --o
  done
done

# time of concentration
r.watershed elevation=dem drainage=fdr_tc streams=streams_tc threshold=10 --o
r.timeofconcentration elevation=dem dir=fdr_tc streams=streams_tc tc=tc --o

# rainfall rasters 
r.mapcalc "rain_1h_T10 = 31" --o
r.mapcalc "rain_1h_T25 = 37" --o

# runoff
for rain in rain_1h_T10 rain_1h_T25; do
  for hc in p f g; do
    for arc in i ii iii; do
      r.runoff \
        rainfall="$rain" \
        duration=1 \
        cn="cn_${hc}_${arc}" \
        dir=fdr \
        tc=tc \
        runoff_depth="rd_${rain}_${hc}_${arc}" \
        runoff_volume="rv_${rain}_${hc}_${arc}" \
        peak_discharge="qp_${rain}_${hc}_${arc}" \
        --o
    done
  done
done

# r.sim.water (uses dx/dy from r.slope.aspect)
r.sim.water elevation=dem dx=dx dy=dy depth=depth_t10 discharge=q_t10 error=error_t10 rain_value=37 man=n_low --o

# NOTE: mannings n was created from QGIS mannings roughness generator plugin for all three; low, med, high roughness conditions)
# All the hydraulic analysis of the project depends on the parameter tweaking of r.sim.water
# My inundation raster metadata shows that I ran the following command;
# |r.sim.water --overwrite -t elevation="dem" dx="dx" dy="dy" rain_valu\       |
# |    e=85.34 infil_value=0.0 man="n_low" man_value=0.1 depth="depth_t1002\   |
# |    4h" discharge="q_t10024h" niterations=1440 mintimestep=0.0 output_st\   |
# |    ep=60 diffusion_coeff=0.8 hmax=0.3 halpha=4.0 hbeta=0.5 nprocs=4        |


################
# After the modified DEM from Kaustuv
r.import input=dem_modified.tif output=dem_mod resample=lanczos --o
r.slope.aspect elevation=dem_mod dx=dx_mod dy=dy_mod --o
r.sim.water elevation=dem_mod dx=dx_mod dy=dy_mod rain_value=85.34 man=n_low depth=depth_t10024h_mod discharge=q_t10024h_mod niterations=1440 mintimestep=0.0 output_step=60 nprocs=4 --o

