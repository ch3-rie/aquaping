# AquaPing

AquaPing is a flood detection and monitoring system. A water sensor on an Arduino measures the level, warns people at the site with LEDs and a buzzer, and sends the same reading to a Flutter app.

## How a reading moves

```text
Water sensor (A0)
    → Arduino (percent + severity, LEDs and buzzer)
    → USB serial, 9600 baud, one JSON line every 5 seconds
    → serial_to_backend.py
    → POST /api/readings/add
    → Node.js API (recalculates severity, stores the row)
    → MySQL
    → Socket.IO, when the severity band changes
    → Flutter app (dashboard, local notification, in-app banner)
```

The Arduino does not call the API. `aquaping-backend/serial_to_backend.py` reads the serial port and forwards the reading. `arduino-server/server.js` only prints serial JSON.

## Repository

| Folder | Role |
| --- | --- |
| `arduino-server/` | Firmware in `ArduinoIPTUPDATE/ArduinoIPTUPDATE.ino`, plus a Node serial logger |
| `aquaping-backend/` | Express API, Socket.IO, MySQL access, and the Python serial bridge |
| `aquaping_app/` | Flutter client (login, dashboard, flood map, alerts) |
| `aquaping-mockup/` | Presentation mockup. Open `index.html` in a browser |

## Hardware

Device id is hardcoded as `device-001`. The sketch samples every 5 seconds at 9600 baud.

| Pin | Component |
| --- | --- |
| A0 | Analog water sensor |
| 2 | Green LED |
| 3 | Yellow LED (PWM) |
| 4 | Red LED |
| 5 | Buzzer (1000 Hz while severity is red) |

Raw analog values are mapped from 80 (empty) to 400 (full) onto 0–100%. Each sample is one line:

```json
{"device_id":"device-001","water_level":18,"severity":"orange"}
```

## Severity

The live rules are in `aquaping-backend/routes/readings.js`. Alerts are sent only when the band changes.

| Water level | Code | App label | At the device |
| --- | --- | --- | --- |
| 0–4% | `none` | No water | LEDs and buzzer off |
| 5–10% | `green` | Low | Green LED |
| 11–15% | `yellow` | Medium | Yellow LED |
| 16–20% | `orange` | High | Yellow LED, brighter as the level rises |
| Above 20% | `red` | Overflow | Red LED and buzzer |

## Requirements

- Node.js for the API
- MySQL
- Python with `pyserial` and `requests` for the serial bridge
- Flutter SDK ^3.9.2 for the app
- Arduino IDE to flash the sketch
- A Firebase project if you enable push notifications

## Run the API

```bash
cd aquaping-backend
cp .env.example .env
npm install
npm start
```

Create the database from `aquaping-backend/sql/schema.sql`, then set `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASS`, and `DB_NAME` in `.env`. Also set `JWT_SECRET`. The API listens on `0.0.0.0` and `PORT` (default 3000).

The map routes expect two tables that `schema.sql` does not create: `flood_zones` (`name`, `severity`, `polygon_geojson`) and `evacuation_centers` (`name`, `latitude`, `longitude`, `address`).

`readings.severity` is declared as `yellow`, `orange`, or `red`. The API also writes `none` and `green`, so widen that column before those inserts will succeed.

## Run the serial bridge

Set `SERIAL_PORT` in `aquaping-backend/serial_to_backend.py` (default `COM8`), then:

```bash
pip install pyserial requests
python serial_to_backend.py
```

The script posts to `http://localhost:3000/api/readings/add`.

## Run the app

```bash
cd aquaping_app
flutter pub get
flutter run
```

The address the app actually uses is `API_BASE_URL` inside `lib/services/api_service.dart`, and the socket URL is in `lib/services/socket_service.dart`. `lib/config.dart` still points at `http://192.168.1.7:3000` and is not what those services call.

Sign-in stores a JWT in SharedPreferences under `api_token`. Passwords are hashed with bcrypt. Tokens expire according to `JWT_EXPIRES_IN` (default 7 days).

## API

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/api/auth/register` | Create an account and return a JWT |
| POST | `/api/auth/login` | Sign in |
| POST | `/api/devices/register` | Register `device_id`, `name`, and `region` |
| GET | `/api/devices` | List devices |
| POST | `/api/readings/add` | Store `{ device_id, water_level }` and emit on a severity change |
| GET | `/api/readings/recent/:deviceId` | Last 24 hours, only rows where severity changed |
| GET | `/api/map/zones` | Flood polygons |
| GET | `/api/map/evac_centers` | Evacuation centers |
| GET | `/api/notifications` | Stored alerts |

Socket.IO events from the server are `severity_change` and `dashboard_update`. A client can emit `subscribe:device` with a device id.

Firebase Cloud Messaging and Twilio helpers live under `aquaping-backend/services/`. The reading route does not call them. It stores a notification and emits the socket events. The phone shows its own local notification when that event arrives.

## Presentation mockup

`aquaping-mockup/index.html` is a visual walkthrough of the hardware, the data path, and the phone screens. The controls at the top drive the sensor, the serial example, and the phone together. Keys 1–5 select Normal through Overflow.

## App screens

Entry, login, register, dashboard for `device-001`, flood map, history, profile, and notifications. The dashboard polls recent readings every 5 seconds in addition to the socket.
