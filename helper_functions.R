create_db_connection <- function(db_name){
  conn <- dbConnect(RSQLite::SQLite(),paste0(
                                    '~/Documents/Documents/Side Projects/myWeightLossPal/',
                                    db_name))
  return(conn)
}

get_app_users <- function(db_name){
  conn <- create_db_connection(db_name)
  user_data <- dbReadTable(conn,'app_users')
  dbDisconnect(conn)
  return(user_data)
}

get_user_goals <- function(db_name){
  conn <- create_db_connection(db_name)
  user_goals <- dbReadTable(conn,'user_goals')
  dbDisconnect(conn)
  return(user_goals)
}

create_acct <- function(db_name, user_name, password){
  #This function inserts data into the app user database table
  conn <- create_db_connection(db_name)
  user_data <- dbReadTable(conn,'app_users')
  #appending new observations
  data <- data.frame(list('user' = user_name,'password' = hashPassword(password),
                          'date_created' = as.character(Sys.time()),
                          'is_hashed_password' = TRUE))
  user_data <- rbind(user_data, data)
  colnames(user_data) <- c('user','password','date_created','is_hashed_password')
  dbWriteTable(conn,'app_users',user_data, overwrite=TRUE)
  dbDisconnect(conn)
}


change_pwd <- function(db_name, user_name, password){
  #'This function changes password of a user
  conn <- create_db_connection(db_name)
  user_data <- dbReadTable(conn,'app_users')
  #appending new user name and password combo
  data <- data.frame(list('user' = user_name,'password' = hashPassword(password),
                          'date_created' = as.character(Sys.time()),
                          'is_hashed_password' = TRUE))
  user_data <- rbind(user_data, data)
  colnames(user_data) <- c('user','password','date_created','is_hashed_password')
  #ordering by date_created
  #and removing the older observation
  user_data <- dplyr::arrange(user_data, desc(date_created), user)
  user_data <- user_data[!duplicated(user_data[,'user']),]
  dbWriteTable(conn,'app_users',user_data, overwrite=TRUE)
  dbDisconnect(conn)
  return()
}

update_db <- function(db_name, app_data, table_name){
  #'This function appends the user goals or the daily inputs to the database
  conn <- create_db_connection(db_name)
  #converting database from wide to long
  datatable <- dbReadTable(conn, table_name)
  app_data <- gather(app_data, 'metric', 'value', -c('user','date_created','year',
                                                    'month','week_in_yr'))
  #appending the observations
  colnames(app_data) <- c('user','date_created','year','month','week_in_yr',
                            'metric','value')
  datatable <- rbind(datatable, app_data)

  #keeping only the latest goal/entry
  datatable <- dplyr::arrange(datatable, desc(date_created), user)
  datatable <- datatable[!duplicated(datatable[,c('user','metric')]),]
  dbWriteTable(conn, table_name, datatable, overwrite=TRUE)
  dbDisconnect(conn)
  return()
}


