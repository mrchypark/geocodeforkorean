geocode<-function()
{

defaultwd<-getwd()

InstallCandidates <- c("sp","rgdal","rvest","devtools","RCurl","xlsx","data.table","plyr")
# check if pkgs are already present
toInstall <- InstallCandidates[!InstallCandidates %in% library()$results[,1]]
if(length(toInstall)!=0) {install.packages(toInstall, repos = "http://cran.r-project.org")}
# load pkgs
lapply(InstallCandidates, library, character.only = TRUE)

from.crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
to.crs = "+proj=tmerc +lat_0=38 +lon_0=127.5 +k=0.9996 +x_0=1000000 +y_0=2000000 +ellps=GRS80 +units=m +no_defs"

convertCoordSystem <- function(long, lat, from.crs, to.crs){
  xy <- data.frame(long=long, lat=lat)
  coordinates(xy) <- ~long+lat

  from.crs <- CRS(from.crs)
  from.coordinates <- SpatialPoints(xy, proj4string=from.crs)
  
  to.crs <- CRS(to.crs)
  changed <- as.data.frame(SpatialPoints(spTransform(from.coordinates, to.crs)))
  names(changed) <- c("long", "lat")
  
  return(changed)
}


geocode_result = c()

message("This code is for geocoding for korean.")
message("Only for adress to UTM-K.(Maybe update.)")
message("Sample files is on repo mrchypark/geocodeutmk")
message()
message("If you enter without any path, default Dir is ",getwd(),"/input/ .")
message("Before you setting input dir, please check path is exists even setting default.")
inputpath <- readline(prompt="Please type input dir full path like above where your files.: ")

if(identical(inputpath,"")){inputpath<-paste0(getwd(),"/input/")}

options(warn=-1)
inputveri<-tryCatch(setwd(file.path(inputpath)),error=function(e) ("error"))
options(warn=1)

    while(identical(inputveri,"error")){
        message("If you want set default dir like ",getwd(),"/input/, please don't enter anything.")
        message("or check foler is exists")
        inputpath <- readline(prompt="Please type input dir full path like above.: ")

        if(identical(inputpath,"")){inputpath<-paste0(getwd(),"/input/")}

        options(warn=-1)
        inputveri<-tryCatch(setwd(file.path(inputpath)),error=function(e) ("error"))
        options(warn=1)
    }

print(paste0("Input path is setting at ",getwd()))
setwd(defaultwd)

    message("Output dir settings.")
    message("If you enter without any path, default Dir is ",getwd(),"/output/")
    message("Before you setting output dir, please check path is exists even setting default.")
    outputpath <- readline(prompt="Please type output dir full path like above where you want to save result files.: ")

if(identical(outputpath,"")){outputpath<-paste0(getwd(),"/output/")}

options(warn=-1)
outputveri<-tryCatch(setwd(file.path(outputpath)),error=function(e) ("error"))
options(warn=1)

    while(identical(outputveri,"error")){
        message("If you want set default dir like ",getwd(),"/input/, please don't enter anything.")
        message("or check foler is exists")
        outputpath <- readline(prompt="Please type input dir full path like above.: ")

        if(identical(outputpath,"")){outputpath<-paste0(getwd(),"/input/")}

        options(warn=-1)
        outputveri<-tryCatch(setwd(file.path(outputpath)),error=function(e) ("error"))
        options(warn=1)
    }

message("Output path is setting at ",getwd())
setwd(defaultwd)
setwd(inputpath)

filelist<-dir()
for (file in 1:length(filelist)){

message(filelist[file]," is on progress.")

loc_list_original<-read.csv(filelist[file],stringsAsFactors=F)
setwd(defaultwd)
names(loc_list_original)<-c("no","address")
loc_list <- unique(loc_list_original[,2])
loc_list <- loc_list[nchar(loc_list)>0]
loc_list <- data.frame(no=1:length(loc_list),address=loc_list,stringsAsFactors=F)


for(loc in 1:nrow(loc_list)){

message(loc_list[loc,2]," is on progress. ", loc," / ",nrow(loc_list)," ",file," / ",length(filelist))

  url = "http://maps.googleapis.com/maps/api/geocode/xml?sensor=false&language=ko&address='"

  geocode_url = paste0(url, URLencode(iconv(loc_list[loc,2],to="UTF-8")) , "'")

  geocode_xml = read_xml(geocode_url, encoding='UTF-8')

  stat = geocode_xml %>%
    xml_node('status') %>%
    xml_text()
while(stat=="OVER_QUERY_LIMIT"){
message("wait for api limit")
Sys.sleep(3)
  geocode_xml = read_xml(geocode_url, encoding='UTF-8')

  stat = geocode_xml %>%
    xml_node('status') %>%
    xml_text()
}
if(!(stat %in% c("ZERO_RESULTS","INVALID_REQUEST"))){

  geocode_lat = geocode_xml %>%
    xml_node('geometry location lat') %>%
    xml_text()

  geocode_lon = geocode_xml %>%
    xml_node('geometry location lng') %>%
    xml_text()

result<-convertCoordSystem(as.numeric(geocode_lon), as.numeric(geocode_lat), from.crs, to.crs)

  geocode_data = data.frame(address = loc_list[loc,2], 
                            lon = result$long,
                            lat = result$lat
                            )

  geocode_result = rbind(geocode_result, geocode_data)
} else {

  geocode_data = data.frame(address = loc_list[loc,2], 
                            lon = "no match.",
                            lat = "no match."
                            )

  geocode_result = rbind(geocode_result, geocode_data)

}


} # for get geocode_result

result<-merge(loc_list_original, geocode_result, by = c("address"))
result<-result[order(result$no),]
result<-result[,c(1,4,5)]

filename<-filelist[file]
filename<-substr(filename,1,(nchar(filename)-4))

setwd(outputpath)
write.xlsx2(geocode_result ,paste0("./result_",filename,".xls"),sheetName="Sheet1",  col.names=TRUE, row.names=TRUE, append=FALSE)
setwd(inputpath)

} # for get files

setwd(defaultwd)
}
geocode() 
