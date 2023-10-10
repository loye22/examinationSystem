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
import bson.json_util as json_util
import re 
import json as json2




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
        #print('->>>>>>>>>>>>>>>>>>>>>>>>>>' , file)
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
                df = df.fillna("")
                # Iterate through the DataFrame and insert student data into MongoDB
                inserted_students = []
                for index, row in df.iterrows():
                    student_data = {
                    "_id":  ObjectId(),
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
                    "Groups": [group.strip().upper() for group in row["Student Group"].split(",")] if isinstance(row["Student Group"], str) else [],
                    # Add other fields as needed
                    }
                    
                    students_collection.insert_one(student_data)
                    inserted_students.append(student_data)
                print('done')
                return jsonify({"message": "File uploaded and data added to the database"})
            except Exception as e:
                print('error ' , e )
                return jsonify({"error": f"Error: {str(e)}"}), 501
        else:
            print( "Error uploading the file.")
            return jsonify({"error": "Error uploading the file."}), 502
    except Exception as e:
        print('error ' , e )
        return jsonify({"error": f"Error: {str(e)}"}), 503



# re-exam funciotn
# this funciton just append to the Group list the last group with "-RE" to rexam
@app.route('/re_exam', methods=['POST'])
def re_exam():
    try:      
        # MongoDB connection setup
        client = MongoClient("mongodb://localhost:27017/")  # Replace with your MongoDB connection URL
        db = client["local"]  # Replace with your database name
        collection = db["students"]  # Replace with your collection name
        data = request.json
        student_ids = data.get('student_ids', [])
        
        for student_id in student_ids:
            # Find the student document by ID
            student = collection.find_one({'ID': student_id})
            
            if student:
                # Get the current "Groups" list
                current_groups = student.get('Groups', [])
                
                # Append a new group with "-RE" to the last group in the list (if available)
                if current_groups:
                    last_group = current_groups[-1]
                    new_group = f"{last_group}-RE"
                    current_groups.append(new_group)
                
                # Update the "Groups" field with the modified list
                collection.update_one({'ID': student_id}, {'$set': {'Groups': current_groups}})
        
        return jsonify({'message': 'Groups updated successfully'})
    except Exception as e:
        return jsonify({'error': str(e)})


# to search student by certan id 
@app.route('/search_student_byid', methods=['GET'])
def search_student_byid():
    client = MongoClient("mongodb://localhost:27017/")  # Replace with your MongoDB connection URL
    db = client["local"]  # Replace with your database name
    collection = db["students"]  # Replace with your collection name
    try:    
        student_id = request.args.get('student_id', '')
        if not student_id:
            return jsonify({'error': 'Student ID is required'})
        # Search for students with IDs containing the provided search string
        regex = re.compile(f'.*{student_id}.*', re.IGNORECASE)
        students = list(collection.find({'ID': {'$regex': regex}}))

        if students:
            # Convert ObjectId to a string in the result
            for student in students:
                student['_id'] = str(student['_id'])

            return jsonify(students)
        else:
            return jsonify({'message': 'No matching students found'})
    except Exception as e:
            return jsonify({'error': str(e)})
    
# get all the quasation category
@app.route('/questions_unique_categories', methods=['GET'])
def unique_categories():
    try:
        # MongoDB connection setup
        client = MongoClient("mongodb://localhost:27017/")  # Replace with your MongoDB connection URL
        db = client["local"]  # Replace with your database name
        collection = db["quastion"]  # Replace with your collection name
        # Use the aggregation framework to find distinct categories
        pipeline = [
            {"$group": {"_id": "$Category"}},
        ]

        categories = list(collection.aggregate(pipeline))

        if categories:
            unique_categories = [category['_id'] for category in categories]
            return jsonify(unique_categories)
        else:
            return jsonify({'message': 'No categories found'})
    except Exception as e:
        return jsonify({'error': str(e)})

