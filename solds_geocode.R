library(ggmap)
library(dplyr)
library(stringr)
library(stringi)

houses <- read.table("geocode_20160901-20160921.csv",sep=";",strip.white = T, stringsAsFactors = F)

code <- data.frame(address = as.character(houses$input_address), main_id = houses$main_id, lat = houses$lat, lng = houses$lng)
code <- code[is.na(code$lat),]
code$address <- as.character(code$address)
for (i in 1:nrow(code)){
  code[i,]$address <- gsub(str_extract(code[i,]$address,"Unit[^,]+[,]"),"",as.character(code[i,]$address))
}
code$address <- trimws(code$address)
code <- code[!is.na(code$address),]

geo_reply = geocode(code$address, output='all', messaging=TRUE, override_limit=TRUE)

geocode <- data.frame(main_id = as.integer(houses$main_id),
                      #listing_id = as.character(houses$listing_id),
                      #input_address = trimws(as.character(houses$address)),
                      lat = NA,
                      lng = NA,
                      neighborhood = NA,
                      sublocality = NA,
                      stringsAsFactors = F
)

for (i in 1:length(geo_reply)){
  if (geo_reply[[i]]$status == "OK"){
    geocode[i,"lat"] <- geo_reply[[i]]$results[[1]]$geometry$location$lat
    geocode[i,"lng"] <- geo_reply[[i]]$results[[1]]$geometry$location$lng
    x <- as.data.frame(t(sapply(geo_reply[[i]]$results[[1]]$address_components, rbind)))
    if (length(grep("sublocality", x)) > 0){
      geocode[i,"sublocality"] <- x[grep("sublocality", x[,3]),1]
    }
    if (length(grep("neighborhood", x)) > 0){
      geocode[i,"neighborhood"] <- x[grep("neighborhood", x[,3]),1]
    }
  }
}

for (i in 1:nrow(geocode)){
  id <- geocode[i,"main_id"]
  houses[id,"lat"] <- geocode[i,"lat"]
  houses[id,"lng"] <- geocode[i,"lng"]
  houses[id,"neighborhood"] <- geocode[i,"neighborhood"]
  houses[id,"sublocality"] <- geocode[i,"sublocality"]
}

write.table(houses,"geocode.csv",sep=";")
