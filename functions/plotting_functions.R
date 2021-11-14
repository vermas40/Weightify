pull_plot_data <- function(user, db_name){
  #'This function subsets the database for a particular user
  
  conn <- create_db_connection(db_name)
  user_weight_history <- gsub('\n', '', user_weight_history)
  qry <- sprintf(user_weight_history, user)
  df <- dbGetQuery(conn, qry)
  dbDisconnect(conn)
  return(df)
}

make_plot_df <- function(user, db_name, metric){
  df <- pull_plot_data(user, db_name)
  df <- df %>%
    pivot_wider(id_cols=c('date','year','month','week_in_yr'),
                names_from='metric', values_from='value') %>%
    filter(source == 'user_generated') %>%
    mutate(!!metric := as.numeric(!!as.name(metric)),
           wt = as.numeric(wt),
           wt_lost = wt - lag(wt, default = wt[1]))
  df <- as.data.frame(df)
  return(df)
}

get_bars <- function(df, metric){
  
  if (metric=='wt'){
    name='Weight'
  }else{
    name='Calories'
  }
  fig <- plot_ly(data = df)
  fig <- fig %>% add_trace(x = ~date, y = as.formula(paste0('~', metric)), 
                           type='bar',
                           marker=list(color = 'rgb(50,97,127)', 
                                       line=list(width=2,
                                                 color='rgb(0,0,0)')),
                           yaxis='y',
                           name=name)
  return(fig)
}

get_metric_unit <- function(user, db_name, metric){
  conn <- create_db_connection(db_name)
  qry <- gsub('\n','',unit_query)
  qry <- sprintf(qry, user, metric)
  df <- dbGetQuery(conn, qry)
  dbDisconnect(conn)
  return(df)
}
make_wt_plot <- function(user, db_name){
  metric <- 'cal'
  df <- make_plot_df(user, db_name, metric)
  wt_unit <- get_metric_unit(user, db_name, 'wt')
  unit <- get_metric_unit(user, db_name, metric)
  
  if (metric=='wt'){
    title = paste0('Weight (in ', unit,')')
  }else{
    title = paste0('Calories (in ', unit,')')
  }
  
  fig <- get_bars(df, metric)
  fig <- fig %>% add_trace(data=df, x = ~date, y = ~wt, 
                           name='Weight',
                           type='scatter', mode='lines',
                           line = list(color='rgb(0,0,0)', width=2, dash='solid'),
                           yaxis='y2')
  
  fig <- fig %>% layout(
                        title='Daily Weight Trend',
                        yaxis=list(side='left', title=title,
                                   showgrid=F, zeroline=F, linecolor=toRGB('black'),
                                   linewidth=2),
                        yaxis2=list(overlaying='y', side='right', 
                                    title=paste0('Weight (in ', wt_unit,')'),
                                    showgrid=T, zeroline=F, automargin=T,
                                    linecolor=toRGB('black'), linewidth=2,
                                    rangemode='normal'),
                        xaxis=list(title='Date', linecolor=toRGB('black'), 
                                   linewidth=2),
                        hovermode = 'x unified',
                        legend = list(orientation = 'h', x=0.40, y= -0.22),
                        margin = list(l = 50, r = 50, t = 50, pad = 20),
                        paper_bgcolor='#C0C0C0',
                        plot_bgcolor='#C0C0C0'
  )
  return(fig)
}



