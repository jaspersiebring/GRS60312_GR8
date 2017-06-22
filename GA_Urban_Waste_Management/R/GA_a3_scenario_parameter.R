##Script name :GA_a3_scenario_parameter.R
##Description :This script contains the data frame of scenarios in Smart Waste Management System. 
            ##The output is a table of scenarios with attributes : scenario_name, values, and descritption.
            ##The table is then pushed to the main geodatabase by using a connection to geodatabase server
##Packages    : RPostgreSQL
##Output table: GA_ps_scenario_parameter
##Attribute   : scenario_name, value, description
##Database    : SWMS_database
##Creator     : Talitha Rahmawati
##Date        : June 21, 2017
##Organization: Wageningen University UR

library('RPostgreSQL')

##Creating data frame of the scenarios
scenario_name <- c ('plastic_weight_dens','paper_weight_dens', 'residual_weight_dens', 'handling_time')
value <- c ('0.039 kg/l', '0.076 kg/l', '0.1 kg/l', '3 minutes')
description <- c ('the relative weight density of plastic waste', 'the relative weight density of paper waste','the relative weight density of residual waste', 'the amount of time for truck to handle the waste')
scenario <- data.frame (scenario_name, value, description)


# Access database
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname ='SWMS_database', host = 'D0146435', port = 5432, user = "postgres", password = 'postgres')

#Insert data frame to database

pgInsert(con, name=c("public","GA_ps_scenario_parameter"), data.obj= scenario, alter.names=TRUE, overwrite = TRUE )



# Free up resources
dbDisconnect(con)


