# combine AFD files into database

# packages
library(dplyr)
library(tidyverse)

# read tables
inat_dat_raw <- read_csv("Data/iNat_AusFish.csv")

AFR_regions_filelist <- read_csv("Data/species_lists/Regions_file_list.csv")

AFD_Bass_Strait_Shelf_Province <- read_csv("Data/species_lists/AFD-Bass Strait Shelf Province.csv")
AFD_Cape_Province <- read_csv("Data/species_lists/AFD-Cape Province.csv")
AFD_Central_Eastern_Province <- read_csv("Data/species_lists/AFD-Central Eastern Province.csv")
AFD_Central_Eastern_Shelf_Province <- read_csv("Data/species_lists/AFD-Central Eastern Shelf Province.csv")
AFD_Central_Eastern_Shelf_Transition <- read_csv("Data/species_lists/AFD-Central Eastern Shelf Transition.csv")
AFD_Central_Eastern_Transition <- read_csv("Data/species_lists/AFD-Central Eastern Transition.csv")
AFD_Central_Western_Province <- read_csv("Data/species_lists/AFD-Central Western Province.csv")
AFD_Central_Western_Shelf_Province <- read_csv("Data/species_lists/AFD-Central Western Shelf Province.csv")
AFD_Central_Western_Shelf_Transition <- read_csv("Data/species_lists/AFD-Central Western Shelf Transition.csv")
AFD_Central_Western_Transition <- read_csv("Data/species_lists/AFD-Central Western Transition.csv")
AFD_Christmas_Island_Province <- read_csv("Data/species_lists/AFD-Christmas Island Province.csv")
AFD_Cocos_Keeling_Island_Province <- read_csv("Data/species_lists/AFD-Cocos (Keeling) Island Province.csv")
AFD_Great_Australian_Bight_Shelf_Transition <- read_csv("Data/species_lists/AFD-Great Australian Bight Shelf Transition.csv")
AFD_Kenn_Province <- read_csv("Data/species_lists/AFD-Kenn Province.csv")
AFD_Kenn_Transition <- read_csv("Data/species_lists/AFD-Kenn Transition.csv")
AFD_Lord_Howe_Province <- read_csv("Data/species_lists/AFD-Lord Howe Province.csv")
AFD_Macquarie_Island_Province <- read_csv("Data/species_lists/AFD-Macquarie Island Province.csv")
AFD_Norfolk_Island_Province <- read_csv("Data/species_lists/AFD-Norfolk Island Province.csv")
AFD_Northeast_Province <- read_csv("Data/species_lists/AFD-Northeast Province.csv")
AFD_Northeast_Shelf_Province <- read_csv("Data/species_lists/AFD-Northeast Shelf Province.csv")
AFD_Northeast_Shelf_Transition <- read_csv("Data/species_lists/AFD-Northeast Shelf Transition.csv")
AFD_Northeast_Transition <- read_csv("Data/species_lists/AFD-Northeast Transition.csv")
AFD_Northern_Shelf_Province <- read_csv("Data/species_lists/AFD-Northern Shelf Province.csv")
AFD_Northwest_Province <- read_csv("Data/species_lists/AFD-Northwest Province.csv")
AFD_Northwest_Shelf_Province <- read_csv("Data/species_lists/AFD-Northwest Shelf Province.csv")
AFD_Northwest_Shelf_Transition <- read_csv("Data/species_lists/AFD-Northwest Shelf Transition.csv")
AFD_Northwest_Transition <- read_csv("Data/species_lists/AFD-Northwest Transition.csv")
AFD_Southeast_Shelf_Transition <- read_csv("Data/species_lists/AFD-Southeast Shelf Transition.csv")
AFD_Southeast_Transition <- read_csv("Data/species_lists/AFD-Southeast Transition.csv")
AFD_Southern_Province <- read_csv("Data/species_lists/AFD-Southern Province.csv")
AFD_Southwest_Shelf_Province <- read_csv("Data/species_lists/AFD-Southwest Shelf Province.csv")
AFD_Southwest_Shelf_Transition <- read_csv("Data/species_lists/AFD-Southwest Shelf Transition.csv")
AFD_Southwest_Transition <- read_csv("Data/species_lists/AFD-Southwest Transition.csv")
AFD_Spencer_Gulf_Shelf_Province <- read_csv("Data/species_lists/AFD-Spencer Gulf Shelf Province.csv")
AFD_Tasman_Basin_Province <- read_csv("Data/species_lists/AFD-Tasman Basin Province.csv")
AFD_Tasmania_Province <- read_csv("Data/species_lists/AFD-Tasmania Province.csv")
AFD_Tasmanian_Shelf_Province <- read_csv("Data/species_lists/AFD-Tasmanian Shelf Province.csv")
AFD_Timor_Province <- read_csv("Data/species_lists/AFD-Timor Province.csv")
AFD_Timor_Transition <- read_csv("Data/species_lists/AFD-Timor Transition.csv")
AFD_West_Tasmania_Transition <- read_csv("Data/species_lists/AFD-West Tasmania Transition.csv")
AFD_Western_Bass_Strait_Shelf_Transition <- read_csv("Data/species_lists/AFD-Western Bass Strait Shelf Transition.csv")



