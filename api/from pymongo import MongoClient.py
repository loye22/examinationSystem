import pymongo
from bson import ObjectId

# Connection to the local MongoDB server (you can replace this with your MongoDB URI)
client = pymongo.MongoClient("mongodb://localhost:27017/")
database = client["local"]  # Replace with your database name
collection = database["test"]  # Use your collection name

# Sample exam data records
exams = [
    {
        "student_id": "mbk1160",
        "student_name": "MOSES BISASO",
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
            # Add more questions as needed
        ],
        "exam_title": "Sample Exam 1",
        "exam_category": "Geography",
        "class": "Class-2023-874",
        "group": "SOL3-C68-2023-AR",
        "active": True,
        "date": "2023-10-15T09:00:00Z",
        "starting_time": "2023-10-15T09:00:00Z",
        "endinging_time": "2023-10-15T11:00:00Z",
        "platform": "web"
    },
 
]

# Insert the exam data into the collection
collection.insert_many(exams)

# Close the MongoDB connection
client.close()

print("Inserted 3 exam records into the 'test' collection.")
