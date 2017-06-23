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

#spatial join on which roads will be blocked using ST_DWithin
d <- dbGetQuery(con, "UPDATE pgnetwork
                      SET blockage = '1'
                      WHERE id IN 
                        (SELECT DISTINCT pgnetwork.id
                        FROM a4_blockades  
                        LEFT JOIN pgnetwork ON ST_DFullyWithin(a4_blockades.geom, pgnetwork.the_geom, 0.0001));") 









dbSendQuery(con, "ALTER TABLE public.pgnetwork ALTER COLUMN the_geom TYPE geometry(LineString, 4326) USING ST_GeometryN(the_geom, 1);")

dbSendQuery(con, "UPDATE pgnetwork SET blockade = '1'
            WHERE ST_DWithin()")

dbSendQuery(con, "SELECT roads.roadname, pois.poiname
            FROM roads LEFT JOIN pois 
            ON ST_DWithin(roads.geog, pois.geog, 1609)
            WHERE pois.gid IS NOT NULL;")

















a <- dbGetQuery(con, "SELECT *
            FROM a4_blockades  
            LEFT JOIN pgnetwork ON ST_DWithin(a4_blockades.geom, pgnetwork.the_geom, 100);") #125mb problem

a <- dbGetQuery(con, "SELECT *
            FROM pgnetwork  
               LEFT JOIN a4_blockades ON ST_DWithin(pgnetwork.the_geom, a4_blockades.geom, 100);") #joins all entities

a <- dbGetQuery(con, "SELECT *
            FROM pgnetwork  
               LEFT JOIN a4_blockades ON ST_DWithin(pgnetwork.the_geom, a4_blockades.geom, 0.0001);") #50993 obs. of 29 var

b <- dbGetQuery(con, "SELECT *
            FROM a4_blockades  
               LEFT JOIN pgnetwork ON ST_DWithin(a4_blockades.geom, pgnetwork.the_geom, 0.0001);") #3333 obs. of 29 var

c <- dbGetQuery(con, "SELECT DISTINCT pgnetwork.id
                      FROM a4_blockades  
                      LEFT JOIN pgnetwork ON ST_DWithin(a4_blockades.geom, pgnetwork.the_geom, 0.0001);") #71 obs. of 1 var

d <- dbGetQuery(con, "SELECT *
                      FROM a4_blockades  
                      LEFT JOIN pgnetwork ON ST_DFullyWithin(a4_blockades.geom, pgnetwork.the_geom, 0.0001);") #273 obs of 29 var, but joined pgnetwork table is NA

e <- dbGetQuery(con, "SELECT *
                      FROM pgnetwork  
                      LEFT JOIN a4_blockades ON ST_DFullyWithin(pgnetwork.the_geom, a4_blockades.geom, 0.0001);") #47731 obs

f <- dbGetQuery(con, "SELECT *
                      FROM a4_blockades  
                      LEFT JOIN pgnetwork ON ST_DFullyWithin(a4_blockades.geom, pgnetwork.the_geom, 0.0001);") #273 obs of 29 var, but joined pgnetwork table is NA

#changed geometrytype of blockades data