AFD_Bass_Strait_Shelf_Province $region_name <- "Bass Strait Shelf Province "
AFD_Cape_Province $region_name <- "Cape Province "
AFD_Central_Eastern_Province $region_name <- "Central Eastern Province "
AFD_Central_Eastern_Shelf_Province $region_name <- "Central Eastern Shelf Province "
AFD_Central_Eastern_Shelf_Transition $region_name <- "Central Eastern Shelf Transition "
AFD_Central_Eastern_Transition $region_name <- "Central Eastern Transition "
AFD_Central_Western_Province $region_name <- "Central Western Province "
AFD_Central_Western_Shelf_Province $region_name <- "Central Western Shelf Province "
AFD_Central_Western_Shelf_Transition $region_name <- "Central Western Shelf Transition "
AFD_Central_Western_Transition $region_name <- "Central Western Transition "
AFD_Christmas_Island_Province $region_name <- "Christmas Island Province "
AFD_Cocos_Keeling_Island_Province $region_name <- "Cocos (Keeling) Island Province "
AFD_Great_Australian_Bight_Shelf_Transition $region_name <- "Great Australian Bight Shelf Transition "
AFD_Kenn_Province $region_name <- "Kenn Province "
AFD_Kenn_Transition $region_name <- "Kenn Transition "
AFD_Lord_Howe_Province $region_name <- "Lord Howe Province "
AFD_Macquarie_Island_Province $region_name <- "Macquarie Island Province "
AFD_Norfolk_Island_Province $region_name <- "Norfolk Island Province "
AFD_Northeast_Province $region_name <- "Northeast Province "
AFD_Northeast_Shelf_Province $region_name <- "Northeast Shelf Province "
AFD_Northeast_Shelf_Transition $region_name <- "Northeast Shelf Transition "
AFD_Northeast_Transition $region_name <- "Northeast Transition "
AFD_Northern_Shelf_Province $region_name <- "Northern Shelf Province "
AFD_Northwest_Province $region_name <- "Northwest Province "
AFD_Northwest_Shelf_Province $region_name <- "Northwest Shelf Province "
AFD_Northwest_Shelf_Transition $region_name <- "Northwest Shelf Transition "
AFD_Northwest_Transition $region_name <- "Northwest Transition "
AFD_Southeast_Shelf_Transition $region_name <- "Southeast Shelf Transition "
AFD_Southeast_Transition $region_name <- "Southeast Transition "
AFD_Southern_Province $region_name <- "Southern Province "
AFD_Southwest_Shelf_Province $region_name <- "Southwest Shelf Province "
AFD_Southwest_Shelf_Transition $region_name <- "Southwest Shelf Transition "
AFD_Southwest_Transition $region_name <- "Southwest Transition "
AFD_Spencer_Gulf_Shelf_Province $region_name <- "Spencer Gulf Shelf Province "
AFD_Tasman_Basin_Province $region_name <- "Tasman Basin Province "
AFD_Tasmania_Province $region_name <- "Tasmania Province "
AFD_Tasmanian_Shelf_Province $region_name <- "Tasmanian Shelf Province "
AFD_Timor_Province $region_name <- "Timor Province "
AFD_Timor_Transition $region_name <- "Timor Transition "
AFD_West_Tasmania_Transition $region_name <- "West Tasmania Transition "
AFD_Western_Bass_Strait_Shelf_Transition $region_name <- "Western Bass Strait Shelf Transition "




