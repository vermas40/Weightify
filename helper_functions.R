get_app_users <- function(db_name){
  conn <- dbConnect(RSQLite::SQLite(),paste0(
                                     '~/Documents/Documents/Side Projects/myWeightLossPal/',
                                     db_name))
  user_data <- dbReadTable(conn,'app_users')
  dbDisconnect(conn)
  return(user_data)
}

get_user_goals <- function(db_name){
  conn <- dbConnect(RSQLite::SQLite(),paste0(
                                    '~/Documents/Documents/Side Projects/myWeightLossPal/',
                                    db_name))
  user_goals <- dbReadTable(conn,'user_goals')
  return(user_goals)
}

create_acct <- function(db_name, user_name, password){
  #This function inserts data into the app user database table
  conn <- dbConnect(RSQLite::SQLite(),paste0(
                                      '~/Documents/Documents/Side Projects/myWeightLossPal/',
                                      db_name))
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
  conn <- dbConnect(RSQLite::SQLite(),paste0(
                                    '~/Documents/Documents/Side Projects/myWeightLossPal/',
                                    db_name)
                   )

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
}

add_user_goal <- function(db_name, new_goal){
  #'This function appends the user goals to the database
  conn <- dbConnect(RSQLite::SQLite(),paste0(
                                    '~/Documents/Documents/Side Projects/myWeightLossPal/',
                                      db_name))
  #converting database from wide to long
  user_goals <- dbReadTable(conn,'user_goals')
  new_goal <- gather(new_goal, 'metric', 'value', -c('user','date_created','year',
                                                    'month','week_in_yr'))
  #appending the observations
  colnames(new_goal) <- c('user','date_created','year','month','week_in_yr',
                            'metric','value')
  user_goals <- rbind(user_goals, new_goal)

  #keeping only the latest goal
  user_goals <- dplyr::arrange(user_goals, desc(date_created), user)
  user_goals <- user_goals[!duplicated(user_goals[,c('user','metric')]),]
  dbWriteTable(conn, 'user_goals',user_goals, overwrite=TRUE)
  dbDisconnect(conn)
  
}