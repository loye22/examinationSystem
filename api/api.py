from flask import Flask, request, jsonify
from flask_pymongo import PyMongo
from bson.json_util import dumps, loads
from werkzeug.security import generate_password_hash, check_password_hash
from flask_cors import CORS


app = Flask(__name__)
app.config['MONGO_URI'] = 'mongodb://localhost:27017/local'  # Update with your MongoDB URI
cors = CORS(app, resources={r"/api/*": {"origins": "*"}})
mongo = PyMongo(app)


@app.route('/api/auth', methods=['POST'])
def authenticate_user():
    data = request.get_json()
    username = data.get('userName')
    password = data.get('password')

    if not username or not password:
        return jsonify({'message': 'Username and password are required'}), 400

    user = mongo.db.users.find_one({'userName': username})

    if user and user['password'] == password:
        # Successful authentication
        return jsonify({'message': 'Authentication successful'})
    else:
        # Failed authentication
        return jsonify({'message': 'Authentication failed'}), 401



if __name__ =="__main__":
    app.run()