##Script name : GA_b4_execute_route.R
##Description : This script determines which bins needs to be emptied, link the location of this bins to network-nodes, 
##              change the network attribute variable which determines if the route needs to go through this node, 
##              empty the bins and put this information in the geodatabase.    
##Packages    : RPostgreSQL, sp, rpostgis
##Output table: b4_linked_bins
##              b4_bins_needs_to_be_emptied
##              b4_bins_to_empty
##Database    : SWMS_database
##Creator     : Bas Wiltenburg
##Date        : June 28, 2017
##Organization: Wageningen University UR


##### FUNCTION WHICH READS ALL THE DATA FROM THE GEODATABASE #####

read_data2 <- function(bin_capacity, con){
  #Read bin properties table
  BinData = dbReadTable(con, c('public', 'a1_bin_properties'))
  
  #Read scenario table
  scenario = dbReadTable(con, c('public', 'a3_scenario_variables'))
  
  #Save 'Factor_BinCapacity' from scenario table in variable
  bincapfact = scenario[scenario$variable_name == 'Factor_BinCapacity',]
  bincapfact_value = as.numeric(bincapfact$variable_value)
  
  #Multiply bin capacity variable with numbers of bins in scenario-table 
  bin_cap = bin_capacity * bincapfact_value
  
  # Read truck table
  df_truck= dbReadTable(con, c('public', 'a2_truck_properties'))
  
  # Extract truck capacity
  capacity_truck = as.numeric(df_truck[1,4])
  
  # Link all bins to a network node (spatial query)
  a <- dbSendQuery (con, "CREATE OR REPLACE VIEW b4_linked_bins AS
SELECT DISTINCT ON(bin_id) id, bin_id, ST_Distance(a1_bin_properties.the_geom, pgnetwork_vertices_pgr.the_geom)
FROM a1_bin_properties RIGHT JOIN pgnetwork_vertices_pgr 
ON ST_DWithin(a1_bin_properties.the_geom, pgnetwork_vertices_pgr.the_geom,0.001)
WHERE bin_id IS NOT NULL ORDER BY bin_id, st_distance ;")
  
  return(list(capacity_truck, bin_cap, BinData))
  
}

  
##### FUNCTION WHICH DETERMINE WHICH BINS NEEDS TO BE EMPTIED #####

collect_bins = function (df_bin_prop, bin_cap, capacity_truck){              # BinData #bin_cap, #capacity_truck
  count = 0
  count1 = 0
  count4=0
  
  # Read bin_fill_history table, needs to be done inside the function because of dynamic table!
  df_binfill = dbReadTable(con, c('public', 'a5_bin_fill_history'))
  
  # Order table based on binId
  df_binfill = df_binfill[order(df_binfill[, 1]) , ] 
  
  # Create an empty vector to store all the unique bin ID's in the database
  binlist = c()
  
  # Build a list with all unique bin ID's (binlist) 
  # All unique bins should have a own dataframe with their filling history. -->  
  # This is because some bins will be emptied more frequently then others, so you can't order the whole dataset on 'latest time'. 
  # To solve this, each bin will get his own dataframe with their fill and empty history
  for (id in 1:nrow(df_bin_prop)){
    count = count +1 
    # Check if binId in bin_properties table is in the unique binId-list
    if (df_bin_prop[count, 4] %in% binlist) {
    } else {
      count1 = count1 + 1
      var <- df_bin_prop[count,4]
      # If the binId of all the bins in the bin_properties table is not in the list, add it to the list
      binlist[[count1]] <- var
    }
  }
  
  # For each specific bin (in binlist), create an own dataframe with their filling history. 
  for (i in binlist) {
    count2 = 0
    count3 = 0
    count4=count4+1
    
    # Define unique names for all the dataframes representing the different bins
    name = paste0("Bin_", count4, sep = "")
    
    # Create an empty dataframe to store all data of a specific binId in a own dataframe
    empty_df1 = data.frame()
    
    # Loop trough the whole 'bin_fill_history table', if binId in binlist equals binId in bin_fill_history table, put all the attributes in the empty dataframe
    for (j in 1:nrow(df_binfill)){
      count2 = count2 +1
      if (i == df_binfill[count2,1]){ 
        count3 = count3 + 1
        empty_df1 = rbind(empty_df1 , df_binfill[j, ])
      }
    }
    # When all rows (with attributes) of a specific bin are added to the empty dataframe, assign the dataframe to a variable with unique name
    assign(name, empty_df1)
  }
  
  # List all the unique dataframes, consisting the data of the different bins
  list_df <- list(Bin_1,Bin_2, Bin_3,Bin_4,Bin_5,Bin_6,Bin_7,Bin_8,Bin_9,Bin_10,Bin_11,Bin_12)
  
  # Set all counters back to 0
  count=0
  count1 =0
  count2=0  
  count3=0
  
  # Create a new empty dataframe to add data representing a new time (when the bin is emptied)
  empty_df = data.frame()
  
  # Loop trough the list of dataframes (each dataframe consist of the data-history of a specific bin)
  for (df_in_list in list_df){
    count = count+1
    
    # New dataframes of bins (with added data), needs to have a unique variable name
    name = paste0("Bin_update_", count, sep = "")
    
    # Order the dataframe on date
    order_df = df_in_list[order(df_in_list[, 2]) , ]
    
    # Create a new dataframe which is only consisting of the last row (latest date) of the bin
    last_rows_df = tail(order_df, 1)
    
    # Calculate the amount of waste in bin in kilograms (convert percentage to kg)
    last_rows_df$kg_waste <- ((as.integer(last_rows_df[1,4])/100) * bin_cap)
    
    # Fill the empty dataframe with the new data
    empty_df = rbind(empty_df , last_rows_df)
    
    # Assign new dataframe of a specific bin to a new variable with unique name
    assign(name, empty_df)
  }
  
  # List all the unique dataframes representing different bins
  list_df_update <- list(Bin_update_1,Bin_update_2, Bin_update_3,Bin_update_4,Bin_update_5,Bin_update_6,Bin_update_7,Bin_update_8,Bin_update_9,Bin_update_10,Bin_update_11,Bin_update_12)
  
  # Merge all the dataframes in the list to one new dataframe again
  # 'Result' is a dataframe with all the bins and their latest fill percentage, also in kg
  result = Reduce(function(x, y) merge(x, y, all=TRUE), list_df_update)
  
  # Order this new dataframe on weight (fullest bins first in the dataframe)
  result = result[order(result[, 5], decreasing = TRUE) , ] 
  
  count6 = 0 
  # DEFINE WHICH BINS NEED TO BE EMPTIED #
  
  # Truck capacity before picking up any bin
  truck_cap_actual <- capacity_truck
  bins_to_empty <- list()
  for (f in 1:nrow(result)){
    # Assign the weight in kilo's of a bin to a variable
    weight <- as.numeric(result[f,5])
    # Check if this amount of waste still fits in the truck
    condition <- truck_cap_actual  - weight
    # If it fits in the truck, empty the bin
    if (condition > 0){
      count6 <- count6+1
      bin <- result[f,1]
      # Put this bin in a list (needs to be emptied and know by the network)
      bins_to_empty[count6] <- bin
      # recalculate the capacity of the truck
      truck_cap_actual = (truck_cap_actual - weight)
    }
  }
  return(bins_to_empty)
}



##### FUNCTION TELLS NETWORK WHICH BINS NEEDS TO BE EMPTIED #####

empty_bins <- function(ListEmptyBins, EmptyTime) {# =function10
  # Read bin_fill_history table, needs to be inside function because of dynamic table!
  df_binfill = dbReadTable(con, c('public', 'a5_bin_fill_history'))

  # Order table based on binId
  df_binfill = df_binfill[order(df_binfill[, 1]) , ] 
  
  # Loop through the 'ListEmptyBins' list, result of previous function!
  for (i in ListEmptyBins){
    # If bin needs to be emptied (is in list), make a subset of their data (from bin_filling_table) 
    if (i  %in% df_binfill[,1]){
      bin <- subset(df_binfill, binid == i)
      # Create a new dataframe which is only consisting of the last row (latest date) of the bin
      last_rows_df = tail(bin, 1)
      
      # Store the oldtime in a variable 
      oldtime = last_rows_df[1,2]
      
      # Calculating the new time (old time plus time-step variable)
      newtime = as.POSIXlt(oldtime)  + EmptyTime*60*60
      
      # Calculate number of rows in dataframe of the whole bin_fill_table (how much history?)
      number_of_rows = nrow(df_binfill)
      
      # New row is a number
      new_row = number_of_rows + 1
      
      # Assign binId to new row in dataframe all data
      df_binfill[new_row,1] = bin[1,1]
      
      # Assign new time to new row (= calculated newtime, column 2)
      df_binfill[new_row,2] = newtime
      
      # Assign the added amount of waste 
      df_binfill[new_row,3] = 0
      
      # Assign new fill percentage to new row (column 4)
      df_binfill[new_row,4] = 0
  }
  }
  # Order this new dataframe on binId
  df_binfill = df_binfill[order(df_binfill[, 1]) , ] 
  
  # Write results to geodatabase
  write_result = dbWriteTable(con, name = 'a5_bin_fill_history', value = df_binfill, row.names = FALSE, alter.names = TRUE, overwrite = TRUE)
}
  


##### FUNCTION TO CHANGE NETWORK BASED ON BINS NEED TO BE EMPTIED ####$#

store_empty_bins_in_network <- function (ListEmptyBins, BinData, con){
  
  # Read connection table
  linkedbins = dbReadTable(con, c('public', 'b4_linked_bins'))
  count = 0
  empty_df2 <- data.frame()
  # Loop through 12 unique bins in linkedbins
  for (j in 1:nrow(linkedbins)){
    # create new dataframe of all bins needs to be emptied, with their geometry data! (stored in BinData) 
    if (linkedbins[j,2]  %in% ListEmptyBins){
      count = count+1
      id <- (linkedbins[j,2])
      bin2 <- subset(BinData, bin_id == id)
      empty_df2 <- rbind(empty_df2, bin2)
  }
}
  # Compress dataframe (only geometry and bin_id)
  bins_needs_to_be_emptied <- data.frame("bin_id" = empty_df2$bin_id, "the_geom" = empty_df2$the_geom)
  # Drob tables which are dependent on b4_bins_needs_to_be_emptied
  b <- dbGetQuery(con, "DROP TABLE b4_bins_needs_to_be_emptied CASCADE ;")
  # Write dataframe to table on geodatabase
  write_result = dbWriteTable(con, name = 'b4_bins_needs_to_be_emptied', value = bins_needs_to_be_emptied, row.names = FALSE, alter.names = TRUE, overwrite = TRUE)
  # Assign geometry datatype to geodatabase attribute
  c <- dbGetQuery (con, "ALTER TABLE b4_bins_needs_to_be_emptied ALTER COLUMN the_geom TYPE geometry(Point, 4326) USING ST_SetSRID(the_geom, 4326);") 
  # Update network vertices table, set everyting to false (truck doesnt need to go here)
  d <- dbGetQuery (con, "UPDATE pgnetwork_vertices_pgr SET binid = '0';") 
  # Create table based on spatial join with bins needs to be emptied --> assign this bins to nodes of the network
  e <- dbSendQuery (con, "CREATE OR REPLACE VIEW b4_bins_to_empty AS 
  SELECT DISTINCT ON(bin_id) id, bin_id, ST_Distance(b4_bins_needs_to_be_emptied.the_geom, pgnetwork_vertices_pgr.the_geom)
  FROM b4_bins_needs_to_be_emptied RIGHT JOIN pgnetwork_vertices_pgr 
  ON ST_DWithin(b4_bins_needs_to_be_emptied.the_geom::geometry, pgnetwork_vertices_pgr.the_geom, 0.001)
  WHERE bin_id IS NOT NULL ORDER BY bin_id, st_distance ;")
  
  
  # Set nodes needs to be 'emptied' to 1 if it is is 'b4_bins_to_empty' table
  g <- dbGetQuery (con, "UPDATE pgnetwork_vertices_pgr
  SET binid = '1' WHERE id IN 
  (SELECT DISTINCT b4_bins_to_empty.id FROM b4_bins_to_empty 
  LEFT JOIN pgnetwork_vertices_pgr ON b4_bins_to_empty.id = pgnetwork_vertices_pgr.id);")
}










