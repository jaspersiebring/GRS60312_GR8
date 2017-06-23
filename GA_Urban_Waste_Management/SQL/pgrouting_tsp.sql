--SELECT Find_SRID('workset333', 'tbl_workset', 'the_geom');
--SELECT UpdateGeometrySRID('tbl_workset', 'the_geom', 4326);
--UPDATE workset333.tbl_workset SET the_geom = ST_Transform(the_geom,4326);

--dbSendQuery(con, "SELECT UpdateGeometrySRID('a4_blockades', 'geom', 4326);")
-- 
--ALTER TABLE workset333.tbl_workset SET SCHEMA public;
--SELECT UpdateGeometrySRID('tbl_workset', 'the_geom', 4326);
-- SELECT seq, id1, id2, round(cost::numeric, 2) AS cost
--FROM pgr_tsp('SELECT id::integer, st_x(the_geom) as x,st_x(the_geom) as y FROM edge_table_vertices_pgr  ORDER BY id', 6, 5);



--SELECT dmatrix, ids from pgr_makeDistanceMatrix('SELECT id, st_x(the_geom) AS x, st_y(the_geom) AS y FROM public.pgnetwork_vertices_pgr');
-- SELECT seq, id FROM pgr_tsp('{{0,1,2,3},{1,0,4,5},{2,4,0,6},{3,5,6,0}}'::float8[],1);


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
--         'SELECT id, source, target, cost, reverse_cost FROM pgnetwork',
--         (SELECT array_agg(id) FROM pgnetwork_vertices_pgr WHERE id < 14),
--         directed := false)", 7);
-- 


