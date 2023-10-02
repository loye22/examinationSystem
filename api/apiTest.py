from flask import Flask, request, jsonify
from flask_pymongo import PyMongo
from bson.json_util import dumps, loads
from werkzeug.security import generate_password_hash, check_password_hash
from flask_cors import CORS
import jwt 
from pymongo import MongoClient
import pandas as pd
import os
from bson import ObjectId  # Import ObjectId from pymongo




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
    try : 
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
    except Exception as e  :
        print('Error at authenticate_user(): ' , e )
        return jsonify({"error at authenticate_user() \n": str(e)}), 500

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
# ex. http://localhost:5000/getStudentsData?group=SOL3 B477-2023
@app.route('/getStudentsData', methods=['GET'])
def get_students_data():
    try:
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
    except Exception as e :
        print('Error at get_students_data() \n ' ,e   ) 
        return jsonify({"error at get_students_data()": str(e)}), 500

# this function will return the first 50 student 
@app.route('/getFirst50Students', methods=['GET'])
def get_first_50_students():
    try:
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
    except Exception as e  :
        print('Error at get_first_50_students() \n ' , e )
        return jsonify({"error get_first_50_students() \n": str(e)}), 500


# this function will add new students
@app.route('/insert_student', methods=['POST'])
def insert_student():
    try:
        client = MongoClient('mongodb://localhost:27017/')  # Replace with your MongoDB connection string
        db = client['local']  # Replace 'local' with your actual database name
        students_collection = db['students']  # Replace 'students' with your actual collection name

        # Get student data from the request
        student_data = {
            "Name": request.json["Name"],
            "ID": request.json["ID"],
            "Study ID": request.json["Study ID"],
            "Class": request.json["Class"],
            "Job ID": request.json["Job ID"],
            "Nationality": request.json["Nationality"],
            "Class No": request.json["Class No"],
            "Seat No": request.json["Seat No"],
            "Seat": request.json["Seat"],
            "Type of Course": request.json["Type of Course"],
            "Groups": request.json["Groups"]
        }

        # Insert the student data into the MongoDB collection
        result = students_collection.insert_one(student_data)

        # Return a response with the inserted student's ID
        response = {"message": "Student inserted successfully", "inserted_id": str(result.inserted_id)}
        return jsonify(response), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# this function will add patch to the database 
@app.route('/upload', methods=['POST'])
def upload_excel():
    mongo_client = MongoClient('mongodb://localhost:27017')
    db = mongo_client['local']
    students_collection = db['test']
    try:
        # Check if a file was included in the request
        if 'file' not in request.files:
            return jsonify({"error": "No file part"}), 400

        file = request.files['file']

        # Check if the file has an allowed extension (e.g., .xlsx)
        if file.filename == '':
            return jsonify({"error": "No selected file"}), 400
        if file:
            try:
                app.config['UPLOAD_FOLDER'] = r'C:\Users\Louie\StudioProjects\tsti_exam_sys\api\UPLOAD_FOLDER'
                # Save the uploaded file to the UPLOAD_FOLDER
                file.save(os.path.join(app.config['UPLOAD_FOLDER'], file.filename))
                # Read the uploaded Excel file into a DataFrame
                df = pd.read_excel(os.path.join(app.config['UPLOAD_FOLDER'], file.filename))
                # Iterate through the DataFrame and insert student data into MongoDB
                inserted_students = []
                for index, row in df.iterrows():
                    student_data = {
                    "_id": str(ObjectId()), 
                    "Name": row["Name"],
                    "ID": row["ID"],
                    "Study ID": "",
                    "Class": row["Class"],
                    "Job ID": "",
                    "Nationality": row["Nationality"]  ,
                    "Class No": "",
                    "Seat No":"",
                    "Seat": "",
                    "Type of Course": row["Course"],
                    "Groups": [group.strip() for group in row["Student Group"].split(",")] if isinstance(row["Student Group"], str) else [],
                    # Add other fields as needed
                    }
                    students_collection.insert_one(student_data)
                    inserted_students.append(student_data)

                print('done')
                return jsonify({"message": "File uploaded and data added to the database", "inserted_students": inserted_students})
            except Exception as e:
                print('error ' , e )
                return jsonify({"error": f"Error: {str(e)}"}), 500
        else:
            print( "Error uploading the file.")
            return jsonify({"error": "Error uploading the file."}), 500
    except Exception as e:
        print('error ' , e )
        return jsonify({"error": f"Error: {str(e)}"}), 500



if __name__ == "__main__":
    app.run()
    
