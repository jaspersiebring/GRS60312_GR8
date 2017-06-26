##Script name :GA_b2_road_blockades.R
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

#open all roads; boolean to blockage = 0
dbSendQuery(con, "")
dbSendQuery(con, "UPDATE pgnetwork SET blockage = '0'")

#make view with buffer of blocked roads, the 0.0001 degrees translates to a 10m selection threshold
f <- dbGetQuery(con, "CREATE OR REPLACE VIEW a4_blockades_joined AS
                      SELECT st_union(st_buffer(a4_blockades.geom, 0.0001))
                      FROM a4_blockades;")

g <- dbGetQuery(con, "UPDATE pgnetwork
                      SET blockage = '1'
                      WHERE gid IN 
                        (SELECT DISTINCT pgnetwork.gid
                        FROM pgnetwork
                        RIGHT JOIN a4_blockades_joined ON ST_within(pgnetwork.the_geom, a4_blockades_joined.st_union));") 