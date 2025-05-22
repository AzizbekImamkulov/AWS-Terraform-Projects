import json
import boto3
import os
import hashlib
import time

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        long_url = body['long_url']

        # Генерация короткого кода на основе времени и URL
        hash_input = long_url + str(time.time())
        short_code = hashlib.sha256(hash_input.encode()).hexdigest()[:6]

        # Сохраняем в DynamoDB
        table.put_item(
            Item={
                'short_code': short_code,
                'long_url': long_url
            }
        )

        # Генерация полного короткого URL
        api_gateway_url = event['requestContext']['domainName'] + "/" + event['requestContext']['stage']
        short_url = f"https://{api_gateway_url}/{short_code}"

        return {
            'statusCode': 200,
            'body': json.dumps({'short_url': short_url}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }

    except Exception as e:
        print("Error:", str(e))
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'}),
            'headers': {
                'Access-Control-Allow-Origin': '*'
            }
        }
