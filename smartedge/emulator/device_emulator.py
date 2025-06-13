import time
import json
import random
import paho.mqtt.client as mqtt

MQTT_HOST = "your IoT endpoint"
MQTT_PORT = 8883
THING_NAME = "smartedge-dev-device"
TOPIC = f"{THING_NAME}/data"

CA_PATH = "../certs/AmazonRootCA1.pem"
CERT_PATH = "../certs/device-certificate.pem.crt"
KEY_PATH = "../certs/private.pem.key"

def on_connect(client, userdata, flags, rc):
    print(f"Connected with result code {rc}")

client = mqtt.Client()
client.on_connect = on_connect
client.tls_set(ca_certs=CA_PATH, certfile=CERT_PATH, keyfile=KEY_PATH)
client.connect(MQTT_HOST, MQTT_PORT, 60)

client.loop_start()

try:
    while True:
        payload = {
            "device_id": THING_NAME,
            "value": round(random.uniform(20.0, 40.0), 2)
        }
        client.publish(TOPIC, json.dumps(payload))
        print("Published:", payload)
        time.sleep(10)
except KeyboardInterrupt:
    client.loop_stop()
    client.disconnect()
