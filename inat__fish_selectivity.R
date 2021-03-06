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
 IMCRA_species_all_2 <- IMCRA_species_all[[1]]

rfishbase::species(species_list=inat_species_list_2, fields = 'Fresh') -> freshwater
#rfishbase::species(species_list=inat_species_list_2, fields = 'Saltwater') -> marine
#rfishbase::species(species_list=inat_species_list_2, fields = 'Brack') -> brackish

rfishbase::list_fields() -> fishbase_fields

rfishbase::ecology(species_list=inat_species_list_2, fields = 'Pelagic') -> Pelagic

rfishbase::ecology(species_list=inat_species_list_2, fields = 'Bathypelagic') -> Bathypelagic


rfishbase::ecology(species_list=IMCRA_species_all_2,fields =  c('Pelagic','Bathypelagic', 'Abyssopelagic','Epipelagic', 'Hadopelagic', 'Mesopelagic')) -> Pelagic_All_AFD

rfishbase::species(species_list=IMCRA_species_all_2, fields = 'DepthRangeDeep') -> Deep 
rfishbase::species(species_list=IMCRA_species_all_2, fields = 'DepthRangeShallow') -> Shallow 

AFD_Shallow <- bind_cols(IMCRA_species_all, Shallow)

Pelagic_All_AFD <-   bind_cols(IMCRA_species_all, Pelagic_All_AFD)

Pelagic_All_AFD$Pelagic_comb <- Pelagic_All_AFD$Pelagic +Pelagic_All_AFD$Bathypelagic+Pelagic_All_AFD$Abyssopelagic+Pelagic_All_AFD$Epipelagic+Pelagic_All_AFD$Hadopelagic+Pelagic_All_AFD$Mesopelagic

Nonpelagic_AFD <- Pelagic_All_AFD %>% 
  filter(is.na(Pelagic_comb)|Pelagic_comb==0)

AFD_Shallow <- AFD_Shallow  %>%  filter(is.na(DepthRangeShallow)|DepthRangeShallow<31)

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

#Removing pelagics....

match_indx_Pel <- as.data.frame(match(AFD_All_regions_species_SW_sml$scientific_name, Nonpelagic_AFD$Species, nomatch = 0))
match_indx_Pel <- rename(match_indx_Pel, Non_Pel_match = 'match(AFD_All_regions_species_SW_sml$scientific_name, Nonpelagic_AFD$Species, nomatch = 0)')
#Global species matching
AFD_All_regions_species_SW_incPela <- bind_cols(AFD_All_regions_species_SW_sml, match_indx_Pel)
AFD_All_regions_species_SW_noPela <- filter(AFD_All_regions_species_SW_incPela, Non_Pel_match != 0)

AFD_All_regions_species_SW_noPela <-select(AFD_All_regions_species_SW_noPela, -Non_Pel_match)
#AFD_All_regions_species_SW_sml$Dataset <- "AFD"

####STILL NEED TO REMOVE PELAGICS FROM INAT####
iNat_AFD_regions_noPela <- bind_rows(AFD_All_regions_species_SW_noPela, iNat_assigned_SW_sml)
iNat_AFD_regions_noPela <- unique(iNat_AFD_regions_noPela)

ggplot(data=iNat_AFD_regions_noPela, aes(iNat_AFD_regions_noPela$region_name)) + 
  geom_histogram(aes(fill = Dataset), position = "dodge", stat="count") + 
  coord_flip()+
  theme(axis.text.x = element_text(angle = 90,hjust=0.98,vjust=0.4)) + 
  theme(axis.text.y = element_text(angle = 0,hjust=0.98,vjust=0.3))

#Removing Deeps from AFD


match_indx_Shallow <- as.data.frame(match(AFD_All_regions_species_SW_sml$scientific_name, AFD_Shallow$Species, nomatch = 0))
match_indx_Shallow <- rename(match_indx_Shallow, Shallow_match = 'match(AFD_All_regions_species_SW_sml$scientific_name, AFD_Shallow$Species, nomatch = 0)')
#Global species matching
AFD_All_regions_species_SW_incDeep <- bind_cols(AFD_All_regions_species_SW_sml, match_indx_Shallow)
AFD_All_regions_species_SW_exDeep <- filter(AFD_All_regions_species_SW_incDeep, Shallow_match != 0)

AFD_All_regions_species_SW_noDeep <-select(AFD_All_regions_species_SW_exDeep, -Shallow_match)
#AFD_All_regions_species_SW_sml$Dataset <- "AFD"

####STILL NEED TO REMOVE PELAGICS FROM INAT####
iNat_AFD_regions_noDeep <- bind_rows(AFD_All_regions_species_SW_noDeep, iNat_assigned_SW_sml)
iNat_AFD_regions_noDeep <- unique(iNat_AFD_regions_noDeep)

