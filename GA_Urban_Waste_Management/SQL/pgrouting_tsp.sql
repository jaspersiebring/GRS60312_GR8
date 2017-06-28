
--USING ONLY CLIPPED IDS
-- ALTER TABLE clipped_network ALTER COLUMN source TYPE integer;
-- ALTER TABLE clipped_network ALTER COLUMN target TYPE integer;
-- SELECT pgr_createTopology('public.clipped_network', 0.0001, 'geom', '__gid');
-- 
-- --only make topology of routes in research areas
-- pgr_createTopology('public.pgnetwork',rows_where:='gid IN (SELECT __gid FROM clipped_network)');

 



--SELECT Find_SRID('workset333', 'tbl_workset', 'the_geom');
--SELECT UpdateGeometrySRID('tbl_workset', 'the_geom', 4326);
--UPDATE workset333.tbl_workset SET the_geom = ST_Transform(the_geom,4326);

--dbSendQuery(con, "SELECT UpdateGeometrySRID('a4_blockades', 'geom', 4326);")
-- 
--ALTER TABLE workset333.tbl_workset SET SCHEMA public;
--SELECT UpdateGeometrySRID('tbl_workset', 'the_geom', 4326);
-- SELECT seq, id1, id2, round(cost::numeric, 2) AS cost
--FROM pgr_tsp('SELECT id::integer, st_x(the_geom) as x,st_x(the_geom) as y FROM edge_table_vertices_pgr  ORDER BY id', 6, 5);




--SELECT round(sum(cost)::numeric, 4) as cost
--FROM pgr_tsp('SELECT id::integer, st_x(the_geom)::float8 AS x, st_y(the_geom) AS y, st_length(the_geom) FROM public.pgnetwork_vertices_pgr WHERE id IN (2, 3000, 2000)  ORDER BY id', 6);

-- 
-- select * from pgr_eucledianTSP( 
--    'select id, st_x(the_geom)::float8 as x, st_y(the_geom)::float8 as y from pgnetwork_vertices_pgr where id in (4540, 2547, 2570, 300, 4200)' 
-- ); 
-- 



-----EITHER CHECK OUT HOW YOU ADD THE UPDATED PGROUTING PACKAGE OR SOLVE THE CONANCATING STRING
--ALTER TABLE pgnetwork_vertices_pgr ALTER COLUMN id SET DATA TYPE integer;
--SELECT * FROM pgr_tsp('select id, st_x(the_geom)::float8 as x, st_y(the_geom)::float8 as y from pgnetwork_vertices_pgr where id in (4540, 2547, 2570, 300, 4200)', 6::integer);
--SELECT * FROM pgr_eucledianTSP('select id, st_x(the_geom)::float8 as x, st_y(the_geom)::float8 as y from pgnetwork_vertices_pgr where id in (4540, 2547, 2570, 300, 4200)');

-- 
-- SELECT * FROM pgr_tsp("SELECT * FROM pgr_dijkstraCostMatrix(
--         'SELECT id, source, target, cost FROM edge_table',
--         (SELECT array_agg(id) FROM pgnetwork_vertices_pgr WHERE id < 14),
--         directed := false)", 7);
-- 

-- SELECT * FROM pgr_TSP(SELECT * FROM pgr_dijkstraCostMatrix('SELECT id, source, target, cost FROM pgnetwork', (SELECT array_agg(id) FROM pgnetwork_vertices_pgr WHERE id < id), directijd := false
-- ), start_id :=7, randomize :=false);

-- 
-- SELECT seq, id1, id2, round(cost::numeric, 2) AS cost
-- FROM pgr_tsp('SELECT id::integer, st_x(the_geom) as x,st_x(the_geom) as y FROM pgnetwork_vertices_pgr where id in (4540, 2547, 2570, 300, 4200)  ORDER BY id', 6);
-- 


--Appears to work-- 
-- SELECT * FROM pgr_TSP($$SELECT * FROM pgr_dijkstraCostMatrix('SELECT gid as id, source, target, st_length(the_geom) AS cost FROM pgnetwork',
-- (SELECT array_agg(id) from pgnetwork_vertices_pgr WHERE id <14), false)$$, 1, randomize :=false);

--With own selected points(4540, 2547, 2570, 300, 4200)
-- CREATE TABLE tsp_route AS SELECT * FROM pgr_TSP($$ SELECT * FROM pgr_dijkstraCostMatrix('SELECT id, source, target, cost FROM edge_table',
-- (SELECT array_agg(id) from edge_table_vertices_pgr WHERE id < 14), directed := false)$$, start_id :=7, randomize := false) AS di
-- JOIN edge_table ON di.node = public.edge_table.id;


