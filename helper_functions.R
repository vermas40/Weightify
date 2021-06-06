get_app_users <- function(db_name){
  conn <- dbConnect(RSQLite::SQLite(),paste0(
                                     '~/Documents/Documents/Side Projects/myWeightLossPal/',
                                     db_name))
  user_data <- dbReadTable(conn,'app_users')
  dbDisconnect(conn)
  return(user_data)
}

create_acct <- function(db_name, user_name, password){
  #This function inserts data into the app user database table
  conn <- dbConnect(RSQLite::SQLite(),paste0(
                                      '~/Documents/Documents/Side Projects/myWeightLossPal/',
                                      db_name))
  #browser()
  if (dbExistsTable(conn,'app_users')){
    #reading table from db
    user_data <- dbReadTable(conn,'app_users')
    #appending new observations
    user_data <- rbind(user_data, c(user_name,password,Sys.time()))
    colnames(user_data) <- c('user_name','password','date_created')
    #ordering by date_created
    user_data <- dplyr::arrange(user_data, desc(date_created), user_name)
    user_data <- user_data[!duplicated(user_data[,'user_name']),]
    dbRemoveTable(conn,'app_users')
    dbWriteTable(conn,'app_users',user_data)
  }else{
    user_data <- data.frame(user_name = character(), password = character(),
                            date_created = character())
    user_data <- rbind(user_data, c(user_name,password,Sys.time()))
    dbWriteTable(conn,'app_users',user_data)
  }
  dbDisconnect(conn)
}