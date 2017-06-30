##Script name :GA_a2_truck_properties.R
##Description :This script contains the (spatial) data frame of truck properties in Smart Waste Management System.
#The output of this script is a table which becomes the project source for further analysis
#The table is loaded to the central database using a connection to geodatabase server
##Packages    : RPostgreSQL, sp, rpostgis
##Output table: GA_a2_truck_properties.R
##Attribute   : truck_license_plate, truck_type, truck_capacity, truck_speed, truck_emission, truck_location
##Database    : SWMS_database
##Creator     : Talitha Rahmawati
##Date        : June 21, 2017
##Organization: Wageningen University UR

truck_properties_table <- function(con, licenceplate, type, capacity, speed, emission){
  #creating data frame
  truck_license_plate <- c(licenceplate)
  truck_type <- c(type)
  truck_capacity <- c(capacity)
  truck_speed <- c(speed)
  truck_emission <-  c(emission) #very rough estimation, unit is g/km
  TruckProperties <- data.frame(truck_license_plate, truck_type, truck_capacity, truck_speed, truck_emission)  
  
  #depot location
  x <- c(5.375356)
  y <- c(52.163011)
  xy_df <- data.frame(x,y)
  coordinates <- data.matrix(xy_df)
  
  #Insert spatial data frame to database
  TruckProperties_Geometry <- SpatialPointsDataFrame(coords = coordinates, data = TruckProperties,
                                                     proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
  pgInsert(con, name=c("public","a2_truck_properties"), data.obj= TruckProperties_Geometry, geom = "the_geom", new.id = "gid")
  
}