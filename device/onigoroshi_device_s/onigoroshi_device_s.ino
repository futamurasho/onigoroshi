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
const int sendMode = 1; // 0:send query only   1:Notify when switch pressed   2:Periodic Notify
const int notifyInterval = 1000;  // sending interval (Notify in sendMode 2)
const int measurementInterval = 50;
const int resolution = 10;  //set the resolution to 10 bits (0-1023)
const int LOADCELL_DOUT_PIN = 33;
const int LOADCELL_SCK_PIN = 32;
const int switchPin = 36;  //read only Pin
const int ledPin = 26;
const int numPixels = 9;
const int brightness = 100;
const int loadingInterval = 150;
const int blinkingInterval = 150;

// JSON format : {"sensor" : (pressureValue) , "switch" : (pressCount) }
// ***********************************************************************

// ***************************** colors **********************************
const int colorList[][3] = {
    {255, 0, 0},      // 0:赤
    {0, 0, 255},      // 1:青
    {255, 255, 0},    // 2:黄
    {0, 255, 0},      // 3:緑
    {128, 0, 128},    // 4:紫
    {255, 140, 160},  // 5:ピンク
    {255, 255, 255},  // 6:白
    {255, 145, 0},    // 7:オレンジ
    {0, 255, 255},    // 8:水色
    {173, 255, 47}    // 9:黄緑
};

/* mode
  0:消灯
  1:点灯
  2:点滅
  3:待機*/
// ***********************************************************************

int colorCode = 6;
int red = 255;
int green = 255;
int blue = 255;

int switchState = 0;
int lastSwitchState = 0;
int pressCount = 0;
int pressureValue = 0;

int lightColor = 6;
int lightMode = 0;

int lastLightChangeTime = 0;
int lastLightNum = 0;

HX711 scale;
Adafruit_NeoPixel pixels(numPixels, ledPin, NEO_GRB + NEO_KHZ800);

