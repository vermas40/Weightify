get_data <- function(db_name){
  conn <- dbConnect(RSQLite::SQLite(),paste0(
                                     '~/Documents/Documents/Side Projects/myWeightLossPal/',
                                     db_name))
  user_data <- dbReadTable(conn,'app_users')
  dbDisconnect(conn)
  return(user_data)
}