AFD_Bass_Strait_Shelf_Province $scientific_name <- paste(AFD_Bass_Strait_Shelf_Province $GENUS,AFD_Bass_Strait_Shelf_Province $SPECIES)
AFD_Cape_Province $scientific_name <- paste(AFD_Cape_Province $GENUS,AFD_Cape_Province $SPECIES)
AFD_Central_Eastern_Province $scientific_name <- paste(AFD_Central_Eastern_Province $GENUS,AFD_Central_Eastern_Province $SPECIES)
AFD_Central_Eastern_Shelf_Province $scientific_name <- paste(AFD_Central_Eastern_Shelf_Province $GENUS,AFD_Central_Eastern_Shelf_Province $SPECIES)
AFD_Central_Eastern_Shelf_Transition $scientific_name <- paste(AFD_Central_Eastern_Shelf_Transition $GENUS,AFD_Central_Eastern_Shelf_Transition $SPECIES)
AFD_Central_Eastern_Transition $scientific_name <- paste(AFD_Central_Eastern_Transition $GENUS,AFD_Central_Eastern_Transition $SPECIES)
AFD_Central_Western_Province $scientific_name <- paste(AFD_Central_Western_Province $GENUS,AFD_Central_Western_Province $SPECIES)
AFD_Central_Western_Shelf_Province $scientific_name <- paste(AFD_Central_Western_Shelf_Province $GENUS,AFD_Central_Western_Shelf_Province $SPECIES)
AFD_Central_Western_Shelf_Transition $scientific_name <- paste(AFD_Central_Western_Shelf_Transition $GENUS,AFD_Central_Western_Shelf_Transition $SPECIES)
AFD_Central_Western_Transition $scientific_name <- paste(AFD_Central_Western_Transition $GENUS,AFD_Central_Western_Transition $SPECIES)
AFD_Christmas_Island_Province $scientific_name <- paste(AFD_Christmas_Island_Province $GENUS,AFD_Christmas_Island_Province $SPECIES)
AFD_Cocos_Keeling_Island_Province $scientific_name <- paste(AFD_Cocos_Keeling_Island_Province $GENUS,AFD_Cocos_Keeling_Island_Province $SPECIES)
AFD_Great_Australian_Bight_Shelf_Transition $scientific_name <- paste(AFD_Great_Australian_Bight_Shelf_Transition $GENUS,AFD_Great_Australian_Bight_Shelf_Transition $SPECIES)
AFD_Kenn_Province $scientific_name <- paste(AFD_Kenn_Province $GENUS,AFD_Kenn_Province $SPECIES)
AFD_Kenn_Transition $scientific_name <- paste(AFD_Kenn_Transition $GENUS,AFD_Kenn_Transition $SPECIES)
AFD_Lord_Howe_Province $scientific_name <- paste(AFD_Lord_Howe_Province $GENUS,AFD_Lord_Howe_Province $SPECIES)
AFD_Macquarie_Island_Province $scientific_name <- paste(AFD_Macquarie_Island_Province $GENUS,AFD_Macquarie_Island_Province $SPECIES)
AFD_Norfolk_Island_Province $scientific_name <- paste(AFD_Norfolk_Island_Province $GENUS,AFD_Norfolk_Island_Province $SPECIES)
AFD_Northeast_Province $scientific_name <- paste(AFD_Northeast_Province $GENUS,AFD_Northeast_Province $SPECIES)
AFD_Northeast_Shelf_Province $scientific_name <- paste(AFD_Northeast_Shelf_Province $GENUS,AFD_Northeast_Shelf_Province $SPECIES)
AFD_Northeast_Shelf_Transition $scientific_name <- paste(AFD_Northeast_Shelf_Transition $GENUS,AFD_Northeast_Shelf_Transition $SPECIES)
AFD_Northeast_Transition $scientific_name <- paste(AFD_Northeast_Transition $GENUS,AFD_Northeast_Transition $SPECIES)
AFD_Northern_Shelf_Province $scientific_name <- paste(AFD_Northern_Shelf_Province $GENUS,AFD_Northern_Shelf_Province $SPECIES)
AFD_Northwest_Province $scientific_name <- paste(AFD_Northwest_Province $GENUS,AFD_Northwest_Province $SPECIES)
AFD_Northwest_Shelf_Province $scientific_name <- paste(AFD_Northwest_Shelf_Province $GENUS,AFD_Northwest_Shelf_Province $SPECIES)
AFD_Northwest_Shelf_Transition $scientific_name <- paste(AFD_Northwest_Shelf_Transition $GENUS,AFD_Northwest_Shelf_Transition $SPECIES)
AFD_Northwest_Transition $scientific_name <- paste(AFD_Northwest_Transition $GENUS,AFD_Northwest_Transition $SPECIES)
AFD_Southeast_Shelf_Transition $scientific_name <- paste(AFD_Southeast_Shelf_Transition $GENUS,AFD_Southeast_Shelf_Transition $SPECIES)
AFD_Southeast_Transition $scientific_name <- paste(AFD_Southeast_Transition $GENUS,AFD_Southeast_Transition $SPECIES)
AFD_Southern_Province $scientific_name <- paste(AFD_Southern_Province $GENUS,AFD_Southern_Province $SPECIES)
AFD_Southwest_Shelf_Province $scientific_name <- paste(AFD_Southwest_Shelf_Province $GENUS,AFD_Southwest_Shelf_Province $SPECIES)
AFD_Southwest_Shelf_Transition $scientific_name <- paste(AFD_Southwest_Shelf_Transition $GENUS,AFD_Southwest_Shelf_Transition $SPECIES)
AFD_Southwest_Transition $scientific_name <- paste(AFD_Southwest_Transition $GENUS,AFD_Southwest_Transition $SPECIES)
AFD_Spencer_Gulf_Shelf_Province $scientific_name <- paste(AFD_Spencer_Gulf_Shelf_Province $GENUS,AFD_Spencer_Gulf_Shelf_Province $SPECIES)
AFD_Tasman_Basin_Province $scientific_name <- paste(AFD_Tasman_Basin_Province $GENUS,AFD_Tasman_Basin_Province $SPECIES)
AFD_Tasmania_Province $scientific_name <- paste(AFD_Tasmania_Province $GENUS,AFD_Tasmania_Province $SPECIES)
AFD_Tasmanian_Shelf_Province $scientific_name <- paste(AFD_Tasmanian_Shelf_Province $GENUS,AFD_Tasmanian_Shelf_Province $SPECIES)
AFD_Timor_Province $scientific_name <- paste(AFD_Timor_Province $GENUS,AFD_Timor_Province $SPECIES)
AFD_Timor_Transition $scientific_name <- paste(AFD_Timor_Transition $GENUS,AFD_Timor_Transition $SPECIES)
AFD_West_Tasmania_Transition $scientific_name <- paste(AFD_West_Tasmania_Transition $GENUS,AFD_West_Tasmania_Transition $SPECIES)
AFD_Western_Bass_Strait_Shelf_Transition $scientific_name <- paste(AFD_Western_Bass_Strait_Shelf_Transition $GENUS,AFD_Western_Bass_Strait_Shelf_Transition $SPECIES)

