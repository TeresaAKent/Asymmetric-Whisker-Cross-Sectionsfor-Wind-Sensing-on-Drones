# Asymmetric-Whisker-Cross-Sections-for-Wind-Sensing-on-Drones
This code works is a companion to the research paper, Asymmetric Whisker-Inspired Sensing Arrays
for Enhanced Airflow Sensing on Drones.

## Data Collection
### Arduino Code
Four stepper motors and four sensors are connected to an Arduino Uno, which is running [this code](https://github.com/TeresaAKent/Asymmetric-Whisker-Cross-Sectionsfor-Wind-Sensing-on-Drones/blob/main/Data%20Collection%20Code/SendToPythonFourMotorsMotor/SendToPythonFourMotorsMotor.ino). Initially, a zeroing phase occurs where the signal for leveling is collected. After the Arduino code waits for a button to be pushed (connected to the LED for visual confirmation). The researcher will turn on the fan at this time and will wait a minimum of 20 s for the fan to reach full speed. After the button is pressed, the Arduino turns the stepper motors in 3.2-degree increments. After waiting 10 seconds, the Arduino prints 150 data points collected from each sensor to the serial. The data transmitted takes the form: Motor Angle, Sensor Number, Bx, By, and Bz signals.

### Python Code
[The Python code](https://github.com/TeresaAKent/Asymmetric-Whisker-Cross-Sectionsfor-Wind-Sensing-on-Drones/blob/main/Data%20Collection%20Code/PythonReadingArduinoShapeSensorRotatingStage.py) reads from the serial, collecting data for the duration of the test (until the incoming motor angle is 360 degrees). After the experiments are done, Python closes the serial and performs some preliminary data filtering, such as removing the original signal leveling. A plot is also output, although this is more for the researcher to verify signals have been collected well than for any data analysis.

## Data Analysis

### Post Processing
#### Initial Analysis
Post-processing is all done in a single MATLAB code. For the paired sensor performance, the post processing was done with the [AnalyzingEachSensor.m code](https://github.com/TeresaAKent/Asymmetric-Whisker-Cross-Sectionsfor-Wind-Sensing-on-Drones/blob/main/Data%20Analysis/AnalyzingEachSensor.m).
1. **Data shift:** The motors are manually set to the zero position by the researcher. The MATLAB code performs a shift check, which shifts the data collected by an angle theta* to minimize the error between the atan(By/Bx) curve and the theta vs. theta curve. 
2. **Summarize the Data:** The vast majority of data analysis is conducted using summary data. For summary data, the Bx and By signals are averaged over the 150 data points. In the post-processing, these data are summarized.
3. **Develop a Model for each Sensor:** Each sensor has a descriptive model curve. The model curve is made from the summary Bx and By signals. The summary
4. **Calculate Single Sensor Accuracy:** the accuracy of the Theta Method, Asymmetric Method, and symmetry for Tables 1, 2, and S1.
5. **Generate Figures:** Figures 2, 3, 5 a-c, S1 and S2 for each sensor are generated here. Diagrammatic figure 4b was also generated here, although it has been commented out.

*The results of this post-processing are in the [SavedDataSummary](https://github.com/TeresaAKent/Asymmetric-Whisker-Cross-Sectionsfor-Wind-Sensing-on-Drones/tree/main/SavedData/SavedDataSummary) folder.* 

#### Post Processing for Temporal Analysis
The idea for the temporal analysis was completed after all the analysis was performed on the summary data. To preserve a record of the analysis, a new code was created that shares many of the same elements. The temporal analysis is performed in the [AnalyzingEachSensorRollEachTrial.m file](https://github.com/TeresaAKent/Asymmetric-Whisker-Cross-Sectionsfor-Wind-Sensing-on-Drones/blob/main/Data%20Analysis/AnalyzingEachSensorRollEachTrial.m)
Many of the same steps are performed; however, it also outputs MATLAB data tables where all of the temporal data is preserved for the temporal analysis done below.

*The results of this post-processing can be found in the [Saved Data Temporal](https://github.com/TeresaAKent/Asymmetric-Whisker-Cross-Sectionsfor-Wind-Sensing-on-Drones/tree/main/SavedData/SavedDataTemporal) folder.* 

### Analyzing Paired Sensors Performance
The code [MultiCurveConsideration.m](https://github.com/TeresaAKent/Asymmetric-Whisker-Cross-Sectionsfor-Wind-Sensing-on-Drones/blob/main/Data%20Analysis/MultiCurveConsideration.m) accomplishes the following tasks:
1. **Solves for the flow heading using Algorithm 1**
2. **Solves for flow heading using Algorithm 2**
3. **Finds the Optimal Offset**
4. **Estimates the velocity from the theta predictions made in steps 1 and 2**
5. **Generate Figures:** Figure 4c, Figure 5 d-f, Figure 6 a-d 

## Temporal Analysis
[TemporalAnalysis.m](https://github.com/TeresaAKent/Asymmetric-Whisker-Cross-Sectionsfor-Wind-Sensing-on-Drones/blob/main/Data%20Analysis/TemporalAnalysis.m) performs the same analysis as the MultiCurveConsideration.m code but uses different input data. For the prior code, the input was the average of the Bx and By signals over all 150 data points. For this code, the input algorithm uses 150 data points, which have been averaged over a filter window ranging from 1 to 150. When the filter window is 150, the data will match the prior analysis. The code then plots Figure 6e, illustrating how the size of the filter window affects the algorithm's ability to identify the flow heading accurately.


## On Drone Testing
Two tests were completed using the asymmetric array on the drone, with each needing an Arduino script.
[Flow_BT_SD_Logging_FasterTJTerriLoopingAcellMadeMulti.ino](https://github.com/TeresaAKent/Asymmetric-Whisker-Cross-Sectionsfor-Wind-Sensing-on-Drones/blob/main/Data%20Collection%20Code/Flow_BT_SD_Logging_FasterTJTerriLoopingAcellMadeMulti/Flow_BT_SD_Logging_FasterTJTerriLoopingAcellMadeMulti.ino) collects Bx, By signals from the sensors and saves the data to the SD card. This code was used to collect the data for Figure 7b which was generated using [MatlabCode](https://github.com/TeresaAKent/Asymmetric-Whisker-Cross-Sectionsfor-Wind-Sensing-on-Drones/blob/main/Data%20Analysis/TwoFlowsDrone.m)

[Flow_BT_SD_Logging_FasterTJTerriLoopingAcelMadeMultiLED.ino](https://github.com/TeresaAKent/Asymmetric-Whisker-Cross-Sectionsfor-Wind-Sensing-on-Drones/blob/main/Drone%20Demonstration/Flow_BT_SD_Logging_FasterTJTerriLoopingAcelMadeMultiLED/Flow_BT_SD_Logging_FasterTJTerriLoopingAcelMadeMultiLED.ino) converts the Bx and By signals into theta values to perform analysis for the identification of multiple flows. No data is saved during these trials to decrease the latency between the second flow arrival and the LED turning on. This code was responsible for figures 7 c d and e.
