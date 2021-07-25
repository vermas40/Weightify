conn <- create_db_connection('weightloss.db')
df <- dbReadTable(conn,'weighing_scale')