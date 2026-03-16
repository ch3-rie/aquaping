int greenLED = 2;
int yellowLED = 3;
int redLED = 4;
int buzzer = 5;
int sensorPin = A0;

int waterLevelRaw = 0;
int waterLevelPercent = 0;

void setup() {
  pinMode(greenLED, OUTPUT);
  pinMode(yellowLED, OUTPUT);
  pinMode(redLED, OUTPUT);
  pinMode(buzzer, OUTPUT);

  Serial.begin(9600);
}

void loop() {
  // Read sensor
  waterLevelRaw = analogRead(sensorPin);

  // Print raw for debugging
  Serial.print("RAW: ");
  Serial.println(waterLevelRaw);

  // Universal working range
  int minVal = 80;  // empty
  int maxVal = 400;  // full (even half submerged)

  waterLevelPercent = map(waterLevelRaw, minVal, maxVal, 0, 100);
  waterLevelPercent = constrain(waterLevelPercent, 0, 100);

  // Severity
  String severity = "none";
  if (waterLevelPercent == 0) severity = "none";
  else if (waterLevelPercent <= 10) severity = "green";
  else if (waterLevelPercent <= 15) severity = "yellow";
  else if (waterLevelPercent <= 20) severity = "orange";
  else severity = "red";

  // JSON
  Serial.print("{\"device_id\":\"device-001\",");
  Serial.print("\"water_level\":");
  Serial.print(waterLevelPercent);
  Serial.print(",");
  Serial.print("\"severity\":\"");
  Serial.print(severity);
  Serial.println("\"}");

  // LED Control
  digitalWrite(greenLED, severity == "green");
  digitalWrite(redLED, severity == "red");

  if (severity == "yellow") {
    analogWrite(yellowLED, 255);
  } else if (severity == "orange") {
    int brightness = map(waterLevelPercent, 60, 85, 120, 255);
    analogWrite(yellowLED, brightness);
  } else {
    analogWrite(yellowLED, 0);
  }

  // Buzzer
  if (severity == "red") tone(buzzer, 1000);
  else noTone(buzzer);

  delay(5000);
}
