

import json
import pandas as pd
import numpy as np



def upload_excel():

    file = r"C:\Users\Louie\Desktop\New folder (6)\Book2.xlsx"
    if file:
            # Read the uploaded Excel file into a DataFrame
            df = pd.read_excel(file)
            df = df.fillna("")
            # Iterate through the DataFrame and insert student data into MongoDB
            inserted_students = []
            for index, row in df.iterrows():
                student_data = {
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
                inserted_students.append(student_data)
               
         
            #data = df.to_dict(orient="records")
            with open(r'C:\Users\Louie\Desktop\New folder (6)\inserted_students.json', 'w') as json_file:
                json.dump(inserted_students, json_file, indent=4, default=lambda x: str(x))
        
    else:
        print('NONO')

upload_excel()