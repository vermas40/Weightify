library(httr)
user='zeus'
GET(url = paste0('http://0.0.0.0:1234/time_left/',
                 user))