-- 


--ALTER TABLE edge_table RENAME COLUMN old_cost TO cost;

-- 
-- 
-- create table myroute as SELECT seq, id1 AS node, id2 AS edge, cost, the_geom
--   FROM pgr_dijkstra(
--     'SELECT gid AS id, source, target, st_length(the_geom) AS cost FROM public.tbl_workset',
--     3000, 2000, false, false
--   ) as di
--   JOIN public.tbl_workset
--   ON di.id2 = public.tbl_workset.gid
-- 


-- SELECT * FROM pgr_withPointsCostMatrix(
--     'SELECT id, source, target, old_cost, reverse_cost FROM edge_table ORDER BY id',
--     'SELECT pid, edge_id, fraction from pointsOfInterest',
--     array[12, 11, 10, 2, 3, 4, 9], directed := true);

--vidsToDMatrix 
DROP TABLE IF EXISTS mat_route;
CREATE TABLE mat_route AS SELECT seq, the_geom FROM pgr_tsp(
    (SELECT pgr_vidsToDMatrix(
        'SELECT id::INTEGER, source::INTEGER, target::INTEGER, cost, reverse_cost FROM edge_table',
        array[12, 11, 10, 2, 3, 4, 9],
        false, false, true)
    ),5) AS di 
    JOIN edge_table ON di.id = edge_table.id;


-- PointsCostMatrix REQUIRES POINTS OF INTEREST
SELECT * FROM pgr_TSP($$
    SELECT * FROM pgr_withPointsCostMatrix(
        'SELECT id, source, target, cost, reverse_cost FROM edge_table ORDER BY id',
        'SELECT pid, edge_id, fraction from pointsOfInterest',
        array[-1, 3, 6, -6], directed := false);
    $$,
    randomize := false

--DijkstraCostMatrix
 SELECT * FROM pgr_TSP($$ SELECT * FROM pgr_dijkstraCostMatrix('SELECT id, source, target, st_length(the_geom) AS cost FROM edge_table',
 (SELECT array_agg(id) from edge_table_vertices_pgr WHERE id in (12, 11, 10, 2, 3, 4, 9)), directed := TRUE)$$, start_id :=5, randomize := false) as di
 JOIN edge_table ON di.node = edge_table.id;

--THIS IS THE ONE
--COST should be set to false, no reverse cost (not directed)
DROP TABLE IF EXISTS false_tbl;
CREATE TABLE false_tbl AS SELECT * FROM pgr_dijkstraCostMatrix(
    'SELECT id, source, target, cost, reverse_cost FROM edge_table',
    (SELECT array_agg(id) FROM edge_table_vertices_pgr),
    false
);



DROP TABLE IF EXISTS false_tbl;
CREATE TABLE false_tbl AS SELECT * FROM pgr_TSP($$
SELECT * FROM pgr_dijkstraCostMatrix(
    'SELECT id, source, target, st_length(the_geom) AS cost, reverse_cost FROM edge_table',
    (SELECT array_agg(id) FROM edge_table_vertices_pgr),
    false
)$$, start_id :=5, randomize :=false);




CREATE TABLE POI_TBL AS SELECT seq,node,source, target,the_geom FROM pgr_TSP(
    $$
    SELECT * FROM pgr_withPointsCostMatrix(
        'SELECT id, source, target, cost, reverse_cost FROM edge_table ORDER BY id',
        'SELECT pid, edge_id, fraction from pointsOfInterest',
        array[-1, 3, 5, 6, -6], directed := false);
    $$,
    start_id := 5,
    randomize := false
) as di
JOIN edge_table on di.node = edge_table.id;




SELECT * FROM pgr_TSP($$SELECT * FROM pgr_withPointsDMatrix(
        'SELECT id, source, target, cost, reverse_cost FROM edge_table ORDER BY id',
        'SELECT pid, edge_id, fraction from pointsOfInterest',
        array[-1, 3, 5, 6, -6], directed := false);$$, start_id := 5, randomize := false);



CREATE TABLE POI_routes AS SELECT seq, node, agg_cost, id, dir, source, target, reverse_cost, category_id, the_geom FROM pgr_TSP($$ SELECT * FROM pgr_dijkstraCostMatrix('SELECT id, source, target, st_length(the_geom) AS cost FROM edge_table',
 (SELECT array_agg(pid) from pointsofinterest), directed := FALSE)$$, start_id :=5, randomize := false) as di
 JOIN edge_table ON di.node = edge_table.id;

ALTER TABLE POI_routes COLUMN NAME cost TO old_cost;


SELECT * FROM pointsofinterest;
SELECT * FROM edge_table_vertices_pgr;