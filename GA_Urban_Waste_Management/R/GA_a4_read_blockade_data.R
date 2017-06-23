##Script name : GA_a4_read_blockade_data.R
##Description : Loads the Waze data in csv format, subsets only the blockades (leaving out traffic), 
              #pushes dataframe to database and lets the database make the table spatial
##Packages    : RPostgreSQL, sp, rpostgis
##Output table: a4_blockades
##Attribute   : according to Waze data
##Database    : SWMS_database
##Creator     : Thijs van Loon
##Date        : June 22, 2017
##Organization: Wageningen University UR

#import csv to dataframe
AllWazeData <- read.csv("./data/project/a4_WazeTrafficData.csv", header = TRUE, sep = ";", strip.white = TRUE)
RoadClosures <- subset(AllWazeData, linqmap_level == "5")

#push dataframe to db
pgInsert(con, name=c("public","a4_blockades"), data.obj= RoadClosures, new.id = "gid", df.geom = "geom")
dbSendQuery(con, "SELECT UpdateGeometrySRID('a4_blockades', 'geom', 4326);" )

dbSendQuery(con, "SELECT UpdateGeometrySRID('pgnetwork', 'the_geom', 4326);" )

#No srid code given, defaulted to 0 