BLEServer *pServer = NULL;
BLECharacteristic *pTxCharacteristic;
BLECharacteristic *pTRxCharacteristic;
bool deviceConnected = false;
bool oldDeviceConnected = false;

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID           generateRandomUUID() + "0"  // UART service UUID
#define CHARACTERISTIC_UUID_RX "6E400001-B5A3-F393-E0A9-E50E24DCCA9E" //write
#define CHARACTERISTIC_UUID_TX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E" //transfer
#define CHARACTERISTIC_UUID_TRX "6E400003-B5A3-F393-E0A9-E50E24DCCA9E" //read

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
    String rxValue = pCharacteristic->getValue();

    if (rxValue.length() > 0) {
      Serial.println("*********");
      Serial.print("Received Value: ");
      for (int i = 0; i < rxValue.length(); i++) {
        Serial.printf("%02X, ", (unsigned int)rxValue[i]);
      }
      Serial.println();
      Serial.println("*********");
      // change color
      if((unsigned int)rxValue[0] != 0){
        colorCode = (unsigned int)rxValue[0] - '0';
        if(colorCode >= 0 && colorCode <= 9){
          red = colorList[colorCode][0];
          green = colorList[colorCode][1];
          blue = colorList[colorCode][2];
        }
      }
      // change lightmode
      if((unsigned int)rxValue[1] != 0){
        lightMode = (unsigned int)rxValue[1] - '0';
      }
      pixels.clear();
      pixels.show();
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
  BLEDevice::init(deviceName);

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE Characteristic
  pTxCharacteristic = pService->createCharacteristic(CHARACTERISTIC_UUID_TX,BLECharacteristic::PROPERTY_NOTIFY);
  pTRxCharacteristic = pService->createCharacteristic(CHARACTERISTIC_UUID_TRX,BLECharacteristic::PROPERTY_READ);

  pTxCharacteristic->addDescriptor(new BLE2902());
  pTRxCharacteristic->addDescriptor(new BLE2902());

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
      //Serial.println("HX711 not found.");
    }

    // Read the switch state
    switchState = digitalRead(switchPin);
    if (switchState == LOW && lastSwitchState == HIGH) {
      pressCount++;
      // Prepare the JSON formatted string
      String jsonString = String("{\"sensor\":") + pressureValue + ",\"switch\":" + pressCount + "}";
      //Serial.println(jsonString);

      // Send the JSON string
      if(sendMode == 1){
        pTxCharacteristic->setValue(jsonString.c_str());
        pTxCharacteristic->notify();
        Serial.println("notified");
      }
    }
    lastSwitchState = switchState;

    // set LED
    if(lightMode == 0){
      pixels.clear();
      pixels.show();
    }else if(lightMode == 1){
      for(int i=0; i<numPixels; i++) {
        pixels.setPixelColor(i, pixels.Color(red, green, blue));
      }
      pixels.show();
    }else if(lightMode == 2){
      for(int i=lastLightNum; i<numPixels; i += 2) {
        pixels.setPixelColor(i, pixels.Color(red, green, blue));
      }
      for(int i=abs(lastLightNum-1); i<numPixels; i += 2) {
        pixels.setPixelColor(i, pixels.Color(0, 0, 0));
      }
      pixels.show();
      if(lastLightChangeTime % blinkingInterval < measurementInterval){
        lastLightNum = (lastLightNum + 1) % 2;
        lastLightChangeTime = 0;
      }
      lastLightChangeTime += measurementInterval;
    }else if(lightMode == 3){
      if(lastLightChangeTime % loadingInterval < measurementInterval){
        pixels.setPixelColor(lastLightNum, pixels.Color(0, 0, 0));
        lastLightNum = (lastLightNum + 1) % numPixels;
        pixels.setPixelColor(lastLightNum, pixels.Color(red, green, blue));
        pixels.show();
        lastLightChangeTime = 0;
      }
      lastLightChangeTime += measurementInterval;
    }

    // Prepare the JSON formatted string
    String jsonString = String("{\"sensor\":") + pressureValue + ",\"switch\":" + pressCount + "}";
    //Serial.println(jsonString);

    pTRxCharacteristic->setValue(jsonString.c_str());

    if (sendMode == 0) {
      pTxCharacteristic->setValue(jsonString.c_str());
    }
    if (sendMode == 2) {
      // Check the measurement interval
      static unsigned long lastMeasurementTime = 0;
      unsigned long currentTime = millis();
      if (currentTime - lastMeasurementTime >= notifyInterval) {
        lastMeasurementTime = currentTime;
        pTxCharacteristic->setValue(jsonString.c_str());
        pTxCharacteristic->notify();
        Serial.println("notified");
      }
    }
    delay(measurementInterval);  // bluetooth stack will go into congestion, if too many packets are sent
  }
  else{
    if(lastLightChangeTime % loadingInterval < measurementInterval){
      pixels.setPixelColor(lastLightNum, pixels.Color(0, 0, 0));
      lastLightNum = (lastLightNum + 1) % numPixels;
      pixels.setPixelColor(lastLightNum, pixels.Color(255, 255, 255));
      pixels.show();
      lastLightChangeTime = 0;
    }
    lastLightChangeTime += measurementInterval;
    delay(measurementInterval);
  }

  // disconnecting
  if (!deviceConnected && oldDeviceConnected) {
    delay(500);                   // give the bluetooth stack the chance to get things ready
    pServer->startAdvertising();  // restart advertising
    Serial.println("start advertising");
    oldDeviceConnected = deviceConnected;

    pixels.clear();
    pixels.show();
    lightMode = 0;
    colorCode = 6;
    red = 255;
    green = 255;
    blue = 255;
  }
  // connecting
  if (deviceConnected && !oldDeviceConnected) {
    // do stuff here on connecting
    oldDeviceConnected = deviceConnected;
    lightMode = 0;
    colorCode = 6;
    for(int i=0; i<3; i++) {
      for(int j=0; j<numPixels; j++) {
        pixels.setPixelColor(j, pixels.Color(red, green, blue));
      }
      pixels.show();
      delay(300);
      pixels.clear();
      pixels.show();
      delay(300);
    }
  }
}