AFD_Bass_Strait_Shelf_Province <- select(AFD_Bass_Strait_Shelf_Province , scientific_name,region_name)
AFD_Cape_Province <- select(AFD_Cape_Province , scientific_name,region_name)
AFD_Central_Eastern_Province <- select(AFD_Central_Eastern_Province , scientific_name,region_name)
AFD_Central_Eastern_Shelf_Province <- select(AFD_Central_Eastern_Shelf_Province , scientific_name,region_name)
AFD_Central_Eastern_Shelf_Transition <- select(AFD_Central_Eastern_Shelf_Transition , scientific_name,region_name)
AFD_Central_Eastern_Transition <- select(AFD_Central_Eastern_Transition , scientific_name,region_name)
AFD_Central_Western_Province <- select(AFD_Central_Western_Province , scientific_name,region_name)
AFD_Central_Western_Shelf_Province <- select(AFD_Central_Western_Shelf_Province , scientific_name,region_name)
AFD_Central_Western_Shelf_Transition <- select(AFD_Central_Western_Shelf_Transition , scientific_name,region_name)
AFD_Central_Western_Transition <- select(AFD_Central_Western_Transition , scientific_name,region_name)
AFD_Christmas_Island_Province <- select(AFD_Christmas_Island_Province , scientific_name,region_name)
AFD_Cocos_Keeling_Island_Province <- select(AFD_Cocos_Keeling_Island_Province , scientific_name,region_name)
AFD_Great_Australian_Bight_Shelf_Transition <- select(AFD_Great_Australian_Bight_Shelf_Transition , scientific_name,region_name)
AFD_Kenn_Province <- select(AFD_Kenn_Province , scientific_name,region_name)
AFD_Kenn_Transition <- select(AFD_Kenn_Transition , scientific_name,region_name)
AFD_Lord_Howe_Province <- select(AFD_Lord_Howe_Province , scientific_name,region_name)
AFD_Macquarie_Island_Province <- select(AFD_Macquarie_Island_Province , scientific_name,region_name)
AFD_Norfolk_Island_Province <- select(AFD_Norfolk_Island_Province , scientific_name,region_name)
AFD_Northeast_Province <- select(AFD_Northeast_Province , scientific_name,region_name)
AFD_Northeast_Shelf_Province <- select(AFD_Northeast_Shelf_Province , scientific_name,region_name)
AFD_Northeast_Shelf_Transition <- select(AFD_Northeast_Shelf_Transition , scientific_name,region_name)
AFD_Northeast_Transition <- select(AFD_Northeast_Transition , scientific_name,region_name)
AFD_Northern_Shelf_Province <- select(AFD_Northern_Shelf_Province , scientific_name,region_name)
AFD_Northwest_Province <- select(AFD_Northwest_Province , scientific_name,region_name)
AFD_Northwest_Shelf_Province <- select(AFD_Northwest_Shelf_Province , scientific_name,region_name)
AFD_Northwest_Shelf_Transition <- select(AFD_Northwest_Shelf_Transition , scientific_name,region_name)
AFD_Northwest_Transition <- select(AFD_Northwest_Transition , scientific_name,region_name)
AFD_Southeast_Shelf_Transition <- select(AFD_Southeast_Shelf_Transition , scientific_name,region_name)
AFD_Southeast_Transition <- select(AFD_Southeast_Transition , scientific_name,region_name)
AFD_Southern_Province <- select(AFD_Southern_Province , scientific_name,region_name)
AFD_Southwest_Shelf_Province <- select(AFD_Southwest_Shelf_Province , scientific_name,region_name)
AFD_Southwest_Shelf_Transition <- select(AFD_Southwest_Shelf_Transition , scientific_name,region_name)
AFD_Southwest_Transition <- select(AFD_Southwest_Transition , scientific_name,region_name)
AFD_Spencer_Gulf_Shelf_Province <- select(AFD_Spencer_Gulf_Shelf_Province , scientific_name,region_name)
AFD_Tasman_Basin_Province <- select(AFD_Tasman_Basin_Province , scientific_name,region_name)
AFD_Tasmania_Province <- select(AFD_Tasmania_Province , scientific_name,region_name)
AFD_Tasmanian_Shelf_Province <- select(AFD_Tasmanian_Shelf_Province , scientific_name,region_name)
AFD_Timor_Province <- select(AFD_Timor_Province , scientific_name,region_name)
AFD_Timor_Transition <- select(AFD_Timor_Transition , scientific_name,region_name)
AFD_West_Tasmania_Transition <- select(AFD_West_Tasmania_Transition , scientific_name,region_name)
AFD_Western_Bass_Strait_Shelf_Transition <- select(AFD_Western_Bass_Strait_Shelf_Transition , scientific_name,region_name)


