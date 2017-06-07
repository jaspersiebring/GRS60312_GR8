#Team Garbage/GA_Urban_Waste_Management
#6th of June 2017

#set working directory to the same folder where main.R is saved!

#library imports
source('Scripts/download_script.R')

## example/download data
url = 'https://drive.google.com/file/d/0B2pH-wZjt_l4WlFnY2FKMXRic2c/view?usp=sharing'
dest = './Data/Step/asphalt_points.csv'
drive_download(url, dest)
