from flask import Flask, request, jsonify
from flask_pymongo import PyMongo
from bson.json_util import dumps, loads
from werkzeug.security import generate_password_hash, check_password_hash
from flask_cors import CORS
import jwt 
from pymongo import MongoClient


app = Flask(__name__)
app.config['MONGO_URI'] = 'mongodb://localhost:27017/local'  # Update with your MongoDB URI
CORS(app, resources={r"/api/*": {"origins": "*"}})  # Allow all origins for the /api/* route
mongo = PyMongo(app)




# Define the add_cors_headers function to include CORS headers in responses
@app.after_request
def add_cors_headers(response):
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS, PUT, DELETE'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
    return response



SECRET_KEY = '0940912246'
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
        token = jwt.encode({'username': username}, SECRET_KEY, algorithm='HS256')
        return jsonify({'message': 'Authentication successful', 'token': token})
        #return jsonify({'message': 'Authentication successful'})
    else:
        # Failed authentication
        return jsonify({'message': 'Authentication failed'}), 401
    


def verify_token(func):
    def wrapper(*args, **kwargs):
        token = request.headers.get('Authorization')

        if not token:
            return jsonify({'message': 'Token is missing'}), 401

        try:
            decoded_token = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
            # You can access decoded_token['username'] to get the username
            return func(*args, **kwargs)

        except jwt.ExpiredSignatureError:
            return jsonify({'message': 'Token has expired'}), 401
        except jwt.DecodeError:
            return jsonify({'message': 'Invalid token'}), 401

    return wrapper

@app.route('/api/secure-route', methods=['GET'])
@verify_token
def secure_route():
    # This route is secure, and the token has been validated
    return jsonify({'message': 'Secure route accessed'})

    

#this function will return all the groups in my DB without redundancy
@app.route('/unique_groups', methods=['GET'])
def get_unique_groups():
    try:
        # Connect to MongoDB
        client = MongoClient("mongodb://localhost:27017/")
        db = client['local']
        collection = db['students']

        # Query MongoDB to get unique groups
        unique_groups = collection.distinct("Groups")

        # Close the MongoDB connection
        client.close()

        return jsonify({"unique_groups": unique_groups})

    except Exception as e:
        return jsonify({"error": str(e)})


# this function returns all the students for specific group 
@app.route('/getStudentsData', methods=['GET'])
def get_students_data():
    # MongoDB connection
    client = MongoClient('mongodb://localhost:27017/')
    db = client['local']  # Use your MongoDB database name
    students_collection = db['students']  # Use your collection name
    # Get the group parameter from the request
    group = request.args.get('group')
    # Check if the 'group' parameter is provided
    if not group:
        return jsonify({"error": "Group parameter is required"}), 400

    # Query the MongoDB collection to find students in the specified group
    students_in_group = students_collection.find({"Groups": group})

    # Create a list to store the results
    results = []

    # Iterate through the matching documents and extract the relevant data
    for student in students_in_group:
        student_data = {
            "_id": str(student['_id']),
            "Name": student['Name'],
            "ID": student['ID'],
            "Class": student['Class'],
            "Nationality": student['Nationality'],
            "Seat": student['Seat'],
            "Groups": student['Groups']
        }
        results.append(student_data)

    return jsonify(results)

# this function will return the first 50 student 
@app.route('/getFirst50Students', methods=['GET'])
def get_first_50_students():
    # MongoDB connection
    client = MongoClient('mongodb://localhost:27017/')
    db = client['local']  # Use your MongoDB database name
    students_collection = db['students']  # Use your collection name
    # Query the MongoDB collection to find the first 50 students
    students = students_collection.find().limit(50)

    # Create a list to store the results
    results = []

    # Iterate through the matching documents and extract the relevant data
    for student in students:
        student_data = {
            "_id": str(student['_id']),
            "Name": student['Name'],
            "ID": student['ID'],
            "Class": student['Class'],
            "Nationality": student['Nationality'],
            "Seat": student['Seat'],
            "Groups": student['Groups']
        }
        results.append(student_data)

    return jsonify(results)



if __name__ == "__main__":
    app.run()
