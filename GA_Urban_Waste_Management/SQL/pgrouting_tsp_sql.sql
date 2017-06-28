--Euclidean Distance

------EXAMPLE WITH SAMPLE DATA
--JOIN the result to a line
CREATE TABLE tsp_costs AS SELECT * from pgr_eucledianTSP($$
    SELECT id, st_X(the_geom) AS x, st_Y(the_geom) AS y FROM edge_table_vertices_pgr WHERE id IN (2, 3, 4, 9, 5, 12, 11, 10)  
    $$, start_id := 5, max_processing_time := 100,
    randomize := false);

-- CREATION of edge_routes table
CREATE TABLE tsp_routes AS SELECT * FROM edge_table WHERE
	((source = 5 AND target = 10) OR (source = 5 AND target = 10)) OR 
	((source = 10 AND target = 11) OR (source = 11 AND target = 10)) OR 
	((source = 12 AND target = 11) OR (source = 11 AND target = 12)) OR 
	((source = 12 AND target = 9) OR (source = 9 AND target = 12)) OR
	((source = 9 AND target = 4) OR (source = 4 AND target = 9)) OR
	((source = 4 AND target = 3) OR (source = 3 AND target = 4)) OR
	((source = 3 AND target = 2) OR (source = 2 AND target = 3)) OR
	((source = 5 AND target = 2) OR (source = 2 AND target = 5)); 

-----REAL APPLICATION

DROP TABLE IF EXISTS tsp_cost;
CREATE TABLE tsp_costs AS SELECT * from pgr_eucledianTSP($$
    SELECT id, st_X(the_geom) AS x, st_Y(the_geom) AS y FROM pgnetwork_vertices_pgr WHERE id IN (8480, 1318, 5147, 9185, 205, 3903)  
    $$, start_id := 9185, max_processing_time := 10000,
    randomize := false);


SELECT * from pgr_eucledianTSP($$
    SELECT id, st_X(the_geom) AS x, st_Y(the_geom) AS y FROM pgnetwork_vertices_pgr WHERE id IN (8480, 1318, 5147, 9185, 205, 3903)  
    $$, start_id := 9185, max_processing_time := 10000,
    randomize := false);




