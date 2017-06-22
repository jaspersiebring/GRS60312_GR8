#GA_Urban_Waste_Management
#Team Garbage

#22nd of June 2017

#adds source/target columns
#Function that initializes the SWMS database (assuming its prebuilt using the pgRouting template and holds the restored Jewel backup file)
db_init = function(con, db_name){
  if (db_name == 'SWMS_database')
    sql_query = paste('ALTER TABLE workset333.tbl_streets SET SCHEMA public;',
                      'ALTER TABLE workset333.tbl_navteq SET SCHEMA public;',
                      'ALTER TABLE workset333.tbl_workset SET SCHEMA public;',
                      'ALTER TABLE public.tbl_workset add column source integer;',
                      'ALTER TABLE public.tbl_workset add column target integer;',
                      'ALTER SCHEMA workset333 RENAME TO jewel_data;')
    dbSendQuery(con, sql_query)
}

#Checks the initial network, converts it to singlelines (for pganalysis), after analysis the network' flaws are fixed in pgNetwork and topology are made from that network 
create_pgnetwork_and_pgvertices = function(con){
  chck_multiline = dbGetQuery(con, "SELECT COUNT(CASE WHEN ST_NumGeometries(the_geom) > 1 THEN 1 END) AS multi, COUNT(the_geom) AS total FROM public.tbl_workset;")
  if (chck_multiline$multi == 0){
  dbSendQuery(con, "ALTER TABLE public.tbl_workset ALTER COLUMN the_geom TYPE geometry(LineString, 4326) USING ST_GeometryN(the_geom, 1);")} 

  #Creates initial topology, public.tbl_workset_vertices_pgr
  #sp_topology = dbExecute(con, "SELECT pgr_createTopology('public.tbl_workset', 0.0001, 'the_geom', 'gid');")

  #Analyses the network (needs both vertices and network) for gaps, intersections and dead ends 
  #sp_analysis = dbGetQuery(con, "SELECT pgr_analyzegraph('public.tbl_workset', 0.001, the_geom:='the_geom', id:='gid', source:='source', target:='target');")

  #If analysis has shown that a new network is needed, this is execute and initially called public.tbl_workset.noded
  temp_sql_result = dbExecute(con, "SELECT pgr_nodenetwork('public.tbl_workset', 0.001, 'gid', 'the_geom', 'noded');")

  #You would still need to join the old network columns to this new network (left join, old.id > new.id
  #join while it still exists, gets deleted at the end of this script
  
  #Using the 'new' network to create topology
  temp_sql_result = dbExecute(con, "SELECT pgr_createtopology('public.tbl_workset_noded', 0.001);")

  #Analyse the new network
  #sp_analysis = dbGetQuery(con, "SELECT pgr_analyzegraph('public.tbl_workset_noded', 0.001, the_geom:='the_geom', id:='id', source:='source', target:='target');")

  #Changes the names of the 'clean' network and its vertices that'll be used in pgRouting
  dbSendQuery(con, "ALTER TABLE public.tbl_workset_noded RENAME TO pgnetwork;")
  dbSendQuery(con, "ALTER TABLE tbl_workset_noded_vertices_pgr RENAME TO pgvertices;")
  
  #Adds the blockage boolean to routing network table
  dbSendQuery(con, "ALTER TABLE public.pgnetwork ADD column blockage boolean;")
  
  #Deletes the public.tbl_workset and, if there, public.tbl_workset_vertices_pgr fi
  dbSendQuery(con, "DROP TABLE IF EXISTS public.tbl_workset;")
  dbSendQuery(con, "DROP TABLE IF EXISTS public.tbl_workset_vertices_pgr;")
}


#Creates a geom_table called pgroutes that holds the calculated route(s) which is still based on Dijkstra
#Source and Target is still fixed
create_pgroutes = function(con){ 
  
  #Extremely important, won't work otherwise
  --CHANGE DATATYPES
  --ALTER TABLE public.pgnetwork ALTER COLUMN the_geom TYPE geometry(LineString, 4326) USING ST_GeometryN(the_geom, 1); 
  --ALTER TABLE public.pgnetwork ALTER COLUMN source TYPE int4;
  --ALTER TABLE public.pgnetwork ALTER COLUMN target TYPE int4;
  
   dbSendQuery(con, paste0("create table pgroutes as SELECT seq, id1 AS node, id2 AS edge, cost, the_geom ",
                                          "FROM pgr_dijkstra('SELECT id AS ID, source, target, st_length(the_geom) AS cost FROM public.pgnetwork',",
                                          " 3000, 2000, false, false) as di",
                                          " JOIN public.pgnetwork",
                                          " ON di.id2 = public.pgnetwork.id"))
}



CREATE TABLE myroute as SELECT seq, id1 AS node, id2 AS edge, cost, the_geom
FROM pgr_dijkstra(
  'SELECT id, source, target, st_length(the_geom) AS cost FROM public.pgnetwork',
  11, 9, false, false
) as di
JOIN public.pgnetwork
ON di.id2 = public.pgnetwork.id











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












