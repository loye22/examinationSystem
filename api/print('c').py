from flask import Flask, request, jsonify
from pymongo import MongoClient
from datetime import datetime

app = Flask(__name__)

# MongoDB connection
client = MongoClient('mongodb://localhost:27017/')
db = client['local']  # Change to your actual database name
test_collection = db['test']  # The collection for exams

@app.route('/generate_exam', methods=['POST'])
def generate_exam():
    group = request.json.get('group')

    # Retrieve students in the specified group
    students = db['students'].find({'Groups': group})

    for student in students:
        exam = {
            "student_id": student['ID'],
            "student_name": student['Name'],
            "question": [
                {
                    "question": "Street closures in the surrounding area of specials event site must obtain municipal approval only",
                    "quastionCategory": "True or False",
                    "correctAnswer": "B",
                    "points": 1,
                    "selected_answer": "",
                    "Category": "Special event security2",
                    "options": [
                        {
                            "label": "A",
                            "text": "Right"
                        },
                        {
                            "label": "B",
                            "text": "Wrong"
                        }
                    ]
                },
                # Add more questions here
            ],
            "exam_title": request.json.get('exam_title'),
            "exam_category": request.json.get('exam_category'),
            "class": student['Class'],
            "group": group,
            "active": True,
            "date": str(datetime.utcnow()),
            "starting_time": "",
            "endinging_time": "",
            "platform": "web"
        }
        
        # Insert the exam document into the test collection
        test_collection.insert_one(exam)

    return jsonify({"message": "Exams generated for the group."})

if __name__ == '__main__':
    app.run()
