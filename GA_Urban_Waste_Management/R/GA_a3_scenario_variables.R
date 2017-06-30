##Script name : GA_a3_scenario_variables.R
##Description : This script contains the data frame of scenarios in Smart Waste Management System. 
##              The table is pushed to the main geodatabase by using a connection to geodatabase server
##Packages    : RPostgreSQL
##Output table: a3_scenario_variables
##Attribute   : variable_name, variable_value, variable_description
##Database    : SWMS_database
##Creator     : Talitha Rahmawati
##Date        : June 21, 2017
##Organization: Wageningen University UR

##Alterations:
#Thijs, 22-6  ; value name instead of scenario name, only one scenario will be stored, which is the table in itself
#             ; only the value in value attribute, units in description
#             ; added variables for Decrease_BinAvgAddedWaste and Factor_BinCapacity
#             ; included test by getting back table


variables <- function(con, plastic_weight_dens, paper_weight_dens, residual_weight_dens, handling_time, Decrease_BinAvgAddedWaste, Factor_BinCapacity){
  ##Creating data frame of the scenarios
  variable_name <- c ('plastic_weight_dens','paper_weight_dens', 'residual_weight_dens', 'handling_time', 'Decrease_BinAvgAddedWaste', 'Factor_BinCapacity')
  variable_value <- c (plastic_weight_dens ,paper_weight_dens, residual_weight_dens, handling_time, Decrease_BinAvgAddedWaste, Factor_BinCapacity)
  variable_description <- c ('[yet unused] the relative weight density of plastic waste [kg/l]', 
                             '[yet unused] the relative weight density of paper waste [kg/l]',
                             '[yet unused] the relative weight density of residual waste [kg/l]', 
                             '[yet unused] the amount of time for truck to handle the waste [minutes]', 
                             'Expected decrease in BinAvgAddedWaste [%]', 
                             'Multiplication factor on bin capacity per location i.e. number of bins per location [-]')
  scenario <- data.frame (variable_name, variable_value, variable_description)
  #Insert data frame to database
  pgInsert(con, name=c("public","a3_scenario_variables"), data.obj= scenario, alter.names=TRUE, overwrite = TRUE )
  #Test by getting back table
  scenario_test = dbReadTable(con, c("public", "a3_scenario_variables"))
  
}
