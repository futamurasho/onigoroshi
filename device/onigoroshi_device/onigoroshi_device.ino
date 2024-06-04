/*
    Video: https://www.youtube.com/watch?v=oCMOYS71NIU
    Based on Neil Kolban example for IDF: https://github.com/nkolban/esp32-snippets/blob/master/cpp_utils/tests/BLE%20Tests/SampleNotify.cpp
    Ported to Arduino ESP32 by Evandro Copercini

   Create a BLE server that, once we receive a connection, will send periodic notifications.
   The service advertises itself as: 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
   Has a characteristic of: 6E400002-B5A3-F393-E0A9-E50E24DCCA9E - used for receiving data with "WRITE"
   Has a characteristic of: 6E400003-B5A3-F393-E0A9-E50E24DCCA9E - used to send data with  "NOTIFY"

   The design of creating the BLE server is:
   1. Create a BLE Server
   2. Create a BLE Service
   3. Create a BLE Characteristic on the Service
   4. Create a BLE Descriptor on the characteristic
   5. Start the service.
   6. Start advertising.

   In this example rxValue is the data received (only accessible inside that function).
   And txValue is the data to be sent, in this example just a byte incremented every second.
*/
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <M5StickC.h>
#include <HX711.h>
#include <Adafruit_NeoPixel.h>

// *************************** parameters ********************************
String deviceName = "ONIGOROSHI";
const bool sendMode = 0; // 0:send query   1:Notify
const int notifyInterval = 1000;  // sending interval (Notify)
const int measurementInterval = 50;
const int resolution = 10;  //set the resolution to 10 bits (0-1023)
const int LOADCELL_DOUT_PIN = 33;
const int LOADCELL_SCK_PIN = 32;
const int switchPin = 36;  //read only Pin
const int ledPin = 26;
const int numPixels = 9;
const int brightness = 50;



// JSON format : {"sensor" : (pressureValue) , "switch" : (pressCount) }
// ***********************************************************************

int switchState = 0;
int lastSwitchState = 0;
int pressCount = 0;
int pressureValue = 0;

HX711 scale;
Adafruit_NeoPixel pixels(numPixels, ledPin, NEO_GRB + NEO_KHZ800);

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
        for(int i=0; i<numPixels; i++) {
          pixels.setPixelColor(i, pixels.Color(100, 255, 100));
          pixels.show();
          delay(1);
        }
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
  pinMode(LOADCELL_DOUT_PIN, INPUT);
  pinMode(LOADCELL_SCK_PIN, OUTPUT);
  pinMode(switchPin, INPUT);
  pinMode(ledPin, OUTPUT);

  // initialize the scale device
  Serial.begin(115200);
  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);
  M5.begin();

  // initialize the LED device
  pixels.begin();
  pixels.setBrightness(brightness);

  //set the resolution to 8 bits (0-255)
  analogReadResolution(resolution);

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
  Serial.println("Waiting a client connection to notify...");
}

void loop() {

  if (deviceConnected) {
    //read the value
    if (scale.is_ready()) {
      pressureValue = scale.read();
    } else {
      Serial.println("HX711 not found.");
    }

    // Read the switch state
    switchState = digitalRead(switchPin);
    if (switchState == LOW && lastSwitchState == HIGH) {
      pressCount++;
        // pixels.setPixelColor(1, pixels.Color(100, 255, 100));
        // pixels.show();
        // delay(1000);
        // pixels.clear();
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