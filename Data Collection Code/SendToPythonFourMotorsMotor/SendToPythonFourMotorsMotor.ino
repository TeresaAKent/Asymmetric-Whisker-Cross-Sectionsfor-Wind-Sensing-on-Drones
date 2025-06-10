#include "Wire.h" 
#include "utility/twi.h"   
#include <Stepper.h>   

// Define the Multiplexers
#define TCAADDR 0x70
//#define TCAADDR2 0x71
// Numberof Pins on first bus
int num_pin = 3 ;
// Numberof Pins on second bus
int num_pin2 = 0;
// If you are having pin issues on the bus
int myPins[] = {0,1,2,3};

const int tle_addr = 0x35; // obtained by i2c scanner. No need to be changed.
const int config_reg = 0x11;
const int lp_mode = 0x13;

// Define terms related to the button press
int buttonpress;
const int buttonPin = 8;
int buttonState = 0; 

// Define pin connections & motor's steps per revolution
const int dirPin1 = 2;
const int stepPin1 = 3;
const int dirPin2 = 4;
const int stepPin2 = 5;
const int dirPin3 = 7;
const int stepPin3 = 6;
const int dirPin4 = 9;
const int stepPin4 = 10;

//Define terms related to the motor

// for your motor
const int stepsPerRevolution = 200;  // change this to fit the number of steps per revolution
const int numberofRotations=105;
double NSteps=stepsPerRevolution/numberofRotations;
double conversion=(double) 360/ (double) stepsPerRevolution;

// Define terms for code math
double Angle;
int o;
int p;
int i;

// Define terms related to reading the Hall effect Sensor
byte bx_high;
byte by_high;
byte bz_high;
byte temp_low;
byte bxy_low;
byte bz_low;

unsigned int bx_value;
unsigned int by_value;
unsigned int bz_value;
//unsigned int temp_value = (temp_high >> 4) | temp_low;

int16_t Bx;
int16_t By;
int16_t Bz;

void ReadMux1(){
  //Wire.beginTransmission(TCAADDR2);
  Wire.write(0);  // no channel selected
  Wire.endTransmission(); 
  for (int q = 0; q < num_pin; ++q){
    i=myPins[q];
    Serial.print(",");
    Serial.print(i);
    Serial.print(",");
    Serial.print(Angle);
    
    tcaselect(i);
    
    
    // Request 7 bytes from the sensor and return, if it didn't send enough re-configure
    while(Wire.requestFrom(tle_addr, 6) < 6){
      //Serial.println("Read failed");
      Wire.begin();   //join I2C bus
      Wire.beginTransmission(tle_addr);
      Wire.write(config_reg);
      Wire.write(lp_mode); 
      Wire.endTransmission();
    }
  
    // Read all registers to variables
    bx_high = Wire.read();
    by_high = Wire.read();
    bz_high = Wire.read();
    temp_low = Wire.read();
    bxy_low = Wire.read();
    bz_low = Wire.read();

    // Split the variables to get B field values
    bx_value = (bx_high << 4) | ((bxy_low & 0xF0)>>4);
    by_value = (by_high << 4) | (bxy_low & 0x0F);
    bz_value = (bz_high << 4) | (bz_low & 0x0F);
    //unsigned int temp_value = (temp_high >> 4) | temp_low;
    
    Bx = (int16_t)(bx_value << 4) / 16 ;
    By = (int16_t)(by_value << 4) / 16 ;
    Bz = (int16_t)(bz_value << 4) / 16 ;
  
    //---- Print Out Sensor Axis Readings ----//
    //if (i == 0) Serial.print("X= ");
    //else Serial.print("\tX= ");
    Serial.print(",");
    Serial.print(Bx); 
    Serial.print(",");    
    //Serial.print("\tY= ");
    Serial.print(By);
    Serial.print(",");
    //Serial.print("\tZ= ");
    if (i == num_pin - 1) Serial.println(Bz);
    else Serial.println(Bz);



    
  }

}






