SELECT * FROM pgr_TSP($$SELECT * FROM pgr_dijkstraDMatrix('SELECT id, source, target, cost, reverse_cost FROM edge_table', (SELECT array_agg(id) from edge_table_vertices_pgr WHERE id IN (2, 3, 4, 9, 5, 12, 11, 10)), false)$$, 5, randomize := false);

SELECT * FROM pgr_dijkstraCostMatrix('SELECT id, source, target, cost, reverse_cost FROM edge_table',(SELECT array_agg(id) FROM edge_table_vertices_pgr ), false);


SELECT * FROM pg_proc WHERE proname LIKE 'pgr_dijkstra%';

--EUCLIDEAN
SELECT * from pgr_eucledianTSP($$
    SELECT id, st_X(the_geom) AS x, st_Y(the_geom) AS y FROM edge_table_vertices_pgr WHERE id IN (2, 3, 4, 9, 5, 12, 11, 10)  
    $$, start_id := 5, max_processing_time := 100,
    randomize := false);


--USING NETWORK
SELECT * FROM pgr_TSP(
    $$
    SELECT * FROM pgr_dijkstraCostMatrix(
        'SELECT id, source, target, cost, reverse_cost FROM edge_table',
        (SELECT array_agg(id) FROM edge_table_vertices_pgr WHERE id IN (2, 3, 9, 5, 12, 10)),
        false
    )
    $$,
    start_id :=5,
    randomize := false
);

pgr_withpoints
pgr_withpointsvia
pgr_pointstodmatrix
pgr_pointstovids
pgr_withpointscostmatrix

SELECT node FROM tsp_costs ORDER BY seq;

--1: Select pgr_tsp, order via pg_dijkstraCostMatrix, use this to calculate the ordered id input for DijkstraVia
SELECT * FROM pgr_dijkstraVia(
    'SELECT id, source, target, cost, reverse_cost FROM edge_table order by id',
    ARRAY[1, 5, 3, 9, 4]
);

--2: Use Points with TSP

SELECT * FROM pgr_TSP(
    $$
    SELECT * FROM pgr_withPointsDMatrix(
        'SELECT id, source, target, cost, reverse_cost FROM edge_table ORDER BY id',
        'SELECT pid, edge_id, fraction from pointsOfInterest',
        array[-1, 3, 5, 6, -6], directed := false);
    $$,
    start_id := 5,
    randomize := false
);





--Points of Interest approach


(SELECT the_geom FROM a1_bin_properties WHERE gid = 1)


SELECT * FROM pgnetwork r
ORDER BY the_geom <#> ST_GeomFromText('POINT(-122.206111 47.983056)')
LIMIT 1;



CREATE TABLE node_route AS SELECT node from pgr_eucledianTSP(
  $$SELECT id, st_X(the_geom) AS x, st_Y(the_geom) AS y FROM edge_table_vertices_pgr 
  $$, start_id := 5, max_processing_time := 100, randomize := false);

(SELECT array_agg(node) FROM node_route);

SELECT node FROM node_route;

(SELECT array_agg(node) FROM node_route)

SELECT * FROM pgr_dijkstraVia(
    'SELECT id, source, target, cost, reverse_cost FROM edge_table order by id',
    ARRAY[5, 8, 7, 13], false, strict:=true, U_turn_on_edge:=false
);

SELECT the_geom <#> (SELECT the_geom FROM a1_bin_properties 


-----------------------
--SELECT THE CLOSEST EDGE TO IDS
CREATE TABLE poi_table AS SELECT gid AS edge_id FROM pgnetwork r
ORDER BY the_geom <#> (SELECT the_geom FROM a1_bin_properties WHERE gid = 1)
LIMIT 1;

ALTER TABLE poi_table ADD COLUMN the_geom geometry 
SELECT * FROM poi_table;

INSERT INTO poi_table  
SELECT the_geom FROM a1_bin_properties WHERE gid = 1

SELECT * FROM pgnetwork r
ORDER BY the_geom <#> (SELECT the_geom FROM a1_bin_properties WHERE gid = 1)
LIMIT 1;
