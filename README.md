# Asymmetric-Whisker-Cross-Sections-for-Wind-Sensing-on-Drones
This work is  project considering how information from asymmetric whisker cross-sections 

## Data Collection
### Arduino Code
Four stepper motors and four sensors are connected to an Arduino Uno. Initially, a zeroing phase occurs where the signal for leveling is collected. After the Arduino code waits for a button to be pushed (connected for LED for visual confirmation). The researcher will turn on the fan in this time and will wait a minium of 20 s for the fan to reach full speed. After the button is pressed the Arduino turns the stepper motors in 3.2 degree increments. After waiting 10 seconds the arduino prints 150 data points collected from each sensor to the serial. The data transmitted takes the form: Motor Angle, Sensor Number, Bx, By and Bz signals .

### Python Code
The python code reads from the serial collecting data for the duration of the test (until the incoming motor angle is 360 degrees). After the experiments are done, python closes the serial and prefroms some preliminary data filtering such as removing the origional signal leveling. A plot is also output although this is more for the researcher to verify signals have been collected well than for any data anaylsis.

## Data Analysis

### Post processing
The initial motor placement is done by the researcher by hand. Embeded in the matlab code is a shift which shifts the data collected by an angle theta* to minimize the error between the atan(By/Bx) curve and the theta vs theata curve. In addition, the vast majority of the data analysis is done with summary data. For summary data the Bx and By signals are averaged over the 150 data points. In the post processing these data are summarized.

The data for Tables 1, 2 and S1 are also generated at that stage.

### Model
Each sensor has a descriptive model curve.

## Solving for Theta Hat from Bx, By signals

### Finding the optimal Offset

### Algorithm 1

### Algorithm 2

### Velocity Prediction

## Temporal Anlysis


## On Drone Testing

