#include <Arduino.h>
#if defined(ESP32)
  #include <WiFi.h>
#elif defined(ESP8266)
  #include <ESP8266WiFi.h>
#endif
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"
#include <Wire.h>
#include <SPI.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BMP280.h>

#define WIFI_SSID "____"
#define WIFI_PASSWORD "_____"
// Insert Firebase project API Key
#define API_KEY "_______"
// Insert RTDB URLefine the RTDB URL */
#define DATABASE_URL "_______" 

#define NUMCHILDPATH 2
String controlParentPath = "/b-iot/control";
String monitoringParentPath = "/b-iot/monitoring";
String childPathController[NUMCHILDPATH] = {"/dirtValve", "/gasValve"};
int childDataController[NUMCHILDPATH]; //data[0]-> valveDung || data[1]->valveGas || data[2]->\0
String childPathMonitoring[NUMCHILDPATH] = {"/dirtHeight", "/cowGas"};
int childDataMonitoring[NUMCHILDPATH]; //data[0] -> dirtHeight || data[1]->cowGas || data[2]->\0
//Firebase
FirebaseData fbdo;
FirebaseJsonData result;
FirebaseAuth auth;
FirebaseConfig config;
bool signupOK = false;
unsigned long sendDataPrevMillis = 0;

//BMP280
#define BMP_SCK 13
#define BMP_MISO 12
#define BMP_MOSI 11
#define BMP_CS 10
Adafruit_BMP280 bme; 

//MQ-4
const int AO_Pin = 32; 
const int LED_Pin = 2; 

//Ultrasonik
#define CM_TO_INCH 0.393701
const int trigPin = 12;
const int echoPin = 14;

//Variable
int gasValue;
float pressureBmp;
int threshold; 
float duration;
float distanceCm;
int uploadStatus = 0;

void setup() {
    Serial.begin(115200);
    pinMode(trigPin, OUTPUT);
    pinMode(echoPin, INPUT);
    pinMode(LED_Pin, OUTPUT);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    Serial.print("Connecting to Wi-Fi");
    while (WiFi.status() != WL_CONNECTED){
        Serial.print(".");
        delay(300);
    }
    Serial.println();
    Serial.print("Connected with IP: ");
    Serial.println(WiFi.localIP());
    Serial.println();

    config.api_key = API_KEY;
    config.database_url = DATABASE_URL;
    if (Firebase.signUp(&config, &auth, "", "")){
        Serial.println("ok");
        signupOK = true;
    }
    else{
        Serial.printf("%s\n", config.signer.signupError.message.c_str());
    }
    config.token_status_callback = tokenStatusCallback;
    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);
    if (!bme.begin(0x76)) {
        Serial.println("Could not find a valid BMP280 sensor, check wiring!");
        while (1);
    }
    Serial.println("Warming up the MQ4 sensor");
    delay(20000);  // wait for the MQ2 to warm up
}

