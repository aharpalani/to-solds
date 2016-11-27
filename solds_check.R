library(rvest)
library(lubridate)

pull_house <- function(link, new_file){
  lines <- readLines("scrape_base_detail.js")
  lines[1] <- paste0("var url = '",link,"'")
  lines[2] <- paste0("var path = '",new_file,"'")
  writeLines(lines, "scrape_detail_curr.js")
  system("phantomjs scrape_detail_curr.js")
}

ind_links <- function(data){
  entries <- data %>% html_node("table") %>% html_node("tbody") %>% html_nodes("a")
  df <- as.data.frame(t(as.data.frame(html_attrs(entries))), row.names = F)
  return(as.character(df$href))
}


mth <- as.Date("2016-09-01")
num_days <- as.numeric(days_in_month(mth))

repull <- data.frame(filename = character(),
                     url = character(),
                     stringsAsFactors = F
                    )
i <- 0
for (y in 1:19) {
  x <- mth %m+% days(y-1)
  filename <- paste0("main_",year(x),sprintf("%02d",month(x)),sprintf("%02d",day(x)),".html")
  data <- read_html(paste0("html/",format(x,"%Y-%m"),"/",filename))
  links <- ind_links(data)
  
  for (z in 1:length(links)) {
    filename <- paste0("lst_",year(x),sprintf("%02d",month(x)),sprintf("%02d",day(x)),"_",sprintf("%03d",z),".html")
    data <- read_html(paste0("html/",format(x,"%Y-%m"),"/detail/",filename))
    url <- paste0("http://www.mongohouse.com",links[z])
    
    check <- try((data %>% html_nodes("h3"))[2],silent=T)
    if (is(check,"try-error")){
      i <- i + 1
      repull[i,"filename"] <- filename
      repull[i,"url"] <- url
    }
  }
}

for (y in 1:nrow(repull)){
  pull_house(repull[y,"url"],repull[y,"filename"])
}
