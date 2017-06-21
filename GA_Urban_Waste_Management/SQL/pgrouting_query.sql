


--select * from workset333.tbl_workset;
-- CREATING A ROUTABLE ROAD NETWORK

--CREATE OR REPLACE VIEW road_ext AS
--	SELECT *, ST_startpoint(the_geom), ST_endpoint(the_geom)
--	FROM workset333.tbl_workset;

-- CREATE TABLE network AS
-- 	SELECT a.*, b.id as start_id, c.id as end_id
-- 	FROM road_ext AS a
-- 		JOIN node AS b ON a.st_startpoint = b.the_geom
-- 		JOIN node AS c ON a.st_endpoint = c.the_geom



-- 
--     Use pgr_createVerticesTable to create the vertices table.
--     Use pgr_createTopology to create the topology and the vertices table.
-- 


--WORKS
--ALTER TABLE workset333.tbl_workset add column source integer;
--ALTER TABLE workset333.tbl_workset add column target integer;
--SELECT pgr_createTopology('workset333.tbl_workset', 0.0001, 'the_geom', 'gid');

-- 
-- --checking multiline
-- SELECT COUNT(
--         CASE WHEN ST_NumGeometries(the_geom) > 1 THEN 1 END
--     ) AS multi, COUNT(the_geom) AS total 
-- FROM workset333.tbl_workset;

--if multiline = 0, change geometry 
type
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



-- CREATION OF THE ACTUAL ROUTE
-- SELECT seq, id1 AS node, id2 AS edge, cost, the_geom
-- FROM pgr_dijkstra(
-- 'SELECT gid AS ID, source, target, st_length(the_geom) AS cost FROM workset333.tbl_workset',
-- 3000, 2000, false, false
-- ) AS di
-- JOIN workset333.tbl_workset r 
-- ON di.id2 = r.gid ;
-- 



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








