##Script name :GA_a1_bin_properties.R
##Description :This script contains the (spatial) data frame of bin properties in Smart Waste Management System.
  #The output of this script is a table which becomes the project source for further analysis
  #The table is loaded to the central database using a connection to geodatabase server
##Packages    : RPostgreSQL, sp, rpostgis
##Output table: a1_bin_properties
##Attribute   : point geometry, "bin_address", "bin_id", "bin_inhabitants", "bin_capacity", "bin_avg_added_waste"
##Database    : SWMS_database
##Creator     : Amy Gex
##Date        : June 22, 2017
##Organization: Wageningen University UR

#installs (and loads) required packages if they're not already found
list.of.packages = c("rgdal", "RPostgreSQL", "sp", "rpostgis", "rstudioapi") 
new.packages = list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages) 
lapply(list.of.packages, require, character.only=T)

#Setting the driver that'll connect to the PostgreSQL database
drv = dbDriver("PostgreSQL")

###Connecting to the PostGreSQL database, 
# ***NOTE: this should be adjusted to connect to final db
#con = dbConnect(drv, dbname = 'ACT_Waste', user = 'postgres', password = 'postgres')
con <- dbConnect(drv, dbname ='SWMS_database', host = 'D0146435', port = 5432, user = "postgres", password = 'postgres')

###EXPORT DATA TO DATABASE###
bintable = readOGR(dsn ='./Data/Component', layer = 'a1_BinProperties' )
names(bintable) <- c("OBJECTID", "bin_address", "bin_id", "bin_inhabitants", "bin_capacity", "bin_avg_added_waste")
bin_prop = pgInsert(con, name = c('a1_bin_properties'), data.obj = bintable, geom ='the_geom' , new.id = 'gid', alter.names = TRUE, overwrite = TRUE)

# Close PostgreSQL connection 
dbDisconnect(con)