void loop() {
    gasValue = analogRead(AO_Pin);
    pressureBmp = bme.readPressure() - 93660; 
    pressureBmp = pressureBmp / 7800 * 100;
    FirebaseJson dataUpload;
    if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 500 || sendDataPrevMillis == 0)){
        sendDataPrevMillis = millis();
        if (Firebase.RTDB.getJSON(&fbdo, controlParentPath)) {
            if (fbdo.dataTypeEnum() == firebase_rtdb_data_type_json) {
                FirebaseJson *json = fbdo.to<FirebaseJson *>();
                Serial.println(json->raw());
                for(int i = 0; i < NUMCHILDPATH; i++){
                    json->get(result, childPathController[i]);
                    if (result.success){
                        childDataController[i] = result.to<int>();
                    }  
                }
            }
        } else {
            Serial.println(fbdo.errorReason());
        }

        if (Firebase.RTDB.getJSON(&fbdo, monitoringParentPath)) {
            if (fbdo.dataTypeEnum() == firebase_rtdb_data_type_json) {
                FirebaseJson *json = fbdo.to<FirebaseJson *>();
                Serial.println(json->raw());
                for(int i = 0; i < NUMCHILDPATH; i++){
                    json->get(result, childPathMonitoring[i]);
                    if (result.success){
                        childDataMonitoring[i] = result.to<int>();
                    }  
                }  
            }
        } else {
            Serial.println(fbdo.errorReason());
        }
    }
    //================= Valve Dung ================
    if (childDataController[0] == 1){
        Serial.println("PassValveDung is open");
    }
    else 
    {
        Serial.println("PassValveDung is Close");
    }
    //============================================

    //================= Valve Gas ================
    if (childDataController[1] == 1)
    {
        Serial.println("PassValveGas is Open");
    }
    else
    {
        Serial.println("PassValveGas is Close");
    }
    //============================================

    //================= Sensor ====================
    Serial.print("Pressure = ");
    Serial.print(pressureBmp);
    Serial.println(" %Pa");
    Serial.print("Methane Conentration: "); 
    Serial.println(gasValue);
    // Clears the trigPin
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);
    // Sets the trigPin on HIGH state for 10 micro seconds
    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW);
    // Reads the echoPin, returns the sound wave travel time in microseconds
    duration = pulseIn(echoPin, HIGH);
    // Calculate the distance
    distanceCm = duration * 0.034/2;
    // Prints the distance in the Serial Monitor
    Serial.print("Distance (Cm): ");
    Serial.println(distanceCm); // Max 24-27 || Half 28-39 || Min 40-53 
    Serial.println();

    //======================= Dirt Height =================================
    if (childDataMonitoring[0] != 2 && distanceCm < 28) // 2 that means the container is full
    {
        Serial.println("Container is full");
        childDataMonitoring[0] = 2;
        dataUpload.set(childPathMonitoring[0], childDataMonitoring[0]);
        uploadStatus = 1;
    }
    else if (childDataMonitoring[0] != 1 && distanceCm < 40 && distanceCm >= 27) // 1 that means the container is half full
    {
        Serial.println("Container is half full");
        childDataMonitoring[0] = 1;
        dataUpload.set(childPathMonitoring[0], childDataMonitoring[0]);
        uploadStatus = 1;
    }
    else if (childDataMonitoring[0] != 0 && distanceCm >= 40) // 0 that means the cointainer is empty
    {
        Serial.println("Container is empty");
        childDataMonitoring[0] = 0;
        dataUpload.set(childPathMonitoring[0], childDataMonitoring[0]);
        uploadStatus = 1;
    }
    else
    {
        dataUpload.set(childPathMonitoring[0], childDataMonitoring[0]);
    }
    //======================================================================
    
    //======================== Cow Gas =====================================
    if(childDataMonitoring[1] != 2 && pressureBmp > 3000 && gasValue > 70)
    {
        Serial.println("Gas value is High");
        childDataMonitoring[1] = 2;
        dataUpload.set(childPathMonitoring[1], childDataMonitoring[1]);
        uploadStatus = 1;
    }
    else if(childDataMonitoring[1] != 1 && pressureBmp > 2000 && gasValue > 40 && gasValue <= 70)
    {
        Serial.println("Gas value is Medium");
        childDataMonitoring[1] = 1;
        dataUpload.set(childPathMonitoring[1], childDataMonitoring[1]);
        uploadStatus = 1;
    }
    else if(childDataMonitoring[1] != 0 && pressureBmp < 2000 && gasValue <= 40)
    {
        Serial.println("Gas value is LOW");
        childDataMonitoring[1] = 0;
        dataUpload.set(childPathMonitoring[1], childDataMonitoring[1]);
        uploadStatus = 1;
    }
    else
    {
        dataUpload.set(childPathMonitoring[1], childDataMonitoring[1]);
    }
    //======================================================================
    if(uploadStatus == 1)
    {
        Firebase.RTDB.setJSON(&fbdo,monitoringParentPath,&dataUpload);
        uploadStatus == 0;
    }
    delay(500);
}
