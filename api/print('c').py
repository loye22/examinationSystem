from flask import Flask, request, jsonify
from pymongo import MongoClient
import random

app = Flask(__name__)

# Connect to your MongoDB database
client = MongoClient('mongodb://localhost:27017/')  # Replace with your MongoDB connection string
db = client['local']  # Replace with your database name
collection = db['quastion']  # Replace with your collection name

@app.route('/get_random_questions', methods=['POST'])
def get_random_questions():
    data = request.json  # Assuming the data is sent as a JSON list of elements

    result = []

    for element in data:
        category = element.get('cat')

        # Find questions that match the category
        questions = list(collection.find({"Category": category}))

        if questions:
            # Select a random question from the list for each element
            random_question = random.choice(questions)
            
            # Convert the ObjectId to a string
            random_question['_id'] = str(random_question['_id'])
            questions['_id'] = str(questions['_id'])

            result.append(random_question)

    return jsonify(questions)

if __name__ == '__main__':
    app.run(debug=True)
