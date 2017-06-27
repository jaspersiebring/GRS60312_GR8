##Script name : GA_b2_road_blockades.R
##Description : Joins the Waze network data to the Here network, transpones boolean
##Packages    : RPostgreSQL, sp, rpostgis
##Output table: a1_bin_properties
##Attribute   : pgnetwork, SET blockage = "1"
##Database    : SWMS_database
##Creator     : Thijs van Loon
##Date        : June 27, 2017
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
