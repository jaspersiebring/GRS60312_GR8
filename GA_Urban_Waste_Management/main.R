#GA_Urban_Waste_Management
#Team Garbage

#20th of June 2017

#Automatically sets your working directory to the location of this main.R script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#installs (and loads) required packages if they're not already found
list.of.packages = c("rgdal", "RPostgreSQL", "sp", "rpostgis") 
new.packages = list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages) 
lapply(list.of.packages, require, character.only=T)

#Setting the driver that'll connect to the PostgreSQL database
drv = dbDriver("PostgreSQL")

###Connecting to the PostGreSQL database, uncomment first line if hosted locally
#con = dbConnect(drv) #simple, local host as default
con = dbConnect(drv, dbname ='PROJ_test', host = 'D0146435', port = 5432, user = "postgres", password = 'postgres')


###EXTRACT DATA FROM DATABASE###
#you can also add a query to the pgGetGeom function to directly filter spatial data
#for spatial data:
drains = pgGetGeom(con, name = c("workset333", "drains_table"), geom = "the_geom", gid = "gid") 
network = pgGetGeom(con, name = c("workset333", "tbl_workset"), geom = "the_geom", gid = 'gid')

#for plain tables:
tbl_streets = dbReadTable(con, c("workset333", "tbl_streets"))
tbl_navteq = dbReadTable(con, c("workset333", "tbl_navteq"))


###EXPORT DATA TO DATABASE###
#Accepts both SpatialDataFrame and DataFrame
#Specify the GEOM column if you're exporting spatial data
#Specified table doesn't have to exist in the database
pgInsert(con, name=c("workset333","drains_table"), data.obj= drains, geom = "the_geom", new.id = "gid")


###RAW SQL QUERIES###
#You can use the db_query/fetch/etc family to apply raw SQL queries
db_query = 'select * from workset333.tbl_workset;'

sql_result = dbGetQuery(con, db_query)


#examples of POSTGRESQL queries
##
##
## shp2pgsql -I -s <SRID> <PATH/TO/SHAPEFILE> <SCHEMA>.<DBTABLE> | psql -U postgres -d <DBNAME>


#disconnect connection
dbDisconnect(con)

#writeOGR(network, dsn = './Export', driver = 'ESRI Shapefile', layer = 'network_layer')
