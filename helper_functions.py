import pandas as pd
import numpy as np
import sqlalchemy
from datetime import datetime
import copy

'''
Progress
1. R code is working fine
2. The data to all the database tables is fine
3. The algorithm code in which python has to generate output is suffering
a. The wt_lost has to be current week vs last week
b. Check the math being done in num_weeks section and if it is in line
'''

def create_engine(db_name):
    '''
    This function creates an engine for connection to sqlite db
    '''
    location = '/Users/mac_air/Documents/Documents/Side Projects/myWeightLossPal/'
    engine = sqlalchemy.create_engine('sqlite:///' + location + db_name)
    return engine
    
def get_data(table_name, user_name, db_name):
    '''
    This function queries the database for a particular db
    
    Input
    1. table_name: str, name of the table to pull
    2. user_name: str, name of the user for whom the records are required
    3. db_name: str, name of the database

    Returns
    1. df: pandas dataframe, dataframe of the required table and user
    '''
    engine = create_engine(db_name)
    query = '''Select * from {} where user = \'{}\''''.format(table_name,user_name)
    df = pd.read_sql(sql=query, con=engine)
    engine.dispose()
    return df

def update_db(table_name, week_dict={}):
    if isinstance(week_dict, dict):
        df = pd.DataFrame(week_dict, index=[0])
    else:
        df = copy.deepcopy(week_dict)
    df_melt = df.melt(id_vars=['user','date_created','year','week_in_yr'],\
                      var_name='metric', value_name='value')
    
    engine = create_engine('weightloss.db')
    tdee_df = pd.read_sql(table_name, engine)
    tdee_df = pd.concat([tdee_df,df_melt]).reset_index(drop=True)

    tdee_df = tdee_df.sort_values(by=['user','year','week_in_yr','date_created'], ascending=False,\
                                  ignore_index=False)
    
    drop_idx = tdee_df.duplicated(subset=['user','year','week_in_yr','metric'], keep='first')
    drop_idx = drop_idx.index[drop_idx==True]
    tdee_df = tdee_df.drop(drop_idx)
    tdee_df = tdee_df.reset_index(drop=True)

    tdee_df.to_sql(table_name, engine, if_exists='replace', index=False)
    return

def get_factor(wt_unit, cal_unit):
    '''
    This function calculates the factor i.e. used for calculating current tdee

    Input
    1. wt_unit: str, the weight unit being used by user
    2. cal_unit: str, the calorie unit being used by user

    Returns
    1. factor: float, the tdee calculation factor
    '''
    if wt_unit == 'kg' and cal_unit == 'cal':
        beginner_factor = 13 * 2.20462
        user_factor = 3500 * 2.20462
    elif wt_unit == 'kg' and cal_unit == 'kj':
        beginner_factor = 13 * 2.20462 * 4.184
        user_factor = 3500 * 2.20462 * 4.184
    elif wt_unit == 'lb' and cal_unit == 'cal':
        beginner_factor = 13
        user_factor = 3500
    elif wt_unit == 'lb' and cal_unit == 'kj':
        beginner_factor = 13 * 4.184
        user_factor = 3500 * 4.184
    return beginner_factor, user_factor

def new_user(user_name):
    '''
    This function checks in the database if the user is new or not
    '''
    #change this table to weighing scale
    weight_df = get_data('weighing_scale', user_name, 'weightloss.db')

    if weight_df.shape[0] == 0:
        return True
    else:
        return False

