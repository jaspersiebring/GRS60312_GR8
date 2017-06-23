##Script name :database_initilization.R
##Description :
##Output table: 
##Attribute   : 
##Database    : SWMS_database
##Creator     : Jasper Siebring
##Date        : June 23, 2017
##Organization: Wageningen University UR


#GA_Urban_Waste_Management
#Team Garbage

#22nd of June 2017

#Function that initializes the SWMS database (assuming its prebuilt using the pgRouting template and holds the restored Jewel backup file)
db_init = function(con){
  
  #Still need to add the auto_restore options in db_init:
  ###pg_restore -i -h localhost -p 5432 -U postgres -d old_db -v 
  ###"/usr/local/backup/10.70.0.61.backup"
  ###wmp_workset333.backup
  
    sql_query = paste("ALTER TABLE workset333.tbl_streets SET SCHEMA public;",
                      "ALTER TABLE workset333.tbl_navteq SET SCHEMA public;",
                      "ALTER TABLE workset333.tbl_workset SET SCHEMA public;",
                      "ALTER SCHEMA workset333 RENAME TO jewel_data;",
                      "SELECT UpdateGeometrySRID('tbl_workset', 'the_geom', 4326);")
    dbSendQuery(con, sql_query)
}


#Function that creates the pgNetwork/vertices from Jewel' tbl_workset (network data) 
create_pgnetwork_and_pgvertices = function(con){
  #Adds (int4) source/target columns to the network_workset required for the creation of topology 
  dbSendQuery(con, "ALTER TABLE public.tbl_workset add column source integer; ALTER TABLE public.tbl_workset add column target integer;")
  
  #Creates initial topology, public.tbl_workset_vertices_pgr
  sp_topology = dbExecute(con, "SELECT pgr_createTopology('public.tbl_workset', 0.0001, 'the_geom', 'gid');")
  
  #Changes the names of network and its vertices that'll be used in pgRouting
  dbSendQuery(con, "ALTER TABLE public.tbl_workset RENAME TO pgnetwork;")
  dbSendQuery(con, "ALTER TABLE public.tbl_workset_vertices_pgr RENAME TO pgnetwork_vertices_pgr;")
  
  #Adds the blockage boolean to the network  table
  dbSendQuery(con, "ALTER TABLE public.pgnetwork ADD column blockage boolean;")
}
