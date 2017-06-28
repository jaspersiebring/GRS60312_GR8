CREATE TABLE fin_routes AS SELECT * FROM pgnetwork WHERE gid in (
(SELECT edge FROM pgr_dijkstraVia(
    'SELECT gid AS id, source, target, st_length(the_geom) AS cost FROM pgnetwork order by id',
    (SELECT array_agg(node) from pgr_eucledianTSP($$
    SELECT id, st_X(the_geom) AS x, st_Y(the_geom) AS y FROM pgnetwork_vertices_pgr WHERE id IN (9185, 448, 4363, 4488, 4421, 345)   
    $$, start_id := 9185, max_processing_time := 10,
    randomize := false)), false, strict:=false, U_turn_on_edge:=false
) WHERE edge >=0));    
