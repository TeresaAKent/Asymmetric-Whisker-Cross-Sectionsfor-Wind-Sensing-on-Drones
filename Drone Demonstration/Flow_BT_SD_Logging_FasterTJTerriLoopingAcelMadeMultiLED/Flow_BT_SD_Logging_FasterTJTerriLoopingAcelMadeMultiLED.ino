#include <SD.h>
#include <Wire.h>
#include <ArduinoBLE.h>
#include <SPI.h>
#include <LSM6DS3.h>

// Create an instance of the LSM6DS3 sensor
//LSM6DS3 myIMU;
LSM6DS3 myIMU(I2C_MODE, 0x6A);    //I2C device address 0x6A


// Define a BLE service and characteristic
BLEService ledService("19B10000-E8F2-537E-4F6C-D104768A1214");
BLEByteCharacteristic switchCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite);

// Pin to control a transistor (used as an indicator in this example)
const int transistorPin = LED_BUILTIN;

#define ADDRESS 0x35
#define DELAY 1
#define TCAADDR 0x70
const int config_reg = 0x11;
const int lp_mode = 0x13;

// Base name must be six characters or less for short file names.
#define FILE_BASE_NAME "Data"

// Arrays to store sensor data
//int list1[6] = {0};
int16_t Bx1, By1, Bz1; 
//delta_x1, delta_y1, delta_z1 , X_drone, Y_drone
int Angle;
int FilteredX[10][2], FilteredY[10][2], ThetaX[10][2], ThetaY[10][2];
int Strength[2];
int SmallCheck;
float Guess[2];
int num_pin = 2;
int pointer=0;

int sumX =0;
int16_t BX0[2];
int16_t BY0[2];
int sumY =0;
int sumX2 =0;
int sumY2 =0;
int16_t averageX, averageY;

// // Arrays to store historical data for moving average
// const int maxWindowSize = 100;
// int X_values[maxWindowSize], Y_values[maxWindowSize];
// int X_sum = 0, Y_sum = 0, X_index = 0, Y_index = 0, windowSize = 20;

// Analog pin for reading sensor data
const int analogPin = A0;

// File for logging data to SD card
unsigned long startTime;
unsigned long elapsedTime = 0;
String m;


File file;

const uint8_t BASE_NAME_SIZE = sizeof(FILE_BASE_NAME) - 1;
char fileName[] = FILE_BASE_NAME "00.txt";

void tcaselect(uint8_t i) {
  if (i > 7) return;
  Wire.beginTransmission(TCAADDR);
  Wire.write(1 << i);
  Wire.endTransmission();  
}

void setup() {
  Serial.begin(115200);

  pinMode(transistorPin, OUTPUT);
  pinMode(D3, OUTPUT);
  pinMode(D1, OUTPUT);
  

  // Initialize BLE
  while (!BLE.begin()) {
    //Serial.println("Starting Bluetooth® Low Energy module failed! Retrying...");
    delay(1000);
  }

  BLE.setLocalName("FLOW");
  BLE.setAdvertisedService(ledService);
  ledService.addCharacteristic(switchCharacteristic);
  BLE.addService(ledService);
  switchCharacteristic.writeValue(0);
  BLE.advertise();

  // Initialize I2C and configure sensor
  Wire.begin();
  delay(3);
  Wire.setClock(400000);
  Wire.beginTransmission(0x00);
  Wire.write(0x00);
  Wire.endTransmission();

    for (int i = 0; i < num_pin; ++i){
    tcaselect(i);
    Wire.beginTransmission(ADDRESS);
    Wire.write(config_reg); //set pointer/access configuration register  
    Wire.write(lp_mode); //
    Wire.endTransmission(); //end configurations
    
  }

  Wire.beginTransmission(ADDRESS);
  Wire.write(0x10);
  Wire.write(0b00000000);
  Wire.write(0b00011001);
  Wire.endTransmission();

  Wire.beginTransmission(ADDRESS);
  Wire.write(0b00100000);
  Wire.endTransmission();

  // Initialize LSM6DS3 sensor
  if (myIMU.begin() != 0) {
    //Serial.println("Device error");
  } else {
    //Serial.println("Device OK!");
  }

  // Initialize SD card
  if (!SD.begin(D3)) {
    //Serial.println("SD Initialization failed!");
    return;
  }
  //5_data.txt

  
  // Main loop for BLE and data logging

}


