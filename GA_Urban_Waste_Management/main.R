#GA_Urban_Waste_Management
#Team Garbage

#20th of June 2017

#Automatically sets your working directory to the location of this main.R script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#installs (and loads) required packages if they're not already found
list.of.packages = c("rgdal", "RPostgreSQL", "sp", "rpostgis", "rstudioapi") 
new.packages = list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages) 
lapply(list.of.packages, require, character.only=T)

#Setting the driver that'll connect to the PostgreSQL database
drv = dbDriver("PostgreSQL")

###Connecting to the PostGreSQL database, 
###1st line = local, 2th = WUR-network: PROJ_test, 3th = WUR-network:  GA_SWMS_database
#con = dbConnect(drv) #simple, local host as default
#con = dbConnect(drv, dbname ='PROJ_test', host = 'D0146435', port = 5432, user = 'postgres', password = 'postgres')
#con = dbConnect(drv, dbname ='GA_SWMS_database', host = 'D0146435', port = 5432, user = 'postgres', password = 'postgres') 


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
#split up over three functions: 
#   dbGetQuery(con, sql_string) #basic interactive use (use only for simple table select statements)
#   dbExecute(con, sql_string) #interactive use, i.e. will return objects (use for more complex spatial queries) (sendstatement/getaffectedrows/clearresult in one function)
#   dbSendQuery(con, sql_string) #only submits and executes the query (use for PGROUTING and SQL scripts)


#examples of POSTGRESQL queries
##sql_string = 'select * from workset333.tbl_streets;'
##sql_result = dbGetQuery(con, db_query)


#disconnect connection
dbDisconnect(con)


