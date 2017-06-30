##Script name : GA_a5_initialize_bin_fill_history.R 
##Description : Initialize the 'a5_bin_fill_history' table, which stores all the history data of the specific bins.
##Packages    : RPostgreSQL, rpostgis 
##Output table: 'a5_bin_fill_history'
##Attribute   : n.a.
##Database    : SWMS_database 
##Creator     : Bas Wiltenburg
##Date        : June 26, 2017 
##Organization: Wageningen University UR 

initialize_bin_filling <- function(con){
  #Calculate bin filling percentage
  fillper = runif(12, 1, 100)
  #Create initial bin filling table, binid's coming from the DB
  binid = dbGetQuery(con, "SELECT bin_id FROM a1_bin_properties;")
    
  #binid <- c(34879, 34892, 34902, 34919, 34920, 34922, 34923, 34927, 34941, 34963, 34971, 34976)
  timestamp = as.POSIXlt(c('2017-01-01 8:00:00')) 
  addedwaste = c(0)
  fillpercentage = c(fillper)
  df = data.frame(binid, timestamp, addedwaste, fillpercentage)
  bin_fill = dbWriteTable(con, name = 'a5_bin_fill_history', value = df, row.names = FALSE, alter.names = TRUE, overwrite = TRUE)
}