def update_user_performance(df):
    df = df.groupby(['user','year','month','week_in_yr'])\
           .agg({'wt':lambda x: x.astype(float).mean(),\
                 'cal':lambda x: x.astype(float).mean()}).reset_index()
    df['date_created'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    update_db('user_performance', df)
    return
    
def get_current_week_data(user_name):
    '''
    This function calculates the current week's average weight and calories consumed

    Input:
    1. user_name: str, the user for which the data needs to be calculated

    Returns:
    1. week_data: dict, python dict containing the current week's weight and calories
    of the user
    '''
    week_data = {}
    weight_df = get_data('weighing_scale', user_name, 'weightloss.db')
    
    df = weight_df.pivot(index=['user','date_created','date',\
                                'year','month','week_in_yr'],\
                        columns='metric', values='value')\
                  .reset_index()
    update_user_performance(df)
    max_year = max(df['year'])
    max_week = max(df.loc[df['year'] == max_year,'week_in_yr'])
    week_data['wt'] = df.loc[((df['year'] == max_year) & (df['week_in_yr'] == max_week)),\
                                'wt'].astype(float).mean()
    week_data['cal'] = df.loc[((df['year'] == max_year) & (df['week_in_yr'] == max_week)),\
                                'cal'].astype(float).mean()
    week_data['year'] = max_year
    week_data['week_in_yr'] = max_week
    week_data['date_created'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    week_data['user'] = user_name

    return week_data

def get_starter_data(user_name):
    '''
    This function pulls the goals of a user

    Input:
    1. user_name: str, the name of the user for whom the data needs to be fetched

    Return
    1. started_data: dict, dictionary containing starting weight, goal weight,
    weight unit, calorie unit for calculation, loss slope i.e. rate of weight loss
    '''
    starter_data={}
    df = get_data('user_goals', user_name, 'weightloss.db')
    starter_data['wt'] = float(df.loc[df['metric']=='curr_wt','value'].unique()[-1])
    starter_data['wt_unit'] = df.loc[df['metric']=='wt_unit','value'].unique()[-1]
    starter_data['cal_unit'] = df.loc[df['metric']=='cal_unit','value'].unique()[-1]
    starter_data['goal_wt'] = float(df.loc[df['metric']=='goal_wt','value'].unique()[-1])
    starter_data['loss_slope'] = float(df.loc[df['metric']=='loss_slope','value'].unique()[-1])
    
    #this is for the hist_tdee (to be renamed) table
    avg_wt_cal_data = {}
    avg_wt_cal_data['wt'] = float(df.loc[df['metric']=='curr_wt','value'].unique()[-1])
    avg_wt_cal_data['year'] = df['year'].unique()[-1]
    #so that it can be used for the current week in year
    avg_wt_cal_data['week_in_yr'] = df['week_in_yr'].unique()[-1] - 1
    avg_wt_cal_data['user'] = df['user'].unique()[-1]
    factor,_ = get_factor(starter_data['wt_unit'],starter_data['cal_unit'])
    cal = avg_wt_cal_data['wt'] * factor
    avg_wt_cal_data['cal'] = cal
    avg_wt_cal_data['date_created'] = df['date_created'].unique()[-1]
    #it only works with going in forward direction. We need to patch this so that
    #user can come in and change data in the past as well
    update_db('user_performance', avg_wt_cal_data)

    return starter_data, avg_wt_cal_data

def get_weight_time_left(user_name):
    '''
    This function finds out the weeks left to reach goal weight

    Input
    1. user_name: str, the name of the user for whom the data needs to be fetched
    
    Returms
    1. weeks_left: int, the number of weeks left to reach goal weight
    2. curr_wt: float, the current weight of the user
    '''
    starter_data,_ = get_starter_data(user_name)
    if new_user(user_name):
        curr_wt = starter_data['wt']
    else:
        curr_wt = get_current_week_data(user_name)['wt']
    wt_left = np.absolute(curr_wt - starter_data['goal_wt'])
    weeks_left = wt_left/starter_data['loss_slope']
    weeks_left = round(weeks_left,0)
    return weeks_left, curr_wt

def get_factored_tdee(user_name):
    df = get_data('tdee_hist', user_name, 'weightloss.db')
    df = df.pivot(index=['user','date_created','year','week_in_yr'],\
                  columns='metric', values='value').reset_index()
    df = df.sort_values(by=['year','week_in_yr'], ignore_index=True)
    tdee_list = df['tdee'].to_list()
    tdee_list = [float(tdee) for tdee in tdee_list]
    #this factor has to be the week number in chronology
    num_weeks = len(df.loc[df['source']=='regular_user','week_in_yr'].unique())
    # if num_weeks > 0: 
    #     tdee_list = [tdee/num_weeks for tdee in tdee_list][1:]
    # else:
    #     tdee_list = tdee_list[1:]
    tdee_list = tdee_list[1:]
    return tdee_list, num_weeks

def get_current_tdee(user_name):
    '''
    This function calculates the current tdee of the user

    Input
    1. user_name: str, the name of the user for whom the data needs to be fetched

    Returns:
    1. new_TDEE: float, this is the current tdee of the user
    '''
    starter_data, avg_wt_cal_data = get_starter_data(user_name)
    beginner_factor, user_factor = get_factor(starter_data['wt_unit'], starter_data['cal_unit'])
    if new_user(user_name):
        tdee = starter_data['wt'] * beginner_factor 
        curr_week_data = avg_wt_cal_data
        #adding data to the database for the tdee as soon as it is created
        hist_data = {'user':curr_week_data['user'], 'year':curr_week_data['year'],\
                    #week in year -1 in the avg dictionary
                    'week_in_yr':curr_week_data['week_in_yr'],
                    'tdee':tdee,
                    'date_created':datetime.now().strftime('%Y-%m-%d'),
                    'source':'new_user'
                    }
    else:
        curr_week_data = get_current_week_data(user_name)
        current_week_wt = curr_week_data['wt']
        current_week_cal = curr_week_data['cal']
        #this has to be the weight lost as compared to last week 
        wt_lost = (current_week_wt - starter_data['wt']) * (-1)
        factored_wt = (wt_lost * user_factor)/7
        tdee_list, num_used = get_factored_tdee(user_name)

        if num_used <= 1:
            tdee = current_week_cal + factored_wt
        else:
            tdee = current_week_cal + factored_wt
            tdee = tdee + sum(tdee_list)
            tdee = tdee/num_used
        
        hist_data = {'user':curr_week_data['user'], 'year':curr_week_data['year'],\
            #week in year -1 in the avg dictionary
            'week_in_yr':curr_week_data['week_in_yr'],
            'tdee':tdee,
            'date_created':datetime.now().strftime('%Y-%m-%d'),
            'source':'regular_user'
            }
    
    
    update_db('tdee_hist',hist_data)
    return tdee

get_current_tdee('5')