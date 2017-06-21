#GA_Urban_Waste_Management
#Team Garbage

#21st of June 2017

#installs (and loads) required packages if they're not already found
list.of.packages = c("rgdal", "RPostgreSQL", "sp", "rpostgis", "rstudioapi") 
new.packages = list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages) 
lapply(list.of.packages, require, character.only=T)

#Automatically sets your working directory to the location of this main.R script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


#Setting the driver that'll connect to the PostgreSQL database
drv = dbDriver("PostgreSQL")

###Connecting to the PostGreSQL database, 
###1st line = localhost, 2th = WUR-network: SWMS_database 
#con = dbConnect(drv, user = 'postgres', password = 'postgres', dbname = '')
con = dbConnect(drv, dbname ='SWMS_database', host = 'D0146435', port = 5432, user = 'postgres', password = 'postgres') 


###EXTRACT DATA FROM DATABASE###
#You can also add a query to the pgGetGeom function to directly filter spatial data
#for spatial data:
sdf_network = pgGetGeom(con, name = c("public", "tbl_workset"), geom = "the_geom", gid = 'gid')
#for plain tables:
tbl_streets = dbReadTable(con, c("public", "tbl_streets"))
tbl_navteq = dbReadTable(con, c("public", "tbl_navteq"))


###EXPORT DATA TO DATABASE###
#Accepts both SpatialDataFrame and DataFrame, specified table doesn't have to exist in DB
#Specify the GEOM column if you're exporting spatial data
pgInsert(con, name=c("public","sdf_network"), data.obj= sdf_network, geom = "the_geom", new.id = "gid")

###RAW SQL QUERIES###
#split up over three functions: 
#   dbGetQuery(con, sql_string) #basic interactive use (always use for table select statements otherwise you'll need to force a shutdown of the DB)
#   dbExecute(con, sql_string) #interactive use, i.e. will return objects (use for more complex spatial queries) (sendstatement/getaffectedrows/clearresult in one function)
#   dbSendQuery(con, sql_string) #only submits and executes the query (use for PGROUTING and SQL scripts)


##If you want to store any spatialdataframes:
#writeOGR(obj, dsn = './Export', driver = 'ESRI Shapefile', layer = 'network_layer')

#disconnect connection
dbDisconnect(con)

