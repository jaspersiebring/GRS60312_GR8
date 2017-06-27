#GA_Urban_Waste_Management
#Team Garbage

#22nd of June 2017

#Function that initializes the SWMS database (assuming its prebuilt using the pgRouting template and holds the restored Jewel backup file)
db_init = function(con){
    sql_query = paste('ALTER TABLE workset333.tbl_streets SET SCHEMA public;',
                      'ALTER TABLE workset333.tbl_navteq SET SCHEMA public;',
                      'ALTER TABLE workset333.tbl_workset SET SCHEMA public;',
                      'ALTER SCHEMA workset333 RENAME TO jewel_data;')
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
  
  #Adds the blockage boolean to the network table and binid to vertices table
  dbSendQuery(con, "ALTER TABLE public.pgnetwork_vertices_pgr ADD column binid integer;")
  dbSendQuery(con, "ALTER TABLE public.pgnetwork ADD column blockage boolean;")
  
  #Fixes cost and reverse cost measurements
  dbSendQuery(con, "ALTER TABLE public.pgnetwork ADD column cost float8;
                    ALTER TABLE public.pgnetwork ADD column rcost float8;")
  dbSendQuery(con, "UPDATE public.pgnetwork SET cost = st_length(public.pgnetwork.the_geom::geography);")
  dbSendQuery(con, "UPDATE public.pgnetwork SET cost = -1 WHERE direction = '-';")
  dbSendQuery(con, "UPDATE public.pgnetwork SET rcost = st_length(public.pgnetwork.the_geom::geography);")
  dbSendQuery(con, "UPDATE public.pgnetwork SET rcost = -1 WHERE direction = '+';")
}

#node_vector <- c(627, 4420)
#dbSendQuery(con, "DROP TABLE IF EXISTS temp_route")

#Calculates the shortest route between two nodes (node_vector) based on Dijkstra's algorithm and saves it as a table (pgroutes)
create_pgroutes = function(con, node_vector){
  #CREATE IF NOT EXISTS
  dbSendQuery(con, "CREATE TABLE IF NOT EXISTS public.pgroutes(seq int4, node int4, edge integer, cost float8, the_geom geometry, timestamp timestamptz);")
  node_source = node_vector[1]
  node_target = node_vector[2]
  dbSendQuery(con, paste0("CREATE TABLE temp_route AS SELECT seq, id1 AS node, id2 AS edge, di.cost, the_geom, now() date ",
                          "FROM pgr_dijkstra('SELECT gid AS ID, source, target, cost, rcost AS reverse_cost FROM pgnetwork WHERE NOT blockage', ",
                          node_source, ", ", node_target, ", true, true) as di",
                          " JOIN public.pgnetwork",
                          " ON di.id2 = public.pgnetwork.gid"))
  dbSendQuery(con, "INSERT INTO pgroutes SELECT * FROM temp_route;")
  dbSendQuery(con, "DROP TABLE IF EXISTS temp_route")
  }


#Spaghetti code for the re-noded network and other planned tasks:
#Still need to add the auto_restore options in db_init:
###pg_restore -i -h localhost -p 5432 -U postgres -d old_db -v 
###"/usr/local/backup/10.70.0.61.backup"
###wmp_workset333.backup


#change of geometry type is not even needed

#Analyses the network (needs both vertices and network) for gaps, intersections and dead ends 
######RUN ME##sp_analysis = dbGetQuery(con, "SELECT pgr_analyzegraph('public.pgnetwork', 0.001, the_geom:='the_geom', id:='gid', source:='source', target:='target');")

#If analysis has shown that a new network is needed, this is execute and initially called public.tbl_workset.noded
#temp_sql_result = dbExecute(con, "SELECT pgr_nodenetwork('public.tbl_workset', 0.001, 'gid', 'the_geom', 'noded');")

#You would still need to join the old network columns to this new network (left join, old.id > new.id
#join while it still exists, gets deleted at the end of this script

#Using the 'new' network to create topology
#temp_sql_result = dbExecute(con, "SELECT pgr_createtopology('public.tbl_workset_noded', 0.001);")

#Analyse the new network
#sp_analysis = dbGetQuery(con, "SELECT pgr_analyzegraph('public.tbl_workset_noded', 0.001, the_geom:='the_geom', id:='id', source:='source', target:='target');")

#Checks whether the network is build up of multiline objects and changes it to singleline segments if that's the case (required for topology)
#chck_multiline = dbGetQuery(con, "SELECT COUNT(CASE WHEN ST_NumGeometries(the_geom) > 1 THEN 1 END) AS multi, COUNT(the_geom) AS total FROM public.tbl_workset;")
#if (chck_multiline$multi == 0){
#dbSendQuery(con, "ALTER TABLE public.tbl_workset ALTER COLUMN the_geom TYPE geometry(LineString, 4326) USING ST_GeometryN(the_geom, 1);")} 


##Extremely important, won't work otherwise
#   --CHANGE DATATYPES
#   --ALTER TABLE public.pgnetwork ALTER COLUMN the_geom TYPE geometry(LineString, 4326) USING ST_GeometryN(the_geom, 1); 
#   --ALTER TABLE public.pgnetwork ALTER COLUMN source TYPE int4;
#   --ALTER TABLE public.pgnetwork ALTER COLUMN target TYPE int4;


#Creation of topology, reformatting multilines, checking and fixing of the network
#algorithm uses edges, not exclusively the nodes
#Creates Topology, checks and removes multilines,
#Then it checks the network for gaps, if there are gaps/dead ends((SAVE ANALYSIS RESULTS?)), etc, makes a new network called project.tbl_workset_noded
#If a new network has been created it stores the new one over the old (topology)
#vertices do exist, are stored in project.tbl_workset_vertices_pgr
#needs to be split up
# 
# db_topo = function(db_name){
# 
#   sql_query = "SELECT pgr_createTopology('project.tbl_workset', 0.0001, 'the_geom', 'gid');
#   SELECT COUNT(CASE WHEN ST_NumGeometries(the_geom) > 1 THEN 1 END) AS multi, COUNT(the_geom) AS total FROM project.tbl_workset;
#   ALTER TABLE project.tbl_workset ALTER COLUMN the_geom TYPE geometry(LineString, 4326) USING ST_GeometryN(the_geom, 1);
#   SELECT pgr_analyzegraph('project.tbl_workset', 0.001, the_geom:='the_geom', id:='gid', source:='source', target:='target');
#   SELECT pgr_nodenetwork('project.tbl_workset', 0.001, 'gid', 'the_geom', 'noded');
#   SELECT pgr_createtopology('project.tbl_workset_noded', 0.001);"
#   }

#comparison_id = function(db_name){ 
#comparing the id's of the noded workset (that doesn't have the old data)
#SELECT old_id, sub_id FROM project.tbl_workset_noded ORDER BY old_id, sub_id;


# CREATE TABLE myroute as SELECT seq, id1 AS node, id2 AS edge, cost, the_geom
# FROM pgr_dijkstra(
#   'SELECT id, source, target, st_length(the_geom) AS cost FROM public.pgnetwork',
#   11, 9, false, false
# ) as di
# JOIN public.pgnetwork
# ON di.id2 = public.pgnetwork.id
