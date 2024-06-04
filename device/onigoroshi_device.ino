#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// *************************** parameters ********************************
String deviceName = "ONIGOROSHI";
bool sendMode = 0; // 0:send query   1:Notify
int notifyInterval = 1000;  // sending interval (Notify)
int measurementInterval = 50;
int resolution = 10;  //set the resolution to 10 bits (0-1023)
int sensorPin = 26;
int switchPin = 36;  //read only Pin
int ledPin1 = 32;
int ledPin2 = 33;

// JSON format : {"sensor" : (pressureValue) , "switch" : (pressCount) }
// ***********************************************************************

int switchState = 0;
int lastSwitchState = 0;
unsigned long pressCount = 0;

BLEServer *pServer = NULL;
BLECharacteristic *pTxCharacteristic;
bool deviceConnected = false;
bool oldDeviceConnected = false;

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID           (generateRandomUUID() + "0").c_str()  // UART service UUID
#define CHARACTERISTIC_UUID_RX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_TX "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *pServer) {
    deviceConnected = true;
    Serial.println("connected");
  };

  void onDisconnect(BLEServer *pServer) {
    deviceConnected = false;
    Serial.println("disconnected");
  }
};

class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    std::string rxValue = pCharacteristic->getValue();
    String rxValueStr = rxValue.c_str();

    if (rxValueStr.length() > 0) {
      Serial.println("*********");
      Serial.print("Received Value: ");
      for (int i = 0; i < rxValueStr.length(); i++) {
        Serial.printf("%02X ", (unsigned int)rxValueStr[i]);
      }
      Serial.println();
      Serial.println("*********");
      if (rxValueStr[0] == 1){
        Serial.println("light");
        analogWrite(ledPin1, 255);
        analogWrite(ledPin2, 255);
        delay(1000);
        analogWrite(ledPin1, 0);
        analogWrite(ledPin2, 0);
      }
    }
  }
};

String generateRandomUUID() {
  char uuid[37];
  const char *hexChars = "0123456789abcdef";

  int sections[5] = {8, 4, 4, 4, 11};

  int pos = 0;
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < sections[i]; j++) {
      uuid[pos++] = hexChars[random(0, 16)];
    }
    if (i < 4) {
      uuid[pos++] = '-';
    }
  }
  uuid[pos] = '\0';
  return String(uuid);
}

void setup() {

  Serial.begin(115200);

  //set the resolution to 8 bits (0-255)
  analogReadResolution(resolution);

  pinMode(sensorPin, INPUT);
  pinMode(switchPin, INPUT);
  pinMode(ledPin1, OUTPUT);
  pinMode(ledPin2, OUTPUT);

  // Create the BLE Device
  BLEDevice::init(deviceName.c_str());

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE Characteristic
  pTxCharacteristic = pService->createCharacteristic(CHARACTERISTIC_UUID_TX, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY);

  pTxCharacteristic->addDescriptor(new BLE2902());

  BLECharacteristic *pRxCharacteristic = pService->createCharacteristic(CHARACTERISTIC_UUID_RX, BLECharacteristic::PROPERTY_WRITE);

  pRxCharacteristic->setCallbacks(new MyCallbacks());

  // Start the service
  pService->start();

  // Start advertising
  pServer->getAdvertising()->start();
  Serial.println("Waiting for a client connection to notify...");
}

void loop() {

  if (deviceConnected) {
    //read the value
    int pressureValue = analogRead(sensorPin);

    // Read the switch state
    switchState = digitalRead(switchPin);
    if (switchState == LOW && lastSwitchState == HIGH) {
      pressCount++;
      analogWrite(ledPin1, 255);
      analogWrite(ledPin2, 255);
      delay(1000);
      analogWrite(ledPin1, LOW);
      analogWrite(ledPin2, LOW);
    }
    lastSwitchState = switchState;

    // Prepare the JSON formatted string
    String jsonString = String("{\"sensor\":") + pressureValue + ",\"switch\":" + pressCount + "}";
    Serial.println(jsonString);

    // Send the JSON string
    pTxCharacteristic->setValue(jsonString.c_str());

    if (sendMode) {
      // Check the measurement interval
      static unsigned long lastMeasurementTime = 0;
      unsigned long currentTime = millis();
      if (currentTime - lastMeasurementTime >= notifyInterval) {
        lastMeasurementTime = currentTime;
        pTxCharacteristic->notify();
        Serial.println("notified");
      }
    }
    delay(measurementInterval);  // bluetooth stack will go into congestion, if too many packets are sent
  }

  // disconnecting
  if (!deviceConnected && oldDeviceConnected) {
    delay(500);                   // give the bluetooth stack the chance to get things ready
    pServer->startAdvertising();  // restart advertising
    Serial.println("start advertising");
    oldDeviceConnected = deviceConnected;
  }
  // connecting
  if (deviceConnected && !oldDeviceConnected) {
    // do stuff here on connecting
    oldDeviceConnected = deviceConnected;
  }
}