void loop() {
  digitalWrite(D1, HIGH);
    while (true) 
    {
      // Check for a BLE central device
      BLEDevice central = BLE.central();
      // If connected to a central BLE device
      if (central)
      {
        NewFileandOpen();
        //Serial.print("Connected to central: ");
        //Serial.println(central.address());

        // Check if file is open
        if (file) 
        {
          //Serial.println("Writing to data.txt...");
          // While the central device is connected
          while (central.connected()) 
          {
            // Check if the BLE characteristic is written
            if (switchCharacteristic.written()) 
            {
              // If the switch is ON
              digitalWrite(transistorPin, HIGH);
              if (switchCharacteristic.value()) 
              {
                // Collect and log data for x mili seconds
                BX0[0] = 0;
                BY0[0] =0;
                BX0[1] =0;
                BY0[1] = 0;
                for (int prep =0 ;prep < 50; prep++){
                  readMultipleSensors();
                  // Serial.println(prep);
                }
                BX0[0]= ThetaX[5][0];
                BX0[1]= ThetaX[5][1];
                BY0[0]= ThetaY[5][0];
                BY0[1]= ThetaY[5][1];
                // Serial.println(F("Check"));
                // Serial.println(BX0[1]);
                // Serial.println(BY0[1]);
                startTime = millis();
                elapsedTime = 0;
                while (elapsedTime < 180000) 
                {
                  //Serial.println("Logging");
                  //int sensorValue = analogRead(analogPin);
                  elapsedTime = millis() - startTime;
                  //digitalWrite(transistorPin, LOW);
                  //delay(100);
                  readMultipleSensors();
                  //file.print(elapsedTime);
                  //file.println(m);
                  //digitalWrite(transistorPin, HIGH);
                  //delay(100);
                  //myFile.flush();
                  //myFile.close();
                }
                file.close();
                // Turn off the indicator
                digitalWrite(transistorPin, LOW);
                delay(2000);
                BLE.disconnect();
                switchCharacteristic.writeValue(0);
              } 
              else 
              {
                file.close();
              }
            }
          }

        // Close the data file and end the logging
        digitalWrite(transistorPin, LOW);
        
        while (!BLE.begin()) 
        {
          //Serial.println("Starting Bluetooth® Low Energy module failed! Retrying...");
          delay(1000);
        }
        BLE.setLocalName("FLOW");
        BLE.setAdvertisedService(ledService);
        ledService.addCharacteristic(switchCharacteristic);
        BLE.addService(ledService);
        switchCharacteristic.writeValue(0);
        BLE.advertise();
      } 
    }
  }
}
// Function to read sensor data from the flow sensor
void NewFileandOpen() {
    //Serial.println("Initialization done.");
  while (SD.exists(fileName)) {
    if (fileName[BASE_NAME_SIZE + 1] != '9') {
      fileName[BASE_NAME_SIZE + 1]++;
    } else if (fileName[BASE_NAME_SIZE] != '9') {
      fileName[BASE_NAME_SIZE + 1] = '0';
      fileName[BASE_NAME_SIZE]++;
    } else {
      Serial.println(F("Can't create file name"));
      return;
    }
  }
  file = SD.open(fileName, FILE_WRITE);
  if (!file) {
    Serial.println(F("open failed"));
    return;
  }
  Serial.print(F("opened: "));
  Serial.println(fileName);
}
void readMultipleSensors() {
  // m = "";
  for (int i =0; i < num_pin; ++i){
    tcaselect(i);

    uint8_t buf[7];
    Wire.requestFrom(ADDRESS, 7);

    // Read data from the sensor
    for (uint8_t ii = 0; ii < 7; ii++) {
      buf[ii] = Wire.read();
    }

    // Extract X, Y, and Z values from the sensor data
    int16_t X = (int16_t)((buf[0] << 8) | (buf[4] & 0xF0)) >> 4;
    int16_t Y = (int16_t)((buf[1] << 8) | ((buf[4] & 0x0F) << 4)) >> 4;
    int16_t Z = (int16_t)((buf[2] << 8) | ((buf[5] & 0x0F) << 4)) >> 4;

    Bx1 = Y;
    By1 = -X;
    Bz1 = Z;



    // Compute the angle using atan2 and convert to degrees
    //Angle = round(atan2(Y_drone, X_drone) * (180 / PI)) + 180;
  

    // Create a string containing sensor and orientation data
    // m = m + " ," + String(Bx1) + ", " + String(By1) ;
    FilteredX[pointer][i]=Bx1-BX0[i]; 
    FilteredY[pointer][i]=By1-BY0[i]; 
    // Serial.println(i);
    // Serial.println(FilteredX[pointer][i]);
    // Serial.println(FilteredY[pointer][i]);
    sumX =0;
    sumY =0;
    for (int j =0; j<10; j++){
      sumX+=FilteredX[j][i];
      sumY+=FilteredY[j][i];
    }
    ThetaX[pointer][i]= sumX/10;
    ThetaY[pointer][i]=sumY/10;
    sumX2=0;
    sumY2=0;
    for (int k =0; k<10; k++){
      sumX2+=ThetaX[k][i];
      sumY2+=ThetaY[k][i];
    }
    
    Strength[i]= sqrt(sumX2*sumX2+sumY2*sumY2);
    // Strength[i]= sqrt(ThetaX[pointer][i]*ThetaX[pointer][i]+ThetaY[pointer][i]*ThetaY[pointer][i]);
  
    Guess[i] = round(atan2(sumY2, sumX2) * (180 / PI)) + 180;
    // Guess[i] = round(atan2(ThetaY[pointer][i], ThetaX[pointer][i]) * (180 / PI)) + 180;
    
    
    
    // Serial.println("Guess1");
    
    // Serial.print(Guess[0],2);
    // Serial.println("Guess2");
    // Serial.print(Guess[1],2);
    
    
    // Print the data to the serial monitor
    

    // Delay for a short duration to control the data update rate
    delay(DELAY);

    // Request new sensor data from the
    Wire.beginTransmission(ADDRESS);
    Wire.write(0b00100000);
    Wire.endTransmission();
  }
  pointer=(pointer+1)%10;
  // Serial.println("pointer");
  // Serial.println(pointer);
  if (Strength[0]>20.0 && Strength[1]>20.0){
    int Angle= abs(Guess[1]-Guess[0]);
    if (Angle<0){
      Angle=Angle+360;
    }
    
    if (Angle%360<20||Angle%360>100) {
      digitalWrite(D1,HIGH);
      Serial.println("Guess1");
      Serial.println(Guess[0]);
      Serial.println("Guess2");
      Serial.println(Guess[1]);
    }
    else{
      digitalWrite(D1,LOW);
    } 
  }
  else{
    digitalWrite(D1,LOW);
  }
  // m = m + ", " + String(myIMU.readFloatGyroX()) + ", " + String(myIMU.readFloatGyroY())+ ", "  + String(myIMU.readFloatAccelX())+ " ," + String(myIMU.readFloatAccelY()) ;
}
