##Comments_misc

#Spaghetti code for the re-noded network and other planned tasks:

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

#comparison_id = function(db_name){ 
#comparing the id's of the noded workset (that doesn't have the old data)
#SELECT old_id, sub_id FROM project.tbl_workset_noded ORDER BY old_id, sub_id;

##CREATION OF SOURCE NODE
# public.a2_truck_properties = SOURCE
# SELECT ST_AsText(ST_ClosestPoint(pt,line)) AS cp_pt_line,
# ST_AsText(ST_ClosestPoint(line,pt)) As cp_line_pt
# FROM (SELECT 'POINT(100 100)'::geometry As pt,
#       'LINESTRING (20 80, 98 190, 110 180, 50 75 )'::geometry As line
# ) As foo;
