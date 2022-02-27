from flask import Flask, jsonify
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
    def get(self, user_name):
        curr_tdee, tgt_tdee = hlp.get_current_tdee(user_name)
        return_json = jsonify(curr_tdee=curr_tdee, tgt_tdee=tgt_tdee)
        return return_json

class weight_time_left(Resource):
    def get(self, user_name):
        weeks_left, curr_wt = hlp.get_weight_time_left(user_name)
        return_json = jsonify(weeks_left=weeks_left, curr_wt=curr_wt)
        return return_json

#the below code creates a URI - Unique resource identifier
#in essence when this URI is hit then it triggers the relevant function
api.add_resource(tdee_capture,'/tdee/<string:user_name>')
api.add_resource(weight_time_left,'/time_left/<string:user_name>')

if __name__ == '__main__':
    app.run(debug=True, use_reloader=False, host='127.0.0.1', port='1234')