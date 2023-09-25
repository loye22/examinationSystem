import docx
import json
import re

# Function to convert a DOCX file to JSON
def docx_to_json(docx_file):
    doc = docx.Document(docx_file)
    
    questions_list = []
    current_question = None
    options = []

    for paragraph in doc.paragraphs:
        text = paragraph.text.strip()

        # Check if the paragraph starts with a question number
        if re.match(r'^\d+\[.*\]', text):
            if current_question:
                current_question["options"] = options
                questions_list.append(current_question)
                options = []

            question_text = text.split("[")[1].split("]")[1].strip()
            current_question = {"question": question_text}
            current_question["quastionCategory"] = re.search(r'\[(.*?)\]', text).group(1)

        elif text.startswith("A. ") or text.startswith("B. ") or text.startswith("C. "):
            if current_question:
                option = {
                    "label": text[0],
                    "text": text[3:]
                }
                options.append(option)

        elif text.startswith("[Answers]"):
            if current_question:
                answer_data = text.split("[Answers]")[1].strip()
                current_question["correctAnswer"] = answer_data.split("[Points]")[0].strip()
                current_question["points"] = int(re.search(r'\d+', answer_data.split("[Points]")[1]).group())
                current_question["Category"] = text.split("[Category]")[1].strip().replace("[Labels]" , "").strip()
        elif text.startswith("[Labels]"):
            if current_question:
                current_question["labels"] = []

    if current_question:
        current_question["options"] = options
        questions_list.append(current_question)

    # Convert the list of questions to JSON
    print(len(questions_list))
    json_data = json.dumps(questions_list, indent=2, ensure_ascii=False)

    return json_data


# Usage example:
docx_file = "q2.docx"
json_data = docx_to_json(docx_file)

# Print the JSON data
#print(json_data)


# Specify the filename where you want to save the JSON data
json_filename = "output2.json"

# Write the JSON data to the file
with open(json_filename, "w", encoding="utf-8") as json_file:
    json_file.write(json_data)

print(f"JSON data has been saved to {json_filename}")



'''
import json
from pymongo import MongoClient

# Connect to your MongoDB server (replace the connection string)
client = MongoClient("mongodb://localhost:27017/")
db = client["your_database_name"]  # Replace with your actual database name
collection = db["quastion"]  # Replace with your actual collection name

# Load the JSON data from the file
json_filename = "output.json"  # Replace with the actual filename
with open(json_filename, "r", encoding="utf-8") as json_file:
    data = json.load(json_file)

# Insert the data into the MongoDB collection
collection.insert_many(data)

# Close the MongoDB connection
client.close()

print("Data has been inserted into the MongoDB collection.")
'''
