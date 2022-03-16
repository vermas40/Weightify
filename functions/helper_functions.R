create_db_connection <- function(db_name){
  conn <- dbConnect(RSQLite::SQLite(),paste0(
    #inside a docker container you need to give absolute path to your files
                                    "/app/data/",db_name))
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

create_week_dates <- function(dt){
  #'This function creates all the dates for a week
  #'Input
  #'1. dt: date object, this is the date of entry
  #'Returns
  #'1. week_dates, r list: list with the dates for a week
  
  dt <- as.Date(dt,'%Y-%m-%d')
  sun_dt <- floor_date(dt, unit='week') #by default floor is sunday
  week_dates <- c()
  for (day in (0:6)){
    week_dates <- c(week_dates, as.character(sun_dt+day))
  }
  week_dates <- data.frame(week_dates)
  colnames(week_dates) <- c('date')
  week_dates['year'] = year(dt)
  week_dates['month'] = month(dt)
  week_dates['week_in_yr'] = epiweek(dt)
  return(week_dates)
}

get_last_week_cal_data <- function(user, db_name){
  conn <- create_db_connection(db_name)
  user_data <- dbReadTable(conn,'user_performance')
  user_data <- user_data[which(user_data['user'] == user),]
  user_data['week_in_yr'] <- user_data['week_in_yr'] + 1
  user_data <- user_data %>%
               pivot_wider(id_cols = c('user','year','week_in_yr'),
                           names_from = 'metric', values_from = 'value')
  user_data <- user_data[c('user','year','week_in_yr','wt','cal')]
  user_data <- user_data %>% dplyr::rename(wt_lst_wk = wt, cal_lst_wk = cal)
  return(user_data)
}
create_week_calendar_data <- function(df){
  #'This function creates the entries for an entire week

  #appending the latest record with previous records of the user
  #this appending is important since the df that is coming as argument
  #only consists of the one record entered by the user
  conn <- create_db_connection('weightloss.db')
  weight_df <- dbReadTable(conn, 'weighing_scale')
  weight_df <- weight_df %>%
               pivot_wider(id_cols = c('user','date_created','date','year',
                                       'month','week_in_yr'),
                           names_from='metric', values_from='value')
  #df['date'] <- as.Date(df[['date']])
  #filtering for only the required user
  weight_df <- weight_df[which(weight_df[['user']] == unique(df[['user']])),]
  weight_df <- rbind(weight_df, df)
  #removing all entries greater than current date so that 
  #the latest weight and calories can get copied over
  weight_df <- weight_df[which(weight_df[['date']] <= df[['date']]),]
  #sorting & removing duplicates
  weight_df <- dplyr::arrange(weight_df, desc(date_created), user)
  weight_df <- weight_df[!duplicated(weight_df[,c('user','date')]),]
  week_dates <- create_week_dates(df[['date']])
  week_cal_data <-merge(week_dates, weight_df, by=c('date','year','month',
                                                    'week_in_yr'),
                        all.x=TRUE)
  #experimental, entered by shivam on 10/10/21
  #browser()
  sys_gen_obs <- which(week_cal_data['source']=='system_generated')
  week_cal_data[sys_gen_obs, c('date_created',
                               'wt','cal','source')] <- NA
  #experimental overs
  week_cal_data <- week_cal_data %>%
                   dplyr::group_by(year, month, week_in_yr) %>%
                   fill(c('user','date_created','year','month','week_in_yr'),
                        .direction='downup') %>%
                   fill(c('wt','cal'), .direction='down') %>%
                   dplyr::ungroup()
  
  week_cal_data <- as.data.frame(week_cal_data)
  last_week_cal_data <- get_last_week_cal_data(unique(week_cal_data[which(is.na(week_cal_data['user'])==F),
                                                                    'user']),
                                               'weightloss.db')
  week_cal_data <- merge(week_cal_data, last_week_cal_data,
                         by=c('user','year','week_in_yr'), all.x = TRUE)
  
  #imputing missing values with last week's data
  week_cal_data[is.na(week_cal_data['source']),'source'] <- 'system_generated'
  cal_miss_idx <- is.na(week_cal_data['cal'])
  wt_miss_idx <- is.na(week_cal_data['wt'])
  week_cal_data[cal_miss_idx,'cal'] <- week_cal_data[cal_miss_idx,'cal_lst_wk']
  week_cal_data[wt_miss_idx,'wt'] <- week_cal_data[cal_miss_idx,'wt_lst_wk']
  
  #if there are still missing values then backward fill
  #browser()
  week_cal_data <- week_cal_data %>%
                   dplyr::group_by(year, month, week_in_yr) %>%
                   fill(c('wt','cal'), .direction='up') %>%
                   dplyr::ungroup()
  week_cal_data <- week_cal_data[,c('user','date_created','date','year','month',
                                    'week_in_yr','wt','cal','source')]
  return(week_cal_data)
}

format_datatable <- function(df, no_vis_cols=NULL){
  
  df <- datatable(df,
                  filter='none',
                  rownames = FALSE,
                  width='100%',
                  escape=FALSE,
                  style='bootstrap',
                  options = list(
                    dom='t',
                    searching=FALSE,
                    processing=FALSE,
                    autowidth=TRUE,
                    ordering=FALSE,
                    paging=FALSE,
                    scrollX=TRUE,
                    scrollY=TRUE,
                    language = list(emptyTable='Start using the weight & calorie 
                                                tracking to see results here'),
                    columnDefs=list(list(width='100', targets='_all'),
                                    list(targets=no_vis_cols, visible=FALSE)),
                    info=FALSE,
                    lengthChange=FALSE
                  ),
                  class='display'
                  ) %>% formatStyle(c(1:dim(df)[2]), border='1px solid #000000')
  
  return(df)
}
make_wt_diary <- function(user, db_name){
  #This function takes user data and converts it into a datatable diary format
  #
  #Input
  #1. df: r dataframe, this is the data frame with user data
  #
  #Return
  #1. df: datatable, this is the data table formatted with the relevant info
  
  df <- pull_plot_data(user, db_name)
  #creating the day of week column
  df['day_of_week'] <- wday(df[['date']], label=TRUE, abbr=FALSE)
  #making those entries NA that were system generated
  sys_gen_dates <- unique(df[which(df['value']=='system_generated'),'date'])
  sys_gen_idx <- which(df[['date']] %in% sys_gen_dates)
  df[sys_gen_idx,'value'] <- NA
  
  #pivoting the dataset to a wider format by pivotting on week starting date
  #and metric
  df <- df %>%
    group_by(week_in_yr) %>%
    mutate(week_starting_date = min(date)) %>%
    pivot_wider(id_cols = c('user','week_starting_date', 'metric'), 
                names_from='day_of_week', values_from='value') %>%
    filter(metric != 'source') %>%
    rename('Week Date' = week_starting_date,
           'Metric' = metric)
  
  df['Metric'] <- ifelse(df[['Metric']]=='wt', 'Weight', 'Calories')
  df <- as.data.frame(df)
  #finding out the index of the user columns that should be hidden
  no_vis_cols <- which(colnames(df)=='user')
  no_vis_cols <- no_vis_cols - 1
  df <- format_datatable(df, no_vis_cols)
  
  return(df)
}

update_db <- function(db_name, app_data, table_name, fx='goals'){
  #'This function appends the user goals or the daily inputs to the database

  conn <- create_db_connection(db_name)
  #converting database from wide to long
  datatable <- dbReadTable(conn, table_name)
  app_data <- gather(app_data, 'metric', 'value', -c('user','date_created','year',
                                                    'month','week_in_yr','date'))
  #appending the observations
  #making sure the order of columns is exactly the same
  datatable <- datatable[,c('user','date_created','date','year','month',
                            'week_in_yr','metric','value')]
  datatable <- rbind(datatable, app_data)
  
  #keeping only the latest goal/entry
  datatable <- dplyr::arrange(datatable, desc(date_created), user)
  if (fx=='goals'){
    datatable <- datatable[!duplicated(datatable[,c('user','metric')]),]
  }else{
    datatable <- datatable[!duplicated(datatable[,c('date','user','metric')]),]
  }
  dbWriteTable(conn, table_name, datatable, overwrite=TRUE)
  dbDisconnect(conn)
  return()
}
