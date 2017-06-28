--TSP_Euclidean with looped Dijkstra approach 


--Use EucledianTSP to get the order (of pairs)
(SELECT * from pgr_eucledianTSP($$
    SELECT id, st_X(the_geom) AS x, st_Y(the_geom) AS y FROM edge_table_vertices_pgr WHERE id IN (8, 10, 3, 4, 9 , 12)    
    $$, start_id := 8, max_processing_time := 100,
    randomize := false));

node_vector = c(1231, 322)


  CREATE TABLE IF NOT EXISTS sum_route (seq int4, node int4, edge integer, cost float8, the_geom geometry, timestamp timestamptz)
  

  CREATE TABLE temp_route AS SELECT seq, id1 AS node, id2 AS edge, cost, the_geom, now() date FROM pgr_dijkstra('SELECT gid AS ID, source, target, st_length(the_geom) AS cost FROM public.pgnetwork', 8, 10, false, false) as di
  JOIN public.pgnetwork ON di.id2 = public.pgnetwork.gid))
  
  INSERT INTO pgroutes SELECT * FROM temp_route;
  DROP TABLE IF EXISTS temp_route
}



CREATE TABLE sum_route as SELECT seq, id1 AS node, id2 AS edge, cost, the_geom
FROM pgr_dijkstra(
    'SELECT id, source, target, cost FROM edge_table',
    8, 10, false, false
  ) as di
  JOIN edge_table
  ON di.id2 = edge_table.id




SELECT * FROM pgr_dijkstra(
    'SELECT id, source, target, cost, reverse_cost FROM edge_table',
    8, 10
);




 




--General helpful comments/functions
--DijkstaCostMatrix will produce Infinity values without WHERE id IN (2, 3, 9, 5, 12, 10)
SELECT * FROM pg_proc WHERE proname LIKE 'pgr_dijkstra%';
SELECT node FROM tsp_costs ORDER BY seq;
WHERE id IN (2, 3, 4, 9, 5, 12, 11, 10)

