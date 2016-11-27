library(rvest)
library(lubridate)
library(stringr)

curr_dir <- "html/2016-09/detail/"

lst_main <- data.frame( main_id = integer(),
                        listing_id=character(), 
                        address=character(),
                        contract_date=as.Date(character()), 
                        sold_price=integer(), 
                        list_price=integer(),
                        area=character(),
                        maint_fees=character(),
                        basement=character(),
                        exposure=character(),
                        kitchens=character(),
                        garage=character(),
                        locker=character(),
                        cooling_type=character(),
                        heating_type=character(),
                        stringsAsFactors = F
                        )

lst_rooms <- data.frame( room = character(),
                         level = character(),
                         width = single(),
                         length = single(),
                         main_id = integer()
                         )

parse_main <- function(filename, lst_main, curr_dir, i, data){
  
  lst_main[i,"address"] <- as.character((data %>% html_nodes("h3") %>% html_text())[1])
  
  price_text <- (data %>% html_nodes("h4") %>% html_text())[1]
  price_text <- gsub("[^[:digit:].[:blank:]]","",price_text)
  lst_main[i,"list_price"] <- as.numeric(str_extract(price_text,"[0-9]{1,8}"))
  lst_main[i,"sold_price"] <- as.numeric(str_extract(price_text,"[0-9]{1,2}\\.[0-9]{1,2}"))*1000000
  
  details <- html_table(data %>% html_nodes("table"))[[1]]
  lst_main[i,"listing_id"] <- as.character(details[details$X1 == "Listing ID:",][2])
  lst_main[i,"contract_date"] <- as.Date(as.character(details[details$X1 == "Contract Date:",][2]),"%m/%d/%Y")
  lst_main[i,"area"] <- as.character(details[details$X1 == "Approximate Footage:",][2])
  lst_main[i,"maint_fees"] <- as.character(details[details$X1 == "Maintenance Fees:",][2])
  lst_main[i,"basement"] <- as.character(details[details$X1 == "Basement:",][2])
  lst_main[i,"exposure"] <- as.character(details[details$X1 == "Exposure:",][2])
  lst_main[i,"kitchens"] <- as.character(details[details$X1 == "Kitchens:",][2])
  lst_main[i,"garage"] <- as.character(details[details$X1 == "Garage:",][2])
  lst_main[i,"locker"] <- as.character(details[details$X1 == "Locker:",][2])
  lst_main[i,"cooling_type"] <- as.character(details[details$X1 == "Cooling Type:",][2])
  lst_main[i,"heating_type"] <- as.character(details[details$X1 == "Heating Type:",][2])
  
  return(lst_main)
}

parse_rooms <- function(filename, lst_rooms, curr_dir, i, data){
  
  rooms <- html_table(data %>% html_nodes("table"))[[2]]
  if (nrow(rooms) > 0){
    rooms$width <- as.numeric(t(data.frame(strsplit(rooms[,3]," x "))[1,]))
    rooms$length <- as.numeric(t(data.frame(strsplit(rooms[,3]," x "))[2,]))
    rooms[,3] <- NULL
    rooms$main_id <- i
    colnames(rooms) <- colnames(lst_rooms)
    lst_rooms <- rbind(lst_rooms, rooms)
  }
  return(lst_rooms)
}

filenames <- list.files(curr_dir, pattern = ".html", full.names = F)

for (j in filenames){
  i <- nrow(lst_main) + 1
  data <- read_html(paste0(curr_dir,j))
  lst_main[i,"main_id"] <- i
  
  
  lst_main <- parse_main(j, lst_main, curr_dir, i, data)
  lst_rooms <- parse_rooms(j, lst_rooms, curr_dir, i, data)
}