AFD_All_regions_species <- bind_rows(AFD_Bass_Strait_Shelf_Province , AFD_Cape_Province , AFD_Central_Eastern_Province, AFD_Central_Eastern_Shelf_Province , AFD_Central_Eastern_Shelf_Transition, AFD_Central_Eastern_Transition, AFD_Central_Western_Province , AFD_Central_Western_Shelf_Province , AFD_Central_Western_Shelf_Transition , AFD_Central_Western_Transition, AFD_Christmas_Island_Province , AFD_Cocos_Keeling_Island_Province , AFD_Great_Australian_Bight_Shelf_Transition , AFD_Kenn_Province , AFD_Kenn_Transition , AFD_Lord_Howe_Province , AFD_Macquarie_Island_Province , AFD_Norfolk_Island_Province , AFD_Northeast_Province , AFD_Northeast_Shelf_Province , AFD_Northeast_Shelf_Transition , AFD_Northeast_Transition , AFD_Northern_Shelf_Province , AFD_Northwest_Province , AFD_Northwest_Shelf_Province , AFD_Northwest_Shelf_Transition , AFD_Northwest_Transition , AFD_Southeast_Shelf_Transition , AFD_Southeast_Transition , AFD_Southern_Province , AFD_Southwest_Shelf_Province , AFD_Southwest_Shelf_Transition , AFD_Southwest_Transition , AFD_Spencer_Gulf_Shelf_Province , AFD_Tasman_Basin_Province , AFD_Tasmania_Province , AFD_Tasmanian_Shelf_Province , AFD_Timor_Province , AFD_Timor_Transition , AFD_West_Tasmania_Transition , AFD_Western_Bass_Strait_Shelf_Transition)

write.csv(AFD_All_regions_species, file = "Outputs/AFD_species_by_region.csv")

