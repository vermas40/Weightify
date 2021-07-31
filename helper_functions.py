import pandas as pd
import numpy as np
import sqlalchemy
from datetime import datetime

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

def update_db(week_dict):
    df = pd.DataFrame(week_dict, index=[0])
    df_melt = df.melt(id_vars=['user','date_created','year','week_in_yr'],\
                      var_name='metric', value_name='value')
    
    engine = create_engine('weightloss.db')
    tdee_df = pd.read_sql('hist_tdee', engine)
    tdee_df = pd.concat([tdee_df,df_melt]).reset_index(drop=True)

    tdee_df = tdee_df.sort_values(by=['user','year','week_in_yr','date_created'], ascending=False,\
                                  ignore_index=False)
    
    drop_idx = tdee_df.duplicated(subset=['user','year','week_in_yr','metric'], keep='first')
    drop_idx = drop_idx.index[drop_idx==True]
    tdee_df = tdee_df.drop(drop_idx)
    tdee_df = tdee_df.reset_index(drop=True)

    tdee_df.to_sql('hist_tdee', engine, if_exists='replace', index=False)
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
    weight_df = get_data('weighing_scale', user_name, 'weightloss.db')

    if weight_df.shape[0] == 0:
        return True
    else:
        return False

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
    max_year = max(df['year'])
    max_week = max(df.loc[df['year'] == max_year,'week_in_yr'])
    week_data['wt'] = df.loc[((df['year'] == max_year) & (df['week_in_yr'] == max_week)),\
                                'wt'].astype(float).mean()
    week_data['cal'] = df.loc[((df['year'] == max_year) & (df['week_in_yr'] == max_week)),\
                                'cal'].astype(float).mean()
    week_data['year'] = max_year
    week_data['week_in_yr'] = max_week
    week_data['date_created'] = datetime.now().strftime("%d-%b-%Y %H:%M:%S")
    week_data['user'] = user_name

    update_db(week_data)
    return week_data

def get_last_week_data(user_name, info):
    weight_df = get_data('weighing_scale', user_name, 'weightloss.db')
    df = weight_df.pivot(index=['user','date_created','date',\
                                                     'year','month','week_in_yr'],\
                                              columns='metric', values='value')\
                             .reset_index()
    max_year = max(df['year'])
    #getting the list of weeks for which the tool was used
    weeks_list = df.loc[df['year'] == max_year, 'week_in_yr'].unique().sort()
    #getting last week, as the tool may not be used every week
    week = weeks_list[-2]
    #finding out the num times the tool was used
    num_times_used = df.loc[((df['year'] == max_year) & (df['week_in_yr'] == week)),].shape[0]
    #polymorphism
    if info == 'weight':
        result = df.loc[((df['year'] == max_year) & (df['week_in_yr'] == week) &\
                         (df['source']=='user_generated')), 'wt'].astype(float).mean()
    else:
        result = df.loc[((df['year'] == max_year) & (df['week_in_yr'] == week) &\
                         (df['source']=='user_generated')), 'cal'].astype(float).mean()
    return result, num_times_used

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

    return starter_data

def get_weight_time_left(user_name):
    '''
    This function finds out the weeks left to reach goal weight

    Input
    1. user_name: str, the name of the user for whom the data needs to be fetched
    
    Returms
    1. weeks_left: int, the number of weeks left to reach goal weight
    2. curr_wt: float, the current weight of the user
    '''
    starter_data = get_starter_data(user_name)
    if new_user(user_name):
        curr_wt = starter_data['wt']
    else:
        curr_wt = get_current_week_data(user_name)['wt']
    wt_left = np.absolute(curr_wt - starter_data['goal_wt'])
    weeks_left = wt_left/starter_data['loss_slope']
    weeks_left = round(weeks_left,0)
    return weeks_left, curr_wt

def get_current_tdee(user_name):
    '''
    This function calculates the current tdee of the user

    Input
    1. user_name: str, the name of the user for whom the data needs to be fetched

    Returns:
    1. new_TDEE: float, this is the current tdee of the user
    '''
    starter_data = get_starter_data(user_name)
    factor = get_factor(starter_data['wt_unit'], starter_data['cal_unit'])
    if new_user(user_name):
        return starter_data['wt'] * factor 
    else:
        #last_week_wt, num_times_used = get_last_week_data(user_name, 'weight')
        curr_week_data = get_current_week_data(user_name)
        current_week_wt = curr_week_data['wt']
        current_week_cal = curr_week_data['cal']
        
        wt_lost = (current_week_wt - starter_data['wt']) * (-1)
        factored_wt = (wt_lost * factor)/7
        new_TDEE = current_week_cal + factored_wt
        return new_TDEE

get_current_tdee('2')