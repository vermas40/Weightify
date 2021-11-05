user_weight_history <- "
  SELECT *
  FROM WEIGHING_SCALE
  WHERE USER='%s'
  ORDER BY DATE
"

unit_query <- "
  SELECT DISTINCT VALUE
  FROM USER_GOALS
  
  WHERE 1=1
  AND USER = '%s'
  AND METRIC = '%s_unit'
  
  GROUP BY USER
  HAVING DATE = MAX(DATE)
"