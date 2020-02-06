# packages

library(sf)
library(dplyr)
library(readr)
library(stringr)
library(tidyverse)
library(ggplot2)
#install.packages("tidyverse", dependencies = TRUE )
#install.packages("lwgeom")

regions_shape <- st_read("Data/imcra_provincial_bioregions/imcra4_pb.shp")

#plot(regions_shape)

regions_metadata <- data.frame(region_name=regions_shape[[1]], geometry=regions_shape[[5]],
                               col.id=1:41)

inat_dat_raw <- read_csv("Data/iNat_AusFish.csv")
FW_specieslist <- read_csv("Data/FW_as_adults.csv")
AFD_All_regions_species <- read_csv("Outputs/AFD_species_by_region.csv")


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
 

#rfishbase::species(species_list=inat_species_list_2, fields = 'Fresh') -> freshwater
#rfishbase::species(species_list=inat_species_list_2, fields = 'Saltwater') -> marine
#rfishbase::species(species_list=inat_species_list_2, fields = 'Brack') -> brackish

#species_habitat <-   bind_cols(freshwater, marine,brackish)

#species_habitat$fresh_only <- abs(species_habitat$Fresh)+species_habitat$Saltwater+species_habitat$Brack

#species_habitat$fresh_only <- sub(-1, 0, species_habitat$fresh_only)
#species_habitat$fresh_only <- sub(-2, 0, species_habitat$fresh_only)

#species_habitat <-   bind_cols(inat_species_list, species_habitat)

#species_habitat <-   species_habitat[,-(2:4)]

#iNat_assigned <-   left_join(iNat_assigned, species_habitat, by='scientific_name')

#iNat_assigned <- iNat_assigned %>% filter(is.na(fresh_only)| fresh_only==0)
 
 FW_specieslist$fresh_only <- "1"
iNat_assigned_SW <-   left_join(iNat_assigned, FW_specieslist, by='scientific_name')

iNat_assigned_SW$distance <- as.numeric(iNat_assigned_SW$distance)
iNat_assigned_SW <- iNat_assigned_SW %>% filter(is.na(fresh_only))

iNat_assigned_SW <- iNat_assigned_SW %>% filter(distance<15000)

iNat_assigned_SW_sml <-select(iNat_assigned_SW, scientific_name, region_name)
iNat_assigned_SW_sml$Dataset <- "iNat"

iNat_master_list <- distinct(iNat_assigned,scientific_name)

#IMCRA SPECIES LISTS

IMCRA_master_list <- read_csv("Data/species_lists/AFD-All regions combined.csv")

IMCRA_species_all <- IMCRA_master_list %>% 
  unite(., GENUS, SPECIES, col="Species",sep=" ")%>%
  select(., "Species")


#iNat species not in IMCRA - ??? old code may be worth rerunning this check at some point

#match_indx_iNat <- as.data.frame(match(iNat_master_list$scientific_name, IMCRA_species_all$Species,  nomatch = 0))

#Global species matching

#iNat_IMCRA_match <- bind_cols(iNat_master_list, match_indx_iNat)
#iNat_IMCRA_match <- filter(iNat_IMCRA_match, iNat_IMCRA_match[[2]] == 0)

#write.csv(iNat_IMCRA_match, file = "Outputs/iNat_IMCRA_match.csv")


# old code -> redundant?
#IMCRA species found/not by INat 
#match_indx <- as.data.frame(match(IMCRA_species_all$Species, iNat_master_list$scientific_name, nomatch = 0))
#Global species matching
#IMCRA_iNat_match <- bind_cols(IMCRA_species_all, match_indx)




#IMCRA FW species in AFD species by region

match_indx_FW <- as.data.frame(match(AFD_All_regions_species$scientific_name, FW_specieslist$scientific_name, nomatch = 0))
match_indx_FW <- rename(match_indx_FW, FW_match = 'match(AFD_All_regions_species$scientific_name, FW_specieslist$scientific_name, nomatch = 0)')
#Global species matching
AFD_All_regions_species_FW_SW <- bind_cols(AFD_All_regions_species, match_indx_FW)
AFD_All_regions_species_SW <- filter(AFD_All_regions_species_FW_SW, FW_match == 0)

AFD_All_regions_species_SW_sml <-select(AFD_All_regions_species_SW, scientific_name, region_name)
AFD_All_regions_species_SW_sml$Dataset <- "AFD"

iNat_AFD_regions <- bind_rows(AFD_All_regions_species_SW_sml, iNat_assigned_SW_sml)
iNat_AFD_regions <- unique(iNat_AFD_regions)

ggplot(data=iNat_AFD_regions, aes(iNat_AFD_regions$region_name)) + 
  geom_histogram(aes(fill = Dataset), position = "dodge", stat="count") + 
  theme(axis.text.x = element_text(angle = 90))

# getting midpoints of shapes
centroids <- st_centroid(regions_shape$geometry)
xy_coords <- do.call(rbind, st_geometry(centroids)) %>% 
  as_tibble() %>% setNames(c("lon","lat"))
regions_shape2 <- as.data.frame(regions_shape$PB_NAME)
#force join
regions_shape2 <- merge(regions_shape2,xy_coords)

regions_shape2 <- rename(regions_shape2, region_name='regions_shape$PB_NAME')
regions_shape2 <- left_join(regions_shape2,summary, by="region_name")

summary <- iNat_AFD_regions %>% 
  group_by(region_name,Dataset)%>%
  summarise(species=n_distinct(scientific_name))

ggplot(data=summary, aes(species)) + 
  geom_scatterpie(aes(fill = Dataset), position = "dodge", stat="count") + 
  theme(axis.text.x = element_text(angle = 90))

#geom scatterpie not available in this R version?

install.packages("geom_scatterpie")
library(geom_scatterpie)
ggplot() + geom_scatterpie(aes(x=lon, y=lat, 
                               group=species, 
                            ), 
                           data=regions_shape2,                                 
                           ) + coord_equal()
