#GA_Urban_Waste_Management
#Team Garbage

#30th of June 2017
 
#installs (and loads) required packages if they're not already found
list.of.packages = c("rgdal", "RPostgreSQL", "sp", "rpostgis", "rstudioapi") 
new.packages = list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages) 
lapply(list.of.packages, require, character.only=T)

#Automatically sets your working directory to the location of this main.R script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#Load your functions here (R scripts)
source('R/GA_a0_db_and_network_initialization.R')
source('R/GA_a1_bin_properties.R')
source('R/GA_a2_truck_properties.R')
source('R/GA_a3_scenario_variables.R')
source('R/GA_a4_read_blockade_data.R')
source('R/GA_a5_initialize_bin_fill_history.R')
source('R/GA_b1_tsp_route_calculation.R')
source('R/GA_b2_road_blockades.R')
source('R/GA_b3_build_fake_data.R')
source('R/GA_b4_execute_route.R')


#Setting the driver that'll connect to the PostgreSQL database
drv = dbDriver("PostgreSQL")

###Connecting to the PostGreSQL database, 
###1st line = localhost, 2th = WUR-network: SWMS_database 
#con = dbConnect(drv, user = 'postgres', password = 'postgres', dbname = '')
con = dbConnect(drv, dbname ='SWMS_database', host = 'D0146435', port = 5432, user = 'postgres', password = 'postgres') 

#######################
#######################
#### FUNCTIONS TO INITIALIZE DATABASE AND TABLES, RUN ONLY ONCE ! ##

#Sets initial DB architecture, unpacks, relocates and renames Jewel data
#MAKE SURE YOUR DATABASE HAS THE REQUIRED EXTENSIONS AND JEWEL DATA
db_initilization(con)

#Creates a routable network (pgNetwork and pgNetwork_vertices_pgr) from the network dataset
network_initilization(con)

#Imports the bin shapefile containing location/capacity/avg_added_waste/no. of users
bin_initilization(con)

#Creates a (spatial) truck_table with modular attributes and exports it to the DB  
truck_initilization(con, 'NLGF421X', 'Kinshofer', 12000, 15, 200)

#Sets scenario variables to be used for the route calculation (plastic_weight_dens, paper_weight_dens, residual_weight_dens, handling_time, Decrease_BinAvgAddedWaste, Factor_BinCapacity)
scenario_variables(con, 0.039, 0.076, 0.1, 3, 40, 1)

#Reads and processes the Waze blockade data (and exports it to the DB)  
readBlockadeWaze(con) 

#Creates a bin_fill table where the bins have randomly been filled (with random amount up to a certain point) to resemble a normal (start) situation 
initialize_bin_filling(con)

#######################
#######################




## CHANGEABLE VARIABLES ##
bin_capacity <- 500
timestep_of_binfilling_hours <- 72
timestep_of_collecting_bins_after_last_update <- 0.25
SD_factor <- 0.1

## FUNCTIONS TO RUN APPLICATION ##

#Updates the boolean in pgnetwork that indicates whether a road is blocked or not
check_road_blockades(con)
function7 <- read_data1(con, bin_capacity, timestep_of_binfilling_hours, SD_factor)
AvgAddedWaste <- function7[[1]]
sel_wastedec <- function7[[2]]
bin_cap <- function7[[3]]
timestep <- function7[[4]]
function8 = bin_filling(AvgAddedWaste)
function9 <- read_data2(bin_capacity, con)
capacity_truck <- function9[[1]]
bin_cap <- function9[[2]]
BinData <- function9[[3]]
function10 <- collect_bins(BinData, bin_cap, capacity_truck)
function11 <- empty_bins(function10, timestep_of_collecting_bins_after_last_update) # result of function 10 is list of bins which will be emptied

#Updates boolean in pgnetwork_vertices_pgr to indicate what bin has to be emptied at what nodes 
store_empty_bins_in_network(function10, BinData, con) # result of function 10 is list of bins which will be emptied
#Calculate the route for the (to be emptied) bins using tsp_euclidean/pgr_dijkstra
pgr_tsp_route(con)




#add all max(d_agg_cost) with unique timestamps

#disconnect connection
dbDisconnect(con)





# ### EXAMPLES / PROGRAMMING HELP JASPER ###
# 
# ###EXTRACT DATA FROM DATABASE###
# #You can also add a query to the pgGetGeom function to directly filter spatial data
# #for spatial data:
# sdf_network = pgGetGeom(con, name = c("public", "tbl_workset"), geom = "the_geom", gid = 'gid')
# #for plain tables:
# tbl_streets = dbReadTable(con, c("public", "tbl_streets"))
# tbl_navteq = dbReadTable(con, c("public", "tbl_navteq"))
# 
# 
# ###EXPORT DATA TO DATABASE###
# #Accepts both SpatialDataFrame and DataFrame, specified table doesn't have to exist in DB
# #Specify the GEOM column if you're exporting spatial data
# pgInsert(con, name=c("public","sdf_network"), data.obj= sdf_network, geom = "the_geom", new.id = "gid")
# 
# ###RAW SQL QUERIES###
# #split up over three functions: 
# #   dbGetQuery(con, sql_string) #basic interactive use (always use for table select statements otherwise you'll need to force a shutdown of the DB)
# #   dbExecute(con, sql_string) #interactive use, i.e. will return objects (use for more complex spatial queries) (sendstatement/getaffectedrows/clearresult in one function)
# #   dbSendQuery(con, sql_string) #only submits and executes the query (use for PGROUTING and SQL scripts)
# 
# 
# ##If you want to store any spatialdataframes:
# #writeOGR(obj, dsn = './Export', driver = 'ESRI Shapefile', layer = 'network_layer')






