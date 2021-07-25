import pandas as pd
import numpy as np
import sqlalchemy

def create_engine(db_name):
    location = '/Users/mac_air/Documents/Documents/Side Projects/myWeightLossPal/'
    engine = sqlalchemy.create_engine('sqlite:///' + location + db_name)
    return engine
    
def get_data(table_name, user_name, db_name):
    engine = create_engine(db_name)
    query = '''Select * from {} where user = \'{}\''''.format(table_name,user_name)
    df = pd.read_sql(sql=query, con=engine)
    return df

def get_factor(wt_unit, cal_unit):
    if wt_unit == 'kg' and cal_unit == 'cal':
        factor = 13 * 2.20462
    elif wt_unit == 'kg' and cal_unit == 'kj':
        factor = 13 * 2.20462 * 4.184
    elif wt_unit == 'lb' and cal_unit == 'cal':
        factor = 13
    elif wt_unit == 'lb' and cal_unit == 'kj':
        factor = 13 * 4.184
    return factor

def new_user(user_name):
    '''
    This function checks in the database if the user is new or not
    '''
    #change this table to weighing scale
    engine = create_engine('weightloss.db')
    sql_query = '''Select * from app_users where user = \'{}\''''.format(user_name)
    app_db = pd.read_sql(sql = sql_query, con = engine)

    if app_db.shape[0] == 0:
        return True
    else:
        return False

def get_current_weight(df):
    max_year = max(df['year'])
    max_week = max(df.loc[df['year'] == max_year,'week_in_yr'])
    curr_wt = df.loc[((df['year'] == max_year) & (df['week_in_yr'] == max_week)), 'wt'].mean()
    return curr_wt

def get_weeks_left(user_name):
    '''
    This function finds out the weeks left to reach goal weight
    '''
    weight_df = get_data('weighing_scale', user_name, 'weightloss.db')
    goals_df = get_data('user_goals', user_name, 'weightloss.db')

    weight_df_pvt = weight_df.pivot(index=['user','date_created',\
                                                     'year','month','week_in_yr'],\
                                              columns='metric', values='value')\
                             .reset_index()
    
    goals_df_pvt = goals_df.pivot(index=['user','date_created',\
                                                     'year','month','week_in_yr'],\
                                              columns='metric', values='value')\
                           .reset_index()
    curr_wt = get_current_weight(weight_df_pvt)
    wt_left = np.absolute(curr_wt - float(goals_df_pvt['goal_wt'][0]))
    weeks_left = wt_left/float(goals_df_pvt['loss_slope'][0])
    weeks_left = round(weeks_left,0)
    return weeks_left


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

