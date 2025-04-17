import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    short_code = event['pathParameters']['short_code']
    response = table.get_item(Key={"short_code": short_code})
    
    if 'Item' not in response:
        return {"statusCode": 404, "body": "Not found"}
    
    item = response['Item']
    long_url = item['long_url']
    
    # Update click count
    table.update_item(
        Key={"short_code": short_code},
        UpdateExpression="SET click_count = click_count + :inc",
        ExpressionAttributeValues={":inc": 1}
    )
    
    return {
        "statusCode": 302,
        "headers": {"Location": long_url}
    }
