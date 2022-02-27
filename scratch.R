library(dplyr)
df <- data.frame(col1=c('shivam','verma','okok'), col2=c(1,2,3))


sample_func <- function(df, col_name){
  df[paste0(col_name,'_exp')] <- paste(df, col_name, sep='_')
  return(df)
}

df %>%
  mutate(across(.cols=everything(),
                .fns = function(x) sample_func(cur_data_all(), cur_column())))
