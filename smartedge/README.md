# SmartEdge IoT Platform

An end-to-end IoT infrastructure for collecting, processing, and accessing device data using AWS services.

Built with:

- **Terraform**
- **AWS IoT Core**
- **Lambda**
- **DynamoDB**
- **API Gateway**
- **Docker**
- **MQTT (paho-mqtt)**

---

## 🚀 Project Structure

smartedge/
├── Makefile
├── README.md
├── lambda/
│ ├── main.py
│ ├── iot_processor.zip
│ └── requirements.txt
├── emulator/
│ └── device_emulator.py
├── certs/
│ ├── AmazonRootCA1.pem
│ ├── device-certificate.pem.crt
│ └── private.pem.key
├── iot-platform/
│ ├── main.tf
│ └── variables.tf

---

---

## ⚙️ Components

- **Terraform**: Deploys IoT Core, Lambda, DynamoDB, API Gateway
- **Lambda**: Processes and stores IoT data
- **IoT Device Emulator**: Simulates a device publishing MQTT messages
- **FastAPI**: Serves API for retrieving data (via Docker/Gunicorn)
- **DynamoDB**: Stores incoming data
- **API Gateway**: Provides HTTP endpoint (`/data`)

---

## 🔧 Setup & Usage

````bash
make init       # terraform init
make zip        # package Lambda into iot_processor.zip
make apply      # deploy infrastructure
make emulator   # run the IoT device simulator
make call       # curl the HTTP API for data

## ⚙️ Install

### 1. Prepare Lambda ZIP
```bash
cd lambda
pip install -r requirements.txt -t .
zip -r ../lambda/iot_processor.zip .

````
