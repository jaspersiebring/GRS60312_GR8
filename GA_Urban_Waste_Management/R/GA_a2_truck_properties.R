##Script name :GA_a2_truck_properties.R
##Description :This script contains the (spatial) data frame of truck properties in Smart Waste Management System.
              #The output of this script is a table which becomes the project source for further analysis
              #The table is loaded to the central database using a connection to geodatabase server
##Packages    : RPostgreSQL, sp, rpostgis
##Output table: GA_ps_truck_properties
##Attribute   : gid, license_plat,capacity,speed_max, truck_type, the_geom
##Database    : SWMS_database
##Creator     : Talitha Rahmawati
##Date        : June 21, 2017
##Organization: Wageningen University UR


#load the packages
library('RPostgreSQL')
library('sp')
library ('rpostgis')

#creating data frame
license_plat <- c('NLGF421X','NLGF422X','NLGF423X','NLGF424X','NLGF425X')
capacity <- c(12000, 12000, 12000, 12000, 10000)
speed_max <- c(15, 15, 15, 15, 15)
truck_type <- c('Kinshofer','Kinshofer','Kinshofer','Kinshofer','Kinshofer')
TruckProperties <- data.frame(license_plat,capacity,speed_max, truck_type)  

#depot location
x <- c(5.375356,5.375356,5.375356,5.375356,5.375356)
y <- c(52.163011,52.163011,52.163011,52.163011,52.163011)
xy_df <- data.frame(x,y)

coordinates <- data.matrix(xy_df)


# Database connection
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname ='SWMS_database', host = 'D0146435', port = 5432, user = "postgres", password = 'postgres')


#Insert spatial data frame to database

TruckProperties_Geometry <- SpatialPointsDataFrame(coords = coordinates, data = TruckProperties,
                                                   proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))

pgInsert(con, name=c("public","GA_ps_truck_properties"), data.obj= TruckProperties_Geometry, geom = "the_geom", new.id = "gid")



# Free up resources
dbDisconnect(con)



