#Team Garbage/GW_Quality_Assessment_Of_Infrastructure
#6th of June 2017

#Parses Google Drive links and downloads it to a specified folder
#right click Google Drive files, select 'get shareable link', go to 'sharing settings' and copy the full URL
#this method will only work for files <25mb, bigger files have to be downloaded manually

fix = 'https://drive.google.com/uc?export=download&id='
drive_download = function(dl_url, dest_name){
  file_id = strsplit(dl_url, '/') 
  file_id = file_id[[1]][6]
  durl = paste0(fix, file_id)
  download.file(durl, dest_name, mode= "wb")
}