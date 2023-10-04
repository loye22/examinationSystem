from pymongo import MongoClient

# Create a MongoClient and connect to your MongoDB server
mongo_client = MongoClient('mongodb://localhost:27017')

# Choose the database and collection where your student data is stored
db = mongo_client['local']
students_collection = db['students']

# Define the criteria to match students with the "Groups" field equal to "Group-01"
criteria = {"Groups": ["GROUP-01"]}


# Delete students that match the criteria
result = students_collection.delete_many(criteria)

# Check the result to see how many documents were deleted
deleted_count = result.deleted_count
print(f"Deleted {deleted_count} student(s) with Groups: 'Group-01'")
