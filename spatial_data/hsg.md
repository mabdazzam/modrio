Download the Global 250m Hydrologic Soil Group from
the following  URL and keep it in this directory.
https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=1566

To fix the EPSG issue and reduce the size,
it is recommended to run the following command
in the command line (requires GDAL compilation):

```sh
gdalwarp -t_srs EPSG:4326 -of GTiff -co COMPRESS=LZW -co \
TILED=YES -co PREDICTOR=2 HYSOGs250m.tif HYSOGs250m_4326_lzw.tif
```
