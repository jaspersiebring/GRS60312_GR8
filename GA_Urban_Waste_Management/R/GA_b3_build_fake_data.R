##Script name : GA_b3_build_fake_data.R 
##Description : Each time this script is executed, it makes up fake data and adds it to the 'a5_bin_fill_history' table.
##              Two variables can be set inside this script: the bin capacity and the timestep between two runs
##Packages    : RPostgreSQL, sp, rpostgis 
##Output table: 'a5_bin_fill_history'
##Attribute   : n.a.
##Database    : SWMS_database 
##Creator     : Bas Wiltenburg
##Date        : June 26, 2017 
##Organization: Wageningen University UR 

read_data1 <- function (con, bin_capacity, timestep_of_binfilling_hours, SD_factor){
  #Read bin properties table
  AvgAddedWaste = dbReadTable(con, c('public', 'a1_bin_properties'))
  
  #Read scenario table
  scenario = dbReadTable(con, c('public', 'a3_scenario_variables'))
  
  #Save 'Factor_BinCapacity' from scenario table in variable
  bincapfact = scenario[scenario$variable_name == 'Factor_BinCapacity',]
  bincapfact_value = as.numeric(bincapfact$variable_value)
  
  #Save 'waste-decrease' from scenario table in variable
  wastedecrease = scenario[scenario$variable_name == 'Decrease_BinAvgAddedWaste',]
  sel_wastedec = as.numeric(wastedecrease$variable_value)
  
  # Multiply bin capacity variable with numbers of bins in scenario-table
  bin_cap = bin_capacity * bincapfact_value
  
  #Initialize timestep (in hours) for number of hours passing until next route calculation
  timestep = timestep_of_binfilling_hours
  
  # Convert average added value per day to average added value per hour
  AvgAddedWaste$bin_avg_added_waste = (AvgAddedWaste$bin_avg_added_waste/24)
  
  #Create standard deviation column in dataframe and calculate stdev per row
  AvgAddedWaste$sdev = (SD_factor * (AvgAddedWaste$bin_avg_added_waste))
  
  # Create timestep column in dataframe and add amount of waste based on time passed (hours) 
  # Take into account the 'decrease in waste scenario variable' (sel_wastedec)! 
  AvgAddedWaste$wastetimestep = (AvgAddedWaste$bin_avg_added_waste * timestep) * ((sel_wastedec /- 100) + 1 )
  
  # Order bin properties dataframe based on bin_id
  AvgAddedWaste = AvgAddedWaste[order(AvgAddedWaste[, 4]) , ] 
  
  return(list(AvgAddedWaste, sel_wastedec, bin_cap, timestep))
}


##### FUNCTION TO ADD FAKE DATA EACH TIME FUNCTION IS EXECUTED #####

bin_filling = function (df_bin_prop){
  count = 0
  count1 = 0
  count4=0
  
  # Read bin_fill_history table
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
  # Next, get for each dataframe (representing a specific bin) their latest fill percentage by ordering the time attribute and get the filling percentage of the latest row
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

  count=0
  count1 =0
  count2=0  
  count3=0
  
  # Create a new empty dataframe to add data (added waste, fill percentages) representing a new time
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
    
    # Store the oldtime in a variable 
    oldtime = last_rows_df[1,2]
    
    # Calculating the new time (old time plus time-step variable)
    newtime = as.POSIXlt(oldtime)  + timestep*60*60
    
    # Store last fill percentage in variable
    last_fill = last_rows_df[4]
    
    # Calculate the actual amount of waste in the bin (based on variable bin_cap)
    last_fill_kg = (last_fill/100) * bin_cap
    
    # Assign 'AvgAddedWaste$wastetimestep' (column 10) to a variable 
    avg = df_bin_prop[count, 10] 
    
    # Assign 'AvgAddedWaste$sdev' (column 9) to a variable
    sdev = df_bin_prop[count, 9] 
    
    # Introduce normal distribution and assign random value in this distribution to variable
    rand_fill = rnorm(n =1, mean =avg, sd = sdev)
    
    # Calculate number of rows in dataframe of the bin (how much history does this bin has?)
    number_of_rows = nrow(df_in_list)
    
    # New fake data should be stored in a new row
    new_row = number_of_rows + 1
    
    # Assign binId to new row in orignal dataframe (df_in_list)
    df_in_list[new_row,1] = df_in_list[number_of_rows,1]
    
    # Assign new time to new row (= calculated newtime, column 2)
    df_in_list[new_row,2] = newtime
    
    # Assign the added amount of waste 
    df_in_list[new_row,3] = rand_fill
    
    # Calculate new fill percentage 
    new_fill = ((last_fill_kg + rand_fill)/bin_cap)*100
    
    # Assign new fill percentage to new row (column 4)
    df_in_list[new_row,4] = new_fill
    
    # Fill the empty dataframe with the historydata of the bin + the new row with new data
    empty_df = rbind(empty_df , df_in_list)
    
    # Sort the dataframe on time
    empty_df = empty_df[order(empty_df[, 2]) , ] 
    
    # Assign new dataframe of a specific bin to a new variable with unique name
    assign(name, empty_df)
  }
  
  # List all the unique dataframes representing different bins
  list_df_update <- list(Bin_update_1,Bin_update_2, Bin_update_3,Bin_update_4,Bin_update_5,Bin_update_6,Bin_update_7,Bin_update_8,Bin_update_9,Bin_update_10,Bin_update_11,Bin_update_12)
  
  # Merge all the dataframes in the list to one new dataframe again
  result = Reduce(function(x, y) merge(x, y, all=TRUE), list_df_update)
  
  # Order this new dataframe on binId
  result = result[order(result[, 1]) , ] 
  
  # Write results to database
  write_result = dbWriteTable(con, name = 'a5_bin_fill_history', value = result, row.names = FALSE, alter.names = TRUE, overwrite = TRUE)
  return(result)
}


