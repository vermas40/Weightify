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
  #if data is there, then read the dataset
  #delete the dataset from database
  #append the new users' data
  #dedupe to remove two entries with same name
  #and then push it to database
  if ((dbExistsTable(conn,'app_users')) & (nrow(dbReadTable(conn,'app_users')) > 0)){
    #reading table from db
    user_data <- dbReadTable(conn,'app_users')
    #appending new observations
    user_data <- rbind(user_data, c(user_name,hashPassword(password),Sys.time(), TRUE))
    colnames(user_data) <- c('user','password','date_created')
    #ordering by date_created
    #this logic is needed in change password, when that is created
    #it will be moved from here
    user_data <- dplyr::arrange(user_data, desc(date_created), user_name)
    user_data <- user_data[!duplicated(user_data[,'user']),]
    dbWriteTable(conn,'app_users',user_data, overwrite=TRUE)
  }else{
    user_data <- data.frame(user = character(), password = character(),
                            date_created = character(), is_hashed_password = character())
    #hashing password before sending to db
    user_data <- rbind(user_data, c(user_name,hashPassword(password),Sys.time(), TRUE))
    dbWriteTable(conn,'app_users',user_data, overwrite=TRUE)
  }
  dbDisconnect(conn)
}