# Asymmetric-Whisker-Cross-Sections-for-Wind-Sensing-on-Drones
This work is  project considering how information from asymmetric whisker cross-sections 

## Data Collection
### Arduino Code
Four stepper motors and four sensors are connected to an Arduino Uno. Initially, a zeroing phase occurs where the signal for leveling is collected. After the Arduino code waits for a button to be pushed (connected for LED for visual confirmation). The researcher will turn on the fan in this time and will wait a minium of 20 s for the fan to reach full speed. After the button is pressed the Arduino turns the stepper motors in 3.2 degree increments. After waiting 10 seconds the arduino prints 150 data points collected from each sensor to the serial. The data transmitted takes the form: Motor Angle, Sensor Number, Bx, By and Bz signals .

### Python Code
The python code reads from the serial collecting data for the duration of the test (until the incoming motor angle is 360 degrees). After the experiments are done, python closes the serial and prefroms some preliminary data filtering such as removing the origional signal leveling. A plot is also output although this is more for the researcher to verify signals have been collected well than for any data anaylsis.

## Data Analysis

### Post Processing
Post processing is all done in one Matlab Code. For the paired sensor preformance the post processing was done with the [AnalyzingEachSensor.m code](https://github.com/TeresaAKent/Asymmetric-Whisker-Cross-Sectionsfor-Wind-Sensing-on-Drones/blob/main/Data%20Analysis/AnalyzingEachSensor.m).
1. **Data shift:** The motors are set to zero posistion is done by hand by the researcher. Matlab code preforms a a shift check, which shifts the data collected by an angle theta* to minimize the error between the atan(By/Bx) curve and the theta vs theata curve. 
2. **Summarize the Data:** The vast majority of the data analysis is done with summary data. For summary data the Bx and By signals are averaged over the 150 data points. In the post processing these data are summarized.
3. **Develop a Model for each Sensor:** Each sensor has a descriptive model curve. The model curve is made from the summary Bx and By signals. The summary
4. **Calculate Single Sensor Accuracy:** the accuracy of the Theta Method, Asymmetric Method and symmetry for Tables 1, 2 and S1.
5. **Generate Figures:** Figures 2 and 3 for each sensor are generated here. Diagrmatic figure 4b was also generated here althought it has been commented out.

The idea to do the temporal analysis was completed after all of the analysis 

### Analyzing Paired Sensors Preformance
The code multi curve consideration accomplishes the following tasks.
1. Solves for the flow heading using Algorithm 1
2. Solves for flow heading using Algorithm 2 
3. Find the Optimal Offset
4. Estimates the velocity from the theta predictions made in step 1 and 2


## Temporal Anlysis


## On Drone Testing

