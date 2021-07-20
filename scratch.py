import sqlite3
#creating database
conn = sqlite3.connect('/Users/mac_air/Documents/Documents/Side Projects/myWeightLossPal/weightloss.db')

#creating a table
cursor_obj = conn.cursor()

sql_query = """SELECT * from app_users;"""

cursor_obj.execute(sql_query)
#commiting changes and closing connection
df = cursor_obj.fetchall()
conn.commit()
conn.close()