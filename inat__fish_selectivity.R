# packages
library(sf)
library(dplyr)
library(readr)
library(stringr)

regions_shape <- st_read("Data/imcra_provincial_bioregions/imcra4_pb.shp")

plot(regions_shape)

regions_metadata <- data.frame(region_name=regions_shape[[1]],
                               col.id=1:41)

inat_dat_raw <- read_csv("Data/iNat_AusFish.csv")



inat_dat <- inat_dat_raw %>% 
  filter(quality_grade=='research')%>% # could be worth doing a comparison of non-research grade as well for some of the more obscure/difficult species.
  filter(is.na(positional_accuracy)|positional_accuracy<10001)%>%
  filter('field:diving, snorkeling, angling, shore etc' !='washup')%>%
  filter(coordinates_obscured !='TRUE'|private_latitude!='')  # remove obscured co-ordinates that have no private lat long. 

# keep eggs?
# remove washups? ie dead fish on beaches - could potentially be from  outside a region.
## removing obscured necessary? point is within 0.2 decrees -> ~20km

inat_dat <-  inat_dat %>%
  mutate(final_lat=ifelse(is.na(private_latitude)=="TRUE", latitude, private_latitude)) %>%
  mutate(final_lng=ifelse(is.na(private_longitude)=="TRUE", longitude, private_longitude)) %>%
  dplyr::filter(complete.cases(final_lat))




crs <- "+proj=longlat +ellps=GRS80 +no_defs"

points_sf <- st_as_sf(inat_dat, coords = c("final_lng", "final_lat"), 
                      crs = crs, agr = "constant")


assigned_points <- as.data.frame(st_nearest_feature(points_sf, regions_shape))

iNat_assigned <- bind_cols (assigned_points)

iNat_assigned <- inat_dat %>%
  bind_cols (assigned_points) %>%
  rename(col.id='st_nearest_feature(points_sf, regions_shape)')%>%
  left_join(., regions_metadata, by="col.id") %>%
  dplyr::select(-col.id)




