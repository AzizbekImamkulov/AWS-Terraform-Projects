import logging
import os
import boto3
from datetime import datetime
from boto3.dynamodb.conditions import Key

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get("TABLE_NAME")
table = dynamodb.Table(table_name)

def handler(event, context):
    logger.info("Received event: %s", event)
    try:
        if event.get("requestContext"):
            response = table.scan()
            return {
                "statusCode": 200,
                "headers": {"Content-Type": "application/json"},
                "body": str(response.get("Items", []))
            }

        for record in event.get("records", []):
            device_id = record.get("device_id")
            timestamp = datetime.utcnow().isoformat()
            value = record.get("value")

            if device_id and value is not None:
                table.put_item(Item={
                    "device_id": device_id,
                    "timestamp": timestamp,
                    "value": str(value)
                })
                logger.info("Saved data for device: %s", device_id)
        return {"statusCode": 200}
    except Exception as e:
        logger.error("Error: %s", e)
        return {"statusCode": 500, "body": str(e)}
