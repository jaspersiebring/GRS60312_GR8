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
  #Checks what nodes to visit based on boolean in pgnetwork_vertices_pgr and truck_start node
  visit_nodes = dbGetQuery(con, "SELECT id AS node FROM pgnetwork_vertices_pgr where binid = 1;")
  start_id = dbGetQuery(con, "SELECT node FROM a2_truck_properties;")
  visit_nodes = append(visit_nodes[[1]], start_id$node)
  
  #Creates a usable SQL string from bin input
  sql = "("
  for (i in 1:length(visit_nodes)){
    sql = paste0(sql, paste0(as.character(visit_nodes[[i]]), ", "))}
  sql = substr(sql, 1, (nchar(sql) -2)) 
  sql = paste0(sql, ")")
  
  #Creates the main route_table called tsp_routes
  dbSendQuery(con, "CREATE TABLE IF NOT EXISTS tsp_routes(node int4, edge bigint, d_agg_cost float8, parent_id bigint, length float8, the_geom geometry, timestamp timestamptz, real_cost float8);")
  
  dbSendQuery(con, "CREATE TABLE temp_routes(node int4, edge bigint, d_agg_cost float8, parent_id bigint, length float8, the_geom geometry, timestamp timestamptz, real_cost float8);")
  
  #Calculates the order of nodes, i.e. bins, so these have to be change (paste0) and creates pairs of nodes
  eucl_order = dbGetQuery(con, paste0("(SELECT node from pgr_eucledianTSP($$SELECT id, st_X(the_geom) AS x, st_Y(the_geom) AS y FROM pgnetwork_vertices_pgr WHERE id IN ", sql, "$$, start_id := ", start_id, ", max_processing_time := 100, randomize := false));"))
  
  x = eucl_order$node
  x = x[1:(length(x)-1)]
  y = eucl_order$node
  y = y[2:length(y)]
  pairs = cbind(x, y)
  
  costs = 0
  for (i in 1:length(pairs[,1])){ 
    source = pairs[i,][1] 
    target = pairs[i,][2]
    
    #Drops table temp_result just in  case
    dbSendQuery(con, "DROP TABLE IF EXISTS temp_result CASCADE;")
    dbSendQuery(con, "DROP TABLE IF EXISTS route_seg CASCADE;")
    
    #Create route_segments
    dbSendQuery(con, paste0("CREATE TABLE temp_result AS SELECT seq, path_seq, node::integer, edge, agg_cost AS d_agg_cost FROM pgr_dijkstra('SELECT gid AS id, source, target, cost, rcost FROM pgnetwork WHERE NOT blockage', ", source, ", ", target, ", FALSE);"))
    dbSendQuery(con, "CREATE TABLE route_seg AS SELECT node, edge, d_agg_cost, parent_id, length, the_geom FROM temp_result AS di JOIN public.pgnetwork ON di.edge = pgnetwork.gid;")
    
    dbSendQuery(con, "ALTER TABLE route_seg ADD COLUMN timestamp timestamptz;")
    dbSendQuery(con, "ALTER TABLE route_seg ADD COLUMN real_cost float8;")
    
    temp_cost = dbGetQuery(con, "SELECT max(d_agg_cost) FROM route_seg")
    temp_cost = temp_cost$max
    costs = (costs + temp_cost)                   
    
    dbSendQuery(con, "UPDATE route_seg SET timestamp = (SELECT max(timestamp) FROM a5_bin_fill_history WHERE addedwaste = 0 AND fillpercentage = 0)")
    dbSendQuery(con, paste0("UPDATE route_seg SET d_agg_cost = ", temp_cost))
    
    dbSendQuery(con, "INSERT INTO temp_routes SELECT * FROM route_seg;")
    dbSendQuery(con, "DROP TABLE IF EXISTS route_seg CASCADE;")
    dbSendQuery(con, "DROP TABLE IF EXISTS temp_result CASCADE;")
  
  }
  dbSendQuery(con, paste0("UPDATE temp_routes SET real_cost = ", costs))
  dbSendQuery(con, paste0("INSERT INTO tsp_routes SELECT * FROM temp_routes"))
  dbSendQuery(con, "DROP TABLE IF EXISTS temp_routes CASCADE")
}

  