#this function will return the first 50 quastion
@app.route('/get_first_50_questions', methods=['GET'])
def get_first_50_questions():
    # MongoDB connection setup
    client = MongoClient("mongodb://localhost:27017/")  # Replace with your MongoDB connection URL
    db = client["local"]  # Replace with your database name
    collection = db["quastion"]  # Replace with your collection name
    try:
        # Find the first 50 questions
        questions = list(collection.find().limit(50))

        if questions:
            # Remove the "_id" field from each question
            for question in questions:
                question.pop('_id', None)

            return jsonify(questions)
        else:
            return jsonify({'message': 'No questions found'})
    except Exception as e:
        return jsonify({'error': str(e)})


# this function will return all the quastion for sepcifec categort 
@app.route('/get_questions_by_category', methods=['GET'])
def get_questions_by_category():
    try:
        # MongoDB connection setup
        client = MongoClient("mongodb://localhost:27017/")  # Replace with your MongoDB connection URL
        db = client["local"]  # Replace with your database name
        collection = db["quastion"]  # Replace with your collection name
        category = request.args.get('category', '')
        print(category)

        if not category:
            return jsonify({'error': 'category is required'})

        # Find questions by the specified category
        questions = list(collection.find({'Category': category}))

        if questions:
            # Remove the "_id" field from each question
            for question in questions:
                question.pop('_id', None)

            return jsonify(questions)
        else:
            return jsonify({'message': 'No questions found for the specified category'})
    except Exception as e:
        return jsonify({'error': str(e)})




# this function will retuerns all the exam's categorys
@app.route('/exam_categories', methods=['GET'])
def get_exam_categories():
    # MongoDB connection setup
    client = MongoClient("mongodb://localhost:27017")  # Replace with your MongoDB connection string
    db = client["local"]  # Replace with your database name
    collection = db["test"]  # Replace with your collection name
    # Use aggregation to retrieve unique exam categories
    pipeline = [
        {"$group": {"_id": "$exam_category"}},
        {"$sort": {"_id": 1}}
    ]
    categories = list(collection.aggregate(pipeline))

    # Extract category names from the result
    category_names = [category["_id"] for category in categories]

    return jsonify({"exam_categories": category_names})
'''
@app.route('/exam_data', methods=['GET'])
def get_exam_data():
    # MongoDB connection setup
    client = MongoClient("mongodb://localhost:27017")  # Replace with your MongoDB connection string
    db = client["local"]  # Replace with your database name
    collection = db["test"] 
     # Retrieve the first 50 rows of data from the collection
    data = list(collection.find().limit(50))

    # Serialize the data to JSON with ObjectId converted to strings
    serialized_data = []
    for doc in data:
        # Convert ObjectId to string for the '_id' field
        doc['_id'] = str(doc['_id'])
        serialized_data.append(doc)

    return jsonify(serialized_data)
'''



# Custom JSON encoder to handle ObjectId serialization
class JSONEncoder(json2.JSONEncoder):
    def default(self, o):
        if isinstance(o, ObjectId):
            return str(o)
        return super(JSONEncoder, self).default(o)

@app.route('/exam_data2', methods=['GET'])
def get_exam_data2():
    # MongoDB connection setup
    client = MongoClient("mongodb://localhost:27017")  # Replace with your MongoDB connection string
    db = client["local"]  # Replace with your database name
    collection = db["test"] 

    # Define the aggregation pipeline to group by "exam_title"
    pipeline = [
        {
            "$group": {
                "_id": "$exam_title",
                "exam_data": {"$push": "$$ROOT"}  # Store all documents for each exam title
            }
        }
    ]

    # Execute the aggregation pipeline
    aggregation_result = list(collection.aggregate(pipeline))

    # Serialize the data using the custom JSON encoder
    serialized_data = JSONEncoder().encode(aggregation_result)

    return serialized_data



if __name__ == "__main__":
    app.run()
    
