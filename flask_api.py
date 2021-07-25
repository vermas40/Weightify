from flask import Flask, request
from flask_restful import Resource, Api

#importing user defined functions
import helper_functions as hlp

#the below code creates a flask app and api 
#for easy management of urls
app = Flask(__name__)
api = Api(app)

#creating different resources - resources here is an abstraction for data handling
#different classes for handling different link requests
class tdee_capture(Resource):
    def get(self, user_name, weight, wt_unit, cal_unit):
        return hlp.get_current_tdee(user_name, weight, wt_unit, cal_unit)

class weeks_left(Resource):
    def get(self, user_name):
        return hlp.get_weeks_left(user_name)

#the below code creates a URI - Unique resource identifier
#in essence when this URI is hit then it triggers the relevant function
api.add_resource(tdee_capture,'/<string:user_name>/<int:weight>/<string:wt_unit>/<string:cal_unit>')
api.add_resource(weeks_left,'/<string:user_name>')

if __name__ == '__main__':
    app.run(debug=True)