ggplot(data=iNat_AFD_regions_noDeep, aes(iNat_AFD_regions_noDeep$region_name)) + 
  geom_histogram(aes(fill = Dataset), position = "dodge", stat="count") + 
  coord_flip()+
  theme(axis.text.x = element_text(angle = 90,hjust=0.98,vjust=0.4)) + 
  theme(axis.text.y = element_text(angle = 0,hjust=0.98,vjust=0.3))


###REMOVE BOTH deep and pelagics?


AFD_All_regions_species_SW_Deep_Pela <- bind_cols(AFD_All_regions_species_SW_incDeep, AFD_All_regions_species_SW_incPela)
AFD_All_regions_species_SW_exDeep_Pela <- filter(AFD_All_regions_species_SW_Deep_Pela, Shallow_match != 0)
AFD_All_regions_species_SW_exDeep_exPela <- filter(AFD_All_regions_species_SW_exDeep_Pela, Non_Pel_match != 0)

AFD_All_regions_species_SW_exDeep_exPela <-select(AFD_All_regions_species_SW_exDeep_exPela, -Shallow_match)
AFD_All_regions_species_SW_exDeep_exPela <-select(AFD_All_regions_species_SW_exDeep_exPela, -Non_Pel_match)
#AFD_All_regions_species_SW_sml$Dataset <- "AFD"

####STILL NEED TO REMOVE PELAGICS FROM INAT####
iNat_AFD_regions_exDeep_exPela <- bind_rows(AFD_All_regions_species_SW_exDeep_exPela, iNat_assigned_SW_sml)
iNat_AFD_regions_exDeep_exPela  <- unique(iNat_AFD_regions_exDeep_exPela)

ggplot(data=iNat_AFD_regions_exDeep_exPela, aes(iNat_AFD_regions_exDeep_exPela$region_name)) + 
  geom_histogram(aes(fill = Dataset), position = "dodge", stat="count") + 
   coord_flip()+
  theme(axis.text.x = element_text(angle = 90,hjust=0.98,vjust=0.4)) + 
  theme(axis.text.y = element_text(angle = 0,hjust=0.98,vjust=0.3))

theme(axis.text.x=element_text(size=15, angle=90,hjust=0.95,vjust=0.2)

      
  Regions_centre
# getting midpoints of shapes
  #regions_shape3<-regions_shape
#regions_shape3$centroids <- st_centroid(regions_shape$geometry)
regions_centroids <- select(regions_shape3, "PB_NAME", "centroids")
centroids <- st_centroid(regions_shape$geometry)
xy_coords <- do.call(rbind, st_geometry(centroids)) %>% 
  as_tibble() %>% setNames(c("lon","lat"))
regions_shape2 <- as.data.frame(regions_shape$PB_NAME)
#force join
regions_shape2 <- bind_cols(regions_shape2,xy_coords)

regions_shape2 <- rename(regions_shape2, region_name='regions_shape$PB_NAME')
#regions_shape2 <- left_join(regions_shape2,summary, by="region_name")

summary <- iNat_AFD_regions %>% 
  group_by(region_name,Dataset)%>%
  summarise(species=n_distinct(scientific_name))
summary_wide <- pivot_wider(summary, names_from=Dataset,values_from = species)
summary_wide[is.na(summary_wide)] <- 0
summary_wide$Not_recorded <- summary_wide$AFD-summary_wide$iNat
summary_wide <- select(summary_wide, -AFD)
summary_wide_all <- left_join(summary_wide,regions_shape2)
summary_long_all <- summary_wide_all %>% pivot_longer(2:3,names_to = "variable", values_to = "species")
summary_long_all <- filter(summary_long_all, region_name!="Macquarie Island Province")





install.packages("maps")
install.packages("mapdata")
install.packages("mapplots")
library(maps)
library(mapdata)
library(mapplots)


  

# The area of the Bicol Region;
xlim <- c(90,158)
ylim <- c(-47,-9)

# Creates an xyz object for use with the function draw.pie
xyz <- make.xyz(summary_long_all$lon, summary_long_all$lat,  summary_long_all$species, summary_long_all$variable)

# Colors used
col <- c("#003366", "#CCCC66", "#CC3366")

# The plot of the pie chart above the map
tiff("pie-on-map.tiff", width = 8, height = 5.5, units = "in",
     res = 200, type = "cairo")
par(mai = c(0.5, 0.5, 0.35, 0.2), omi = c(0.25, 0.5, 0, 0),
    mgp = c(2.5, 0.5, 0), family = "Liberation Serif")
basemap(xlim = c(90,158), ylim = c(-47,-9), bg = "white",
        main = "Distribution of iNat Observations compared to AFD")
map('world2Hires', xlim = xlim, ylim = ylim, add = TRUE)
draw.pie(xyz$x, xyz$y, xyz$z, radius = 1.1, col = col)
legend.pie(105, -40, labels = c("in iNat", "Not in iNat"), 
           radius = 5, bty = "n", col = col, cex = 0.8, label.dist = 1.3)
# TO ADD TEXT TO MAP
#text(121.5, 12.1, "Tuna Species:", cex = 0.8, font = 2)

dev.off()





  

