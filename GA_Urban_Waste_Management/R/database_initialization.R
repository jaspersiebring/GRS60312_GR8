#GA_Urban_Waste_Management
#Team Garbage

#21st of June 2017

#far from final, will change considerably later on

#Function that initializes the SWMS database (assuming its prebuilt using the pgRouting template and holds the restored Jewel backup file)
db_init = function(db_name){
  if (db_name == 'SWMS_database'):
    sql_query = 'ALTER TABLE workset333.tbl_streets SET SCHEMA public; ALTER TABLE workset333.tbl_navteq SET SCHEMA public; ALTER TABLE workset333.tbl_workset SET SCHEMA public; ALTER TABLE public.tbl_workset add column source integer; ALTER TABLE public.tbl_workset add column target integer; ALTER SCHEMA workset333 RENAME TO jewel_data;'
    dbSendQuery(con, sql_query)
}

#Creation of topology, reformatting multilines, checking and fixing of the network
#algorithm uses edges, not exclusively the nodes
#Creates Topology, checks and removes multilines,
#Then it checks the network for gaps, if there are gaps/dead ends((SAVE ANALYSIS RESULTS?)), etc, makes a new network called project.tbl_workset_noded
#If a new network has been created it stores the new one over the old (topology)
#vertices do exist, are stored in project.tbl_workset_vertices_pgr

db_topo = function(db_name){
      dbClearResult(con)
      close_me = dbSendQuery(con, sql_query)
      postgresqlCloseResult(close_me, force = T)
      #needs to be split up 
      sql_query = "SELECT pgr_createTopology('project.tbl_workset', 0.0001, 'the_geom', 'gid');
      SELECT COUNT(CASE WHEN ST_NumGeometries(the_geom) > 1 THEN 1 END) AS multi, COUNT(the_geom) AS total FROM project.tbl_workset;
      ALTER TABLE project.tbl_workset ALTER COLUMN the_geom TYPE geometry(LineString, 4326) USING ST_GeometryN(the_geom, 1);
      SELECT pgr_analyzegraph('project.tbl_workset', 0.001, the_geom:='the_geom', id:='gid', source:='source', target:='target');
      SELECT pgr_nodenetwork('project.tbl_workset', 0.001, 'gid', 'the_geom', 'noded');
      SELECT pgr_createtopology('project.tbl_workset_noded', 0.001);"
      }


#comparing the id's of the noded workset (that doesn't have the old data)
#SELECT old_id, sub_id FROM project.tbl_workset_noded ORDER BY old_id, sub_id;

