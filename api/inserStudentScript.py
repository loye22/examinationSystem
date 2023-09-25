import pandas as pd
import json

# Read the CSV file into a pandas DataFrame
df = pd.read_csv('Allstudentsliststudents.csv', delimiter=',')  # Replace 'your_csv_file.csv' with the path to your CSV file

# Clean up the DataFrame
df = df.fillna('')  # Replace NaN values with empty strings
df = df.apply(lambda x: x.str.strip() if x.dtype == "object" else x)  # Remove leading/trailing spaces from string columns

# Split the "Groups" column into a list of groups
df['Groups'] = df['Groups'].str.split(',')

# Convert the DataFrame to a list of dictionaries
records = df.to_dict(orient='records')

# Convert the list of dictionaries to JSON
json_data = json.dumps(records, ensure_ascii=False, indent=2)

# Print or save the JSON data as needed
#with open('students.json', 'w', encoding='utf-8') as json_file:
#   json_file.write(json_data)



import json
from pymongo import MongoClient

# Connect to your MongoDB server (replace the connection string)
client = MongoClient("mongodb://localhost:27017/")
db = client["local"]  # Replace with your actual database name
collection = db["students"]  # Replace with your actual collection name

# Load the JSON data from the file
json_filename = "students.json"  # Replace with the actual filename
with open(json_filename, "r", encoding="utf-8") as json_file:
    data = json.load(json_file)

# Insert the data into the MongoDB collection
collection.insert_many(data)

# Close the MongoDB connection
client.close()

print("Data has been inserted into the MongoDB collection.")


