# -*- coding: utf-8 -*-
"""
Created on Tue Feb  7 13:09:24 2023

@author: tkent
"""

import serial
import csv
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import statistics as stat
import cv2
import pandas as pd
from time import process_time

def PredictThetaAngle(ThetaValues):
    
    PosCount=np.size([a for j,a in enumerate(ThetaValues) if a>=0])
    NegCount=np.size(ThetaValues)-PosCount
    if PosCount>NegCount:
        ThetaValues[(ThetaValues<0)]=ThetaValues[(ThetaValues<0)]+360
    else:
        ThetaValues[(ThetaValues>0)]=ThetaValues[(ThetaValues>0)]-360
    Avg=np.average(ThetaValues)
    stdv=np.std(ThetaValues)
    return Avg, stdv
 
#Max Angle tells when to stop collecting data
MaxAngle=360

CalibrationSize=50
 



#Identifying Information about flow
flowSpeed1=0
flowSpeed2=3
Flow1Angel=225
Flow2Angle=315

#Identifying Information About Test
trial=466
Date=20230920

#Identifying information about whiskers
WhiskerAspect=15.0
NumberOfWhiskers = 9
Spacing=35
Order='BEFGHIJK'
# 1 2 3
# 4 5 6
# 7 8 9

# Close Any Graphs mad before
plt.close('all') 


# Create an output for the Raw Data
fileName="Flow1{}Flow2{}Aspect{}Flow1Angel{}Flow2Angle{}Trial{}Spacing{}Order{}{}.csv".format(flowSpeed1,flowSpeed2,WhiskerAspect,Flow1Angel,Flow2Angle,trial,Spacing,Order,Date)
fileName2="Flow1{}Flow2{}Aspect{}Flow1Angel{}Flow2Angle{}Trial{}Spacing{}Order{}{}Motion.csv".format(flowSpeed1,flowSpeed2,WhiskerAspect,Flow1Angel,Flow2Angle,trial,Spacing,Order,Date)
GraphName1="Flow1{}Flow2{}Aspect{}Flow1Angel{}Flow2Angle{}Trial{}Spacing{}{}Data.png".format(flowSpeed1,flowSpeed2,WhiskerAspect,Flow1Angel,Flow2Angle,trial,Spacing,Date)
GraphName2="Flow1{}Flow2{}Aspect{}Flow1Angel{}Flow2Angle{}Trial{}Spacing{}{}Raw.png".format(flowSpeed1,flowSpeed2,WhiskerAspect,Flow1Angel,Flow2Angle,trial,Spacing,Date)
GraphName3="Flow1{}Flow2{}Aspect{}Flow1Angel{}Flow2Angle{}Trial{}Spacing{}{}Visualize.png".format(flowSpeed1,flowSpeed2,WhiskerAspect,Flow1Angel,Flow2Angle,trial,Spacing,Date)
file = open(fileName, "a")
print("Created file")

# Connect to the arduino 
arduino_port = "COM4" #serial port of Arduino
baud = 9600 #arduino uno runs at 9600 baud
ser = serial.Serial(arduino_port, baud)
print("Connected to Arduino port:" + arduino_port)

# Initilization
sensor_data=[]
line_data=[]
line=0

SecondsForTest=.75
samples=SecondsForTest*baud

readingsTemp2=np.zeros(3*NumberOfWhiskers)
t0 = process_time()
while line <= SecondsForTest*400:
    
    getData=ser.readline()
    dataString = getData.decode('utf-8')
    #print (dataString)
    data=dataString[1:][:-2]

    readingTemp = data.split(",")
    #print('rT',readingTemp)
    try:
        Readingnum=int(readingTemp[0])
        #print('Readingnum',Readingnum)
        
        #save the data to the array if you have just recived the last from the row
        if Readingnum==NumberOfWhiskers-1:
            readingsTemp2[Readingnum*3:Readingnum*3+3]=readingTemp[1:4]
            if line==0:
                sensor_data=readingsTemp2
            else:
                sensor_data=np.vstack((sensor_data,readingsTemp2))
            line = line+1
        else:
            readingsTemp2[Readingnum*3:Readingnum*3+3]=readingTemp[1:4]
    except:
        pass
    print('rT2',readingsTemp2)
    print(line)

# After the test close the serial
ser.close()
t1=process_time()
print('samplerate',np.round((SecondsForTest*400)/(t1-t0),2),'hz')

# Save the Raw Data to Excel
with open(fileName, 'w', encoding='UTF8', newline='') as f:
    writer = csv.writer(f)
    writer.writerows(sensor_data)
print("Data collection complete!")
file.close()



# Convert the data into an array
SensorArrayData=np.zeros((np.shape(sensor_data)[0],3*NumberOfWhiskers))
for ii in range(np.size(sensor_data,0)):
    try:
        hold=np.array(sensor_data[ii])
        SensorArrayData[ii,:]=hold[0:3*NumberOfWhiskers]
    # block raising an exception
    except:
        pass # doing nothing on exception

