import pandas as pd
import sqlalchemy
def get_factor(wt_unit, cal_unit):
    if wt_unit == 'kg' and cal_unit == 'cal':
        factor = 13 * 2.20462
    elif wt_unit == 'kg' and cal_unit == 'kj':
        factor = 13 * 2.20462 * 4.184
    elif wt_unit == 'lb' and cal_unit == 'cal':
        factor = 13
    else:
        factor = 13 * 4.184
    return factor

def new_user(user_name):
    '''
    This function checks in the database if the user is new or not
    '''
    #change this table to weighing scale
    sql_query = '''Select * from app_users as a where a.user = \'{}\''''.format(user_name)
    engine = sqlalchemy.create_engine('sqlite:////Users/mac_air/Documents/Documents/Side Projects/myWeightLossPal/weightloss.db')
    app_db = pd.read_sql(sql = sql_query, con = engine)

    if app_db.shape[0] == 0:
        return True
    else:
        return False

def get_current_tdee(user_name, weight, wt_unit, cal_unit):
    factor = get_factor(wt_unit, cal_unit)
    #if new_user(user_name):
    return weight * factor #rewire it once we get the weighing scale working
#    else:
#        last week weight = getLastWeekWeight(user_name)
#        current_week_weight = getCurrentWeekWeight(user_name)
#        wt_lost = last_week_weight - current_week_weight
#        factored_wt = (wt_lost * factor)/no_of_time_used_last week
#        avg_week_wt = getAverageWeeklyWeight(user_name)
#        new_TDEE = (avg_week_wt + factored_wt)/(len(avg_week_wt) + 1)


