import serial
import requests
import time

SERIAL_PORT = "COM8"
BAUD_RATE = 9600
API_URL = "http://localhost:3000/api/readings/add"
DEVICE_ID = "device-001"

def severity(level):
    if level < 80:
        return "none"
    elif level < 130:
        return "green"
    elif level < 150:
        return "yellow"
    elif level < 180:
        return "orange"
    else:
        return "red"

ser = serial.Serial(SERIAL_PORT, BAUD_RATE)
time.sleep(2)

while True:
    try:
        line = ser.readline().decode().strip()
        if line.isdigit():
            level = int(line)
            sev = severity(level)
            payload = {"device_id": DEVICE_ID, "water_level": level, "severity": sev}
            r = requests.post(API_URL, json=payload)
            print(f"Sent {level} ({sev}) -> {r.status_code}")
    except Exception as e:
        print(e)
    time.sleep(1)
