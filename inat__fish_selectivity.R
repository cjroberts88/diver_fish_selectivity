# packages
library(sf)
library(dplyr)
library(readr)
library(stringr)
#install.packages("lwgeom")

regions_shape <- st_read("Data/imcra_provincial_bioregions/imcra4_pb.shp")

#plot(regions_shape)

regions_metadata <- data.frame(region_name=regions_shape[[1]], geometry=regions_shape[[5]],
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

#copy private lat/long to lat/long

inat_dat <-  inat_dat %>%
  mutate(final_lat=ifelse(is.na(private_latitude)=="TRUE", latitude, private_latitude)) %>%
  mutate(final_lng=ifelse(is.na(private_longitude)=="TRUE", longitude, private_longitude)) %>%
  dplyr::filter(complete.cases(final_lat))

#reduce data frame to relevant variables
inat_dat <- select(inat_dat, id, observed_on, url, final_lat, final_lng, scientific_name, common_name)




crs <- "+proj=longlat +ellps=GRS80 +no_defs"

points_sf <- st_as_sf(inat_dat, coords = c("final_lng", "final_lat"), 
                      crs = crs, agr = "constant")


assigned_points <- as.data.frame(st_nearest_feature(points_sf, regions_shape))

#iNat_assigned <- bind_cols (assigned_points)

iNat_assigned <- inat_dat %>%
  bind_cols (assigned_points) %>%
  rename(col.id='st_nearest_feature(points_sf, regions_shape)')%>%
  left_join(., regions_metadata, by="col.id") %>%
  dplyr::select(-col.id)


#calculate distance


iNat_assigned$distance <- st_distance(iNat_assigned$geometry, points_sf$geometry,by_element = TRUE)

rm(regions_metadata)
iNat_assigned <- select(iNat_assigned, -geometry)

inat_old_raw <- read_csv("Data/iNat_AusFish_old_wth_fam.csv")

inat_taxon <- inat_old_raw%>%
  distinct(., scientific_name, .keep_all = TRUE)%>%
  select(c(38, 49,52))

 iNat_assigned <-   left_join(iNat_assigned, inat_taxon, by='scientific_name')
 
 inat_species_list <- inat_old_raw %>%
  distinct(., scientific_name, .keep_all = FALSE) 
 
 inat_species_list_2 <- inat_species_list[[1]]
 

rfishbase::species(species_list=inat_species_list_2, fields = 'Fresh') -> freshwater
rfishbase::species(species_list=inat_species_list_2, fields = 'Saltwater') -> marine
rfishbase::species(species_list=inat_species_list_2, fields = 'Brack') -> brackish

species_habitat <-   bind_cols(freshwater, marine,brackish)

species_habitat$fresh_only <- abs(species_habitat$Fresh)+species_habitat$Saltwater+species_habitat$Brack

species_habitat$fresh_only <- sub(-1, 0, species_habitat$fresh_only)
species_habitat$fresh_only <- sub(-2, 0, species_habitat$fresh_only)

species_habitat <-   bind_cols(inat_species_list, species_habitat)

species_habitat <-   species_habitat[,-(2:4)]

iNat_assigned <-   left_join(iNat_assigned, species_habitat, by='scientific_name')

iNat_assigned <- iNat_assigned %>% filter(is.na(fresh_only)| fresh_only==0)

iNat_assigned$distance <- as.numeric(iNat_assigned$distance)

iNat_assigned <- iNat_assigned %>% filter(distance<15000)
