##Script name :GA_b1_tsp_route_calculation.R
##Description :Exports all the SpatialDataFrames to shapefiles
##Packages    : 
##Output table: 
##Attribute   : 
##Database    : SWMS_database
##Creator     : Jasper Siebring
##Date        : June 23, 2017
##Organization: Wageningen University UR


#Export all data to shapefiles
export_all = function(list_obj, save_path){
  save_path = './Export'
  lst = list(sdf_network, sdf_truck, sdf_bins, sdf_vertices, sdf_blockades, sdf_routes)
  for (i in lst){
    writeOGR(lst[[i]], dsn = save_path, driver = 'ESRI Shapefile', layer = quote(lst[[i]])
    } 



#writeOGR(sdf_truck, dsn = './Export', driver = 'ESRI Shapefile', layer = 'truck_layer')
#writeOGR(sdf_bins, dsn = './Export', driver = 'ESRI Shapefile', layer = 'bin_layer')
#writeOGR(sdf_vertices, dsn = './Export', driver = 'ESRI Shapefile', layer = 'vertices_layer')
#writeOGR(sdf_blockades, dsn = './Export', driver = 'ESRI Shapefile', layer = 'blockades_layer')
#writeOGR(sdf_routes, dsn = './Export', driver = 'ESRI Shapefile', layer = 'routes_layer')


#sdf_network = pgGetGeom(con, name = c("public", "pgnetwork"), geom = "the_geom", gid = 'gid')
#sdf_truck = pgGetGeom(con, name = c("public", "a2_truck_properties"), geom = "the_geom")
#sdf_bins = pgGetGeom(con, name = c("public", "a1_bin_properties"), geom = "the_geom")
#sdf_vertices = pgGetGeom(con, name = c("public", "pgnetwork_vertices_pgr"), geom = "the_geom", gid = 'id')
#sdf_blockades = pgGetGeom(con, name = c("public", "a4_blockades"), geom = "geom", gid = 'gid')
#sdf_routes = pgGetGeom(con, name = c("public", "pgroutes"), geom = "the_geom")
