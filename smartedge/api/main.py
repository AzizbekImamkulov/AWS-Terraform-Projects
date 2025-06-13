from fastapi import FastAPI
import boto3
import os

app = FastAPI()
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ.get("TABLE_NAME", "smartedge-dev-device-data"))

@app.get("/data")
def get_data():
    response = table.scan()
    return response.get("Items", [])

@app.get("/")
def root():
    return {"status": "API is running"}
