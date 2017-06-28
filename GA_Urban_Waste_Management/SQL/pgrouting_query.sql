
-- CREATING A ROUTABLE ROAD NETWORK

--     Use pgr_createVerticesTable to create the vertices table.
--     Use pgr_createTopology to create the topology and the vertices table.


--ALTER TABLE workset333.tbl_workset add column source integer;
--ALTER TABLE workset333.tbl_workset add column target integer;
--SELECT pgr_createTopology('workset333.tbl_workset', 0.0001, 'the_geom', 'gid');

-- --checking multiline
-- SELECT COUNT(
--         CASE WHEN ST_NumGeometries(the_geom) > 1 THEN 1 END
--     ) AS multi, COUNT(the_geom) AS total 
-- FROM workset333.tbl_workset;

--if multiline = 0, change geometry type
-- ALTER TABLE workset333.tbl_workset
--     ALTER COLUMN the_geom TYPE geometry(LineString, 4326) 
--     USING ST_GeometryN(the_geom, 1);


--vertices/nodes do exist, following table: NOT ACTUAL STEP, algorithm uses edges
--SELECT * FROM workset333.tbl_workset_vertices_pgr;

--check network for gaps, intersections and dead ends (SAVE ANALYSIS RESULTS?)
--SELECT pgr_analyzegraph('workset333.tbl_workset', 0.001, the_geom:='the_geom', id:='gid', source:='source', target:='target');

--FIXES the gaps, intersections and dead ends in a new file
--SELECT pgr_nodenetwork('workset333.tbl_workset', 0.001, 'gid', 'the_geom', 'noded');

--comparing the id's of the noded workset (that doesn't have the old data)
--SELECT old_id, sub_id FROM workset333.tbl_workset_noded ORDER BY old_id, sub_id;

--use this new node network to create topology
--SELECT pgr_createtopology('workset333.tbl_workset_noded', 0.001);



---ACTUAL MYROUTE CALC
create table myroute as SELECT seq, id1 AS node, id2 AS edge, cost, the_geom
  FROM pgr_dijkstra(
    'SELECT gid AS ID, source, target, st_length(the_geom) AS cost FROM pgnetwork',
    3000, 2000, false, false
  ) as di
  JOIN pgnetwork
  ON di.id2 = pgnetwork.gid

--Try it using pgnetwork


-- CREATE TABLE dummy2 AS SELECT
-- cast(t1.zid as integer) AS orig_id,
-- cast(t2.zid as integer) AS dest_id,
-- ABS(RANDOM()*(45-2)-45) AS dist
-- FROM dummy t1, dummy t2;
-- 
-- dbSendQuery(con, "ALTER TABLE public.pgnetwork ADD column blockage boolean;")
--   
-- 


--INSERT INTO 

--create table myroute(seq int4, node int4, edge integer, cost float8, the_geom geometry(1107460));


--create table if not exists myroute(seq int4, node int4, edge integer, cost float8, the_geom geometry(LineString,43260));

--FIX MULTILINE

--SELECT COUNT(CASE WHEN ST_NumGeometries(the_geom) > 1 THEN 1 END) AS multi, COUNT(the_geom) AS total FROM public.pgnetwork;

--CHANGE DATATYPES
--ALTER TABLE public.pgnetwork ALTER COLUMN the_geom TYPE geometry(LineString, 4326) USING ST_GeometryN(the_geom, 1); 
--ALTER TABLE public.pgnetwork ALTER COLUMN source TYPE int4;
--ALTER TABLE public.pgnetwork ALTER COLUMN target TYPE int4;
 



--6207/1670, 5838/1573
-- CREATE TABLE myroute as SELECT seq, id1 AS node, id2 AS edge, cost, the_geom
-- FROM pgr_dijkstra(
--     'SELECT id, source, target, st_length(the_geom) AS cost FROM public.pgnetwork',
--     11, 9, false, false
--   ) as di
--   JOIN public.pgnetwork
--   ON di.id2 = public.pgnetwork.id

--int4
--::int4
--float8
--ALTER TABLE test ALTER COLUMN id  TYPE integer USING (id::integer);

--TYPE int4


--EITHER alter length or add trigger to update length
-- ALTER TABLE network ADD COLUMN shape_leng double precision;
-- UPDATE network SET shape_leng = length(the_geom);
-- 
-- CREATE OR REPLACE FUNCTION shape_leng() RETURNS trigger AS
-- $BODY$BEGIN
--   NEW.shape_leng := ST_Length(NEW.the_geom);
--   RETURN NEW;
-- END;$BODY$ LANGUAGE plpgsql;
-- 
-- CREATE TRIGGER network_shape_leng
--   BEFORE INSERT OR UPDATE ON network
--   FOR EACH ROW EXECUTE PROCEDURE shape_leng();



--select source as closest to depot
-- select source from hh_2po_4pgr order by st_distance(geom_way, 
-- st_setsrid(st_makepoint(-71.120328, 42.327462), 4326)) limit 1;
-- 
-- select target from hh_2po_4pgr order by st_distance(geom_way, 
-- st_setsrid(st_makepoint(-71.060934, 42.358421), 4326)) limit 1;




