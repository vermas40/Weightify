user_weight_history <- "
  SELECT *
  FROM WEIGHING_SCALE
  WHERE USER='%s'
  ORDER BY DATE
"

wt_unit_query <- "
  SELECT DISTINCT VALUE
  FROM USER_GOALS
  
  WHERE 1=1
  AND USER = '%s'
  AND METRIC = 'wt_unit'
  
  GROUP BY USER
  HAVING DATE = MAX(DATE)
"