// Function for I2C multiplexer switching
void tcaselect(uint8_t i) {
  if (i > 7) return;
  Wire.beginTransmission(TCAADDR);
  Wire.write(1 << i);
  Wire.endTransmission();  
}
// void tcaselect2(uint8_t i) {
//   if (i > 7) return;
//   Wire.beginTransmission(TCAADDR2);
//   Wire.write(1 << i);
//   Wire.endTransmission();  
// }

 
void setup() {
  Wire.begin();   //join I2C bus
  Wire.setWireTimeout(1000 /* us */, true /* reset_on_timeout */);
  Serial.begin(115200); //start Serial
  Serial. flush();
  while(!Serial); //wait for Serial to be available
  for (int q = 0; q < num_pin; ++q){
    i=myPins[q];
    tcaselect(i);
    Wire.beginTransmission(tle_addr);
    Wire.write(config_reg); //set pointer/access configuration register  
    Wire.write(lp_mode); //
    Wire.endTransmission(); //end configurations
    
  }
  Serial.println(33);
  // Declare pins as Outputs
	pinMode(stepPin1, OUTPUT);
	pinMode(dirPin1, OUTPUT);
  pinMode(stepPin2, OUTPUT);
	pinMode(dirPin2, OUTPUT);
  pinMode(stepPin3, OUTPUT);
	pinMode(dirPin3, OUTPUT);
  pinMode(stepPin4, OUTPUT);
	pinMode(dirPin4, OUTPUT);
  pinMode(buttonPin, INPUT);

  delay(50); //delay to allow time for sensor the update
  Serial.print("Setup Complete\n\n");
}

void loop(){
  //Delay so I can start python code
  
  //Get 100 Data Points this is about Getting a zero value
  Serial.println(123456); // This is for matlab visualization
  //Read Data off the first hub
  unsigned long StartTime = millis();
    for (int p = 0; p < 150; ++p)
  {
    ReadMux1();
  }
  unsigned long CurrentTime = millis();
  unsigned long ElapsedTime = CurrentTime - StartTime;
  //Serial.println ("Hz");
  unsigned long Hz = 50/ElapsedTime*1000;
  //Serial.println(ElapsedTime);


  // Wait for a button to be pushed
  while (digitalRead(buttonPin)==LOW)
  {
    buttonState = digitalRead(buttonPin);
    delay(250);
  }
  

  for (int rot = 0; rot<numberofRotations; rot++)
  {
    delay(5000);
    
    //Serial.print(rot*NSteps);
    //Serial.print(',');
    

    
    Angle=(double)rot*2*conversion;
    

    for (int p = 0; p < 150; ++p){
    ReadMux1();
    }
    
    delay(50);
    digitalWrite(dirPin1, LOW);
    
    
    
    for (int i = 0; i < 2; i++) 
    {
      // These four lines result in 1 step:
      digitalWrite(stepPin1, HIGH);
      delayMicroseconds(500);
      digitalWrite(stepPin1, LOW);
      delayMicroseconds(500);
    }
    digitalWrite(dirPin2, HIGH);
    delay (500);

    for (int i = 0; i < 2; i++) 
    {

      digitalWrite(stepPin2, HIGH);
      delayMicroseconds(500);
      digitalWrite(stepPin2, LOW);
      delayMicroseconds(500);
    }
    digitalWrite(dirPin3, HIGH);
    delay(500);

    for (int i = 0; i < 2; i++)
    { 
      digitalWrite(stepPin3, HIGH);
      delayMicroseconds(500);
      digitalWrite(stepPin3, LOW);
      delayMicroseconds(500);
    }
    digitalWrite(dirPin4, HIGH);
    delay(500);

    for (int i = 0; i < 2; i++)
    { 
      digitalWrite(stepPin4, HIGH);
      delayMicroseconds(500);
      digitalWrite(stepPin4, LOW);
      delayMicroseconds(500);
    }
  }
}
