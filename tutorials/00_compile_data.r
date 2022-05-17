# acquires digital elevation models for Upper Penticton Creek
# and the built-in volcano data set and stores them in the
# "data" folder
#
# resamples the UPC DEMs to 10-m resolution and stores in the
# "output" folder
#
# 2022-May-14 RDM
# =============================================================

library(sf)
library(dplyr)
library(raster)
library(tidyr)
library(magrittr)
library(CSHShydRology)
library(here)


# ===================================================================
# check that 'data' and 'output' folders exist; if not, create them
# ===================================================================

data_dir <- here::here("data")
if (!dir.exists(data_dir)) dir.create(data_dir)

out_dir <- here::here("output")
if (!dir.exists(out_dir)) dir.create(out_dir)


# ==============================================================
# generate a DEM from the built-in volcano data set
# ==============================================================

volcano_dem <- ch_volcano_raster()

# check plot
plot(volcano_dem)

# save as GeoTIFF 
fn_geotiff <- here::here("data", "volcano.tiff")
writeRaster(volcano_dem, fn_geotiff)


# ====================================================================
# download DEMs from zenodo repository; first check whether they exist
# ====================================================================

# 240 and 241 Creeks
url_240 <- "https://zenodo.org/record/5520109/files/gs_be240.tif"
fn_240 <- here::here("data", "upc_dem_240.tif")
if (!file.exists(fn_240)) {
  ch_get_url_data(gd_url = url_240, gd_filename = fn_240)
} 

# 242 Creek
url_242 <- "https://zenodo.org/record/5520109/files/gs_be242.tif"
fn_242 <- here::here("data", "upc_dem_242.tif")
if (!file.exists(fn_242)) {
  ch_get_url_data(gd_url = url_242, gd_filename = fn_242)
}

# resample to 10-m resolution and save
dem_240 <- raster::raster(fn_240)
dem_240_ras <- raster(ext = extent(dem_240), crs = crs(dem_240), res = 10)
dem_240_10 <- resample(dem_240, dem_240_ras)
fn_240_10 <- here::here("output", "upc_dem_240_10.tif")
writeRaster(dem_240_10, fn_240_10)

dem_242 <- raster::raster(fn_242)
dem_242_ras <- raster(ext = extent(dem_242), crs = crs(dem_242), res = 10)
dem_242_10 <- resample(dem_242, dem_242_ras)
fn_242_10 <- here::here("output", "upc_dem_242_10.tif")
writeRaster(dem_242_10, fn_242_10)


# ====================================================================
# download weir locations from zenodo repository
# ====================================================================

# local file name for weir file
fn_weirs <- here::here("data", "weirs.GeoJSON")

# check if file already exists; if not, access it from zenodo
if (!file.exists(fn_weirs)) {
  url_weirs <-"https://zenodo.org/record/5520109/files/gs_weirs.GeoJSON"
  weirs <- ch_get_url_data(url_weirs, fn_weirs)
  fn_weirs <- here::here("data", "weirs.GeoJSON")
  st_write(weirs, fn_weirs)
}  


