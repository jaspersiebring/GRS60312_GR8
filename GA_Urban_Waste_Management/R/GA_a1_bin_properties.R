##Script name : GA_a1_bin_properties.R
##Description : This script contains the (spatial) data frame of bin properties in Smart Waste Management System.
#               The output of this script is a table which becomes the project source for further analysis
#               The table is loaded to the central database using a connection to geodatabase server
##Packages    : RPostgreSQL, sp, rpostgis
##Output table: a1_bin_properties
##Attribute   : point geometry, "bin_address", "bin_id", "bin_inhabitants", "bin_capacity", "bin_avg_added_waste"
##Database    : SWMS_database
##Creator     : Amy Gex
##Date        : June 22, 2017
##Organization: Wageningen University UR

###EXPORT DATA TO DATABASE###

#Imports the (premade) bin shapefile containing locations(geocoded), unique bin_ids, capacity, users/inhabitants per bin, average added waste per bin(CBS)
#Pushes it to the DB (overwrites if already exists)
bin_initilization <- function(con){
  bintable = readOGR(dsn ='./Data/Component', layer = 'a1_BinProperties' )
  names(bintable) <- c("OBJECTID", "bin_address", "bin_id", "bin_inhabitants", "bin_capacity", "bin_avg_added_waste")
  bin_prop = pgInsert(con, name = c('a1_bin_properties'), data.obj = bintable, geom ='the_geom' , new.id = 'gid', alter.names = TRUE, overwrite = TRUE)
}