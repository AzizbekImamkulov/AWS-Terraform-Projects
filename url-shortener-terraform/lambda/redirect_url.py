import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    try:
        short_code = event['pathParameters']['short_code']

        response = table.get_item(Key={"short_code": short_code})
        if 'Item' not in response:
            return {
                "statusCode": 404,
                "body": json.dumps({"error": "Short URL not found"}),
                "headers": {"Content-Type": "application/json"}
            }

        item = response['Item']
        long_url = item['long_url']

        # Атомарное увеличение счётчика с защитой от отсутствия click_count
        table.update_item(
            Key={"short_code": short_code},
            UpdateExpression="SET click_count = if_not_exists(click_count, :start) + :inc",
            ExpressionAttributeValues={
                ":inc": 1,
                ":start": 0
            }
        )

        return {
            "statusCode": 302,
            "headers": {
                "Location": long_url
            }
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
            "headers": {"Content-Type": "application/json"}
        }