#Get initial values for the sensor
InitialXYZ=np.zeros((3,NumberOfWhiskers))
for jj in range(NumberOfWhiskers):
    InitialXYZ[0,jj]=stat.median(SensorArrayData[0:30,3*jj])
    InitialXYZ[1,jj]=stat.median(SensorArrayData[0:30,3*jj+1])
    InitialXYZ[2,jj]=stat.median(SensorArrayData[0:30,3*jj+2])

SensorChangeData=SensorArrayData-InitialXYZ.T.flatten()
# Save the MagnitudeChangeData to Excel
# Save the Raw Data to Excel
with open(fileName2, 'w', encoding='UTF8', newline='') as f:
    writer = csv.writer(f)
    writer.writerows(SensorChangeData)
print("Data collection complete!")
file.close()



# Plot the data
# Three plots
# First we need a color for each of the nine
Colors=['darkred','purple','navy','red','darkorchid','blue','coral','fuchsia','cyan']


fig2, axs2 = plt.subplots(3)
fig2.suptitle('BxByBz Comparison')
for j in range(NumberOfWhiskers):
    axs2[0].plot(np.arange(line),-1*SensorChangeData[:,j*3], color=Colors[j],label="B{}".format(j+1))
    axs2[1].plot(np.arange(line),-1*SensorChangeData[:,j*3+1], color=Colors[j],label="B{}".format(j+1))
    axs2[2].plot(np.arange(line),-1*SensorChangeData[:,j*3+2], color=Colors[j],label="B{}".format(j+1))

plt.ylim([-100,100])
axs2[0].set(xlabel='Time (s)')
axs2[1].set(xlabel='Time(s)')
axs2[2].set(xlabel='Time(s)')
axs2[0].set(ylabel='Bx Signal Strength [mT]')
axs2[1].set(ylabel='By Signal Strength [mT]')
axs2[2].set(ylabel='Bz Signal Strength [mT]')
plt.legend()
plt.savefig(GraphName2)
# Make new arrays for Calculated Values
SignalStrength = np.zeros((np.size(SensorArrayData,0),NumberOfWhiskers))
PredictedTheta1 = np.zeros((np.size(SensorArrayData,0),NumberOfWhiskers))
StdvSignal = np.zeros((np.size(SensorArrayData,0),NumberOfWhiskers))
StdvAngle = np.zeros((np.size(SensorArrayData,0),NumberOfWhiskers))


# Plot the angle and signal strength of each line
fig, axs = plt.subplots(2)
fig.suptitle('Sensor Comparison')
for i in range(NumberOfWhiskers):
    fil=5
    xval=np.convolve(SensorChangeData[:,3*i], np.ones(fil)/fil, mode='same')
    yval=np.convolve(SensorChangeData[:,3*i+1], np.ones(fil)/fil, mode='same')
    SignalStrength[:,i]=np.sqrt(np.square(xval)+np.square(yval))
    PredictedTheta1[:,i] = np.arctan2(SensorChangeData[:,3*i],SensorChangeData[:,3*i+1])*180/3.141592
    axs[0].scatter(np.arange(line),SignalStrength[:,i], color=Colors[i],label="B{}".format(i+1))
    axs[1].scatter(np.arange(line),PredictedTheta1[:,i],color=Colors[i],label="Theta{}".format(i+1))

axs[1].plot(np.arange(line),np.ones(line)*-160,color='black') 
axs[0].set(xlabel='Time (s)')
axs[1].set(xlabel='Time(s)')
axs[0].set(ylabel='Signal Strength [mT]')
axs[1].set(ylabel='Signal Direction (degrees)')
print(np.median(SignalStrength[150:280,:],0))  
print(np.median(PredictedTheta1[150:280,:],0)) 
plt.savefig(GraphName1)


# Open our existing CSV file in append mode
# Create a file object for this file



#Visualize the results
fig, ax = plt.subplots(figsize=(12,8))
ax.set(xlim=(-75, 75), ylim=(-75,75))
xStarts=[-Spacing,0,0,-Spacing,0,Spacing,-Spacing,0,Spacing]
yStarts=[Spacing,Spacing,0,0,0,0,-Spacing,-Spacing,-Spacing]
for k in range(NumberOfWhiskers):
    ArrowLength=np.median(SignalStrength[150:280,k])
    yPart=-ArrowLength*np.sin(np.median(PredictedTheta1[150:280,k])/180*3.14159)
    xPart=ArrowLength*np.cos(np.median(PredictedTheta1[150:280,k])/180*3.14159)
    ax.arrow(xStarts[k],yStarts[k],xPart,yPart,color=Colors[k],width=1)
plt.savefig(GraphName3)    

plt.show()
with open('9ArrayTest.csv', 'a', newline='') as f_object:
     
    # Pass this file object to csv.writer()
    # and get a writer object
    writer_object = csv.writer(f_object)
 
    # Pass the list as an argument into
    # the writerow()
    List=[Date,flowSpeed1,flowSpeed2,trial,WhiskerAspect,Flow1Angel,Flow2Angle,Spacing]+list(np.median(SignalStrength[150:280,:],0))+list(np.median(PredictedTheta1[150:280,:],0))+list(np.std(SignalStrength[150:280,:],0))+list(np.std(PredictedTheta1[150:280,:],0))
    writer_object.writerow(List)
    # Close the file object
    f_object.close()

