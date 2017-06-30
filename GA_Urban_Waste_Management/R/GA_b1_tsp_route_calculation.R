##Script name :GA_b1_tsp_route_calculation.R
##Description :
##Packages    : 
##Output table: 
##Attribute   : 
##Database    : SWMS_database
##Creator     : Jasper Siebring
##Date        : June 23, 2017
##Organization: Wageningen University UR



#Calculates the shortest route between two nodes (node_vector) based on Dijkstra's algorithm and saves it as a table (pgroutes)
pgr_dijkstra_route = function(con, node_vector){
  #CREATE IF NOT EXISTS
  dbSendQuery(con, "CREATE TABLE IF NOT EXISTS public.pgroutes(seq int4, node int4, edge integer, cost float8, the_geom geometry, timestamp timestamptz);")
  node_source = node_vector[1]
  node_target = node_vector[2]
  dbSendQuery(con, paste0("CREATE TABLE temp_route AS SELECT seq, id1 AS node, id2 AS edge, cost, the_geom, now() date ",
                          "FROM pgr_dijkstra('SELECT gid AS ID, source, target, st_length(the_geom) AS cost FROM public.pgnetwork', ",
                          node_source, ", ", node_target, ", false, false) as di",
                          " JOIN public.pgnetwork",
                          " ON di.id2 = public.pgnetwork.gid"))
  dbSendQuery(con, "INSERT INTO pgroutes SELECT * FROM temp_route;")
  dbSendQuery(con, "DROP TABLE IF EXISTS temp_route")
}





pgr_tsp_route = function(con){
  
  #Creates the main route_table called tsp_routes
  dbSendQuery(con, "CREATE TABLE IF NOT EXISTS tsp_routes(node int4, edge bigint, d_agg_cost float8, parent_id bigint, length float8, the_geom geometry);")
  
  #Calculates the order of nodes, i.e. bins, so these have to be change (paste0) and creates pairs of nodes
  eucl_order = dbGetQuery(con, "(SELECT node from pgr_eucledianTSP($$SELECT id, st_X(the_geom) AS x, st_Y(the_geom) AS y FROM pgnetwork_vertices_pgr WHERE id IN (4363, 9185, 345, 4421, 4488, 448)$$, 
                          start_id := 9185, max_processing_time := 100, randomize := false));")
  
  x = eucl_order$node
  x = x[1:(length(x)-1)]
  y = eucl_order$node
  y = y[2:length(y)]
  pairs = cbind(x, y)
  
  for (i in 1:length(pairs[,1])){ 
    source = pairs[i,][1] 
    target = pairs[i,][2]
    
    #Drops table temp_result just in  case
    dbSendQuery(con, "DROP TABLE IF EXISTS temp_result;")
    
    #Create route_segments
    dbSendQuery(con, paste0("CREATE TABLE temp_result AS SELECT seq, path_seq, node::integer, edge, agg_cost AS d_agg_cost FROM pgr_dijkstra('SELECT gid AS id, source, target, cost, rcost FROM pgnetwork', ", source, ", ", target, ", FALSE);"))
    dbSendQuery(con, "DROP TABLE IF EXISTS route_seg;")
    dbSendQuery(con, "CREATE TABLE route_seg AS SELECT node, edge, d_agg_cost, parent_id, length, the_geom FROM temp_result AS di JOIN public.pgnetwork ON di.edge = pgnetwork.gid;")
    dbSendQuery(con, "INSERT INTO tsp_routes SELECT * FROM route_seg;")
    dbSendQuery(con, "DROP TABLE IF EXISTS route_seg;")
  }
  dbSendQuery(con, "ALTER TABLE tsp_routes ADD COLUMN IF NOT EXISTS  id bigserial;")
}
  







  

