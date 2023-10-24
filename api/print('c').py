from flask import Flask, jsonify
from pymongo import MongoClient

app = Flask(__name__)



if __name__ == '__main__':
    app.run(debug=True)
