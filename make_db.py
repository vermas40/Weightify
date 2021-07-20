import sqlite3
#creating database
conn = sqlite3.connect('/Users/mac_air/Documents/Documents/Side Projects/myWeightLossPal/weightloss.db')

#creating a table
cursor_obj = conn.cursor()

#creating the table
cursor_obj.execute(
    '''
    CREATE TABLE weighing_scale(
        user_id text,
        start_date text,
        year integer,
        month integer,
        week_in_yr integer,
        weight real,
        calories real
    )
    '''
)

cursor_obj.execute(
    '''
    CREATE TABLE app_users(
        user text,
        password text,
        date_created text,
        is_hashed_password text
    )
    '''
)

cursor_obj.execute(
    '''
    CREATE TABLE user_goals(
        user text,
        date_created text,
        year integer,
        month integer,
        week_in_yr integer,
        metric text,
        value text
    )
    '''
)
#commiting changes and closing connection
conn.commit()
conn.close()