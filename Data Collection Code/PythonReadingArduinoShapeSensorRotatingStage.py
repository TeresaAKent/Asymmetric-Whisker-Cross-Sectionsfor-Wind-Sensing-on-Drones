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
from pandas import ExcelWriter

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

CalibrationSize=150


#Identifying Information about flow
flowSpeed1="Low"
flowSpeed2=0
Flow1Angle=0
AlphaAngle=0

#Identifying Information About Test
try: trial
except NameError: trial = None
if trial is None:
    trial=1
else:
    trial+=1
Date=20241219

#Identifying information about whiskers
WhiskerAspect=15
WhiskerShape='2Circle'
NumberOfWhiskers = 3
WhiskerName='CircG'

# Close Any Graphs mad before
plt.close('all') 


# Create names for Outputs
#Excel Files
fileName="Flow1{}Flow2{}Phi1{}Alpha{}Trial{}Shape{}Aspect{}WhiskerName{}Date{}Raw.csv".format(flowSpeed1,flowSpeed2,Flow1Angle,AlphaAngle,trial,WhiskerShape,WhiskerAspect,WhiskerName,Date)
fileName2="Flow1{}Flow2{}Phi1{}Alpha{}Trial{}Shape{}Aspect{}WhiskerName{}Date{}Delta.csv".format(flowSpeed1,flowSpeed2,Flow1Angle,AlphaAngle,trial,WhiskerShape,WhiskerAspect,WhiskerName,Date)
fileName3="Flow1{}Flow2{}Phi1{}Alpha{}Trial{}Shape{}Aspect{}WhiskerName{}Date{}Analyzed.xlsx".format(flowSpeed1,flowSpeed2,Flow1Angle,AlphaAngle,trial,WhiskerShape,WhiskerAspect,WhiskerName,Date)

#Pictures
GraphName1="Flow1{}Flow2{}Phi1{}Alpha{}Trial{}Shape{}Aspect{}WhiskerName{}Date{}Data.png".format(flowSpeed1,flowSpeed2,Flow1Angle,AlphaAngle,trial,WhiskerShape,WhiskerAspect,WhiskerName,Date)
GraphName2="Flow1{}Flow2{}Phi1{}Alpha{}Trial{}Shape{}Aspect{}WhiskerName{}Date{}Analysis.png".format(flowSpeed1,flowSpeed2,Flow1Angle,AlphaAngle,trial,WhiskerShape,WhiskerAspect,WhiskerName,Date)
GraphName3="Flow1{}Flow2{}Phi1{}Alpha{}Trial{}Shape{}Aspect{}WhiskerName{}Date{}AnalysisCalibrated.png".format(flowSpeed1,flowSpeed2,Flow1Angle,AlphaAngle,trial,WhiskerShape,WhiskerAspect,WhiskerName,Date)

file = open(fileName, "a")
print("Created file")

# Connect to the arduino 
arduino_port = "COM8" #serial port of Arduino
baud = 115200 #arduino uno runs at 9600 baud
ser = serial.Serial(arduino_port, baud)
print("Connected to Arduino port:" + arduino_port)

# Initilization
sensor_data=[]
line_data=[]
line=0



readingsTemp2=np.zeros(4*NumberOfWhiskers)
t0 = process_time()
MotorAngle=0

while MotorAngle <= MaxAngle:
    # Read data from arduino
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
            readingsTemp2[Readingnum*4:Readingnum*4+4]=readingTemp[1:5]
            #print('rt2',readingsTemp2)
            MotorAngle=float(readingTemp[1])
            #print('motor',MotorAngle)
            if line==0:
                sensor_data=readingsTemp2
            else:
                sensor_data=np.vstack((sensor_data,readingsTemp2))
            line = line+1
        else:
            readingsTemp2[Readingnum*4:Readingnum*4+4]=readingTemp[1:5]
            MotorAngle=int(readingTemp[1])
    except:
        pass
    print('rT2',readingsTemp2)
    print(line)

# After the test close the serial
ser.close()
t1=process_time()
print('samplerate',np.round(np.size(sensor_data,0)/(t1-t0),2),'hz')

# Save the Raw Data to Excel
with open(fileName, 'w', encoding='UTF8', newline='') as f:
    writer = csv.writer(f)
    writer.writerows(sensor_data)
print("Data collection complete!")
file.close()



# Convert to the Delta Data and Plot
# Convert the data into an array
SensorArrayData=np.zeros((np.shape(sensor_data)[0]-1,4*NumberOfWhiskers))
for ii in range(np.size(sensor_data,0)-1):
    try:
        hold=np.array(sensor_data[ii])
        SensorArrayData[ii,:]=hold[0:4*NumberOfWhiskers]
    # block raising an exception
    except:
        pass # doing nothing on exception

#Get initial values for the sensor
InitialXYZ=np.zeros((3,NumberOfWhiskers))
for jj in range(NumberOfWhiskers):
    InitialXYZ[0,jj]=stat.median(SensorArrayData[5:30,4*jj+1])
    InitialXYZ[1,jj]=stat.median(SensorArrayData[5:30,4*jj+2])
    InitialXYZ[2,jj]=stat.median(SensorArrayData[5:30,4*jj+3])
jj=0
#print(stat.median(SensorArrayData[0:30,3*jj]),stat.median(SensorArrayData[0:30,3*jj+1]))
# InitialXYZ[0,0]=-89
# InitialXYZ[1,0]=-73
# InitialXYZ[2,0]=393
SensorChangeData=np.zeros((np.size(SensorArrayData,0),3*NumberOfWhiskers+1))
SensorChangeData[:,0]=SensorArrayData[:,0]
for jj in range(NumberOfWhiskers):
    SensorChangeData[:,jj*3+1:jj*3+4]=SensorArrayData[:,jj*4+1:jj*4+4]-InitialXYZ[:,jj]
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
    axs2[0].plot(np.arange(np.size(SensorChangeData,0)),-1*SensorChangeData[:,j*3+1], color=Colors[j],label="B{}".format(j+1))
    axs2[1].plot(np.arange(np.size(SensorChangeData,0)),-1*SensorChangeData[:,j*3+2], color=Colors[j],label="B{}".format(j+1))
    axs2[2].plot(np.arange(np.size(SensorChangeData,0)),-1*SensorChangeData[:,j*3+3], color=Colors[j],label="B{}".format(j+1))

plt.ylim([-100,100])
axs2[0].set(xlabel='Time (s)')
axs2[1].set(xlabel='Time(s)')
axs2[2].set(xlabel='Time(s)')
axs2[0].set(ylabel='Bx Signal Strength [mT]')
axs2[1].set(ylabel='By Signal Strength [mT]')
axs2[2].set(ylabel='Bz Signal Strength [mT]')
plt.legend()
plt.savefig(GraphName1)


# Make new arrays for Calculated Values
SignalStrength = np.zeros((np.size(SensorChangeData,0),NumberOfWhiskers))
PredictedTheta = np.zeros((np.size(SensorChangeData,0),NumberOfWhiskers))
StdvSignal = np.zeros((np.size(SensorChangeData,0),NumberOfWhiskers))
StdvAngle = np.zeros((np.size(SensorChangeData,0),NumberOfWhiskers))


MotorAnglesListed=  np.unique(SensorChangeData[:,0])  
numAngles=np.size(MotorAnglesListed)
AnalyzedData=np.zeros((numAngles,NumberOfWhiskers,9))
# BxAnalysis=np.zeros(numAngles)
# ByAnalysis=np.zeros(numAngles)
# BAnalysis=np.zeros(numAngles)
# ThetaAnalysis=np.zeros(numAngles)
# StdvBxAnalysis=np.zeros(numAngles)
# StdvByAnalysis=np.zeros(numAngles)
# StdvBAnalysis=np.zeros(numAngles)
# StdvThetaAnalysis=np.zeros(numAngles)

# Plot the angle and signal strength of each line
xval=np.zeros((np.size(SensorChangeData,0),NumberOfWhiskers))
yval=np.zeros((np.size(SensorChangeData,0),NumberOfWhiskers))
for i in range(NumberOfWhiskers):
    for MotorAngles in enumerate(MotorAnglesListed):
        CurrentAngle=MotorAngles[1]
        fil=5
        xval[(SensorChangeData[:,0]==CurrentAngle),i]=np.convolve(SensorChangeData[(SensorChangeData[:,0]==CurrentAngle),3*i+1], np.ones(fil)/fil, mode='same')
        yval[(SensorChangeData[:,0]==CurrentAngle),i]=np.convolve(SensorChangeData[(SensorChangeData[:,0]==CurrentAngle),3*i+2], np.ones(fil)/fil, mode='same')
    SignalStrength[:,i]=np.sqrt(np.square(xval[:,i])+np.square(yval[:,i]))
    PredictedTheta[:,i] = np.arctan2(SensorChangeData[:,3*i+1],SensorChangeData[:,3*i+2])*180/3.141592


ma=0;
fig, axs = plt.subplots(2,2)
fig.suptitle('Rotation Affect')
for MotorAngles in enumerate(MotorAnglesListed):
    for i in range(NumberOfWhiskers):
        CurrentAngle=MotorAngles[1]
        print('CurrentAngle',CurrentAngle)
        AnalyzedData[ma,i,0]=CurrentAngle
        AnalyzedData[ma,i,1]=np.average(xval[(SensorChangeData[:,0]==CurrentAngle),i])
        AnalyzedData[ma,i,2]=np.average(yval[(SensorChangeData[:,0]==CurrentAngle),i])
        AnalyzedData[ma,i,3]=np.average(SignalStrength[(SensorChangeData[:,0]==CurrentAngle),i])
        AnalyzedData[ma,i,5]=np.std(xval[(SensorChangeData[:,0]==CurrentAngle),i])
        AnalyzedData[ma,i,6]=np.std(yval[(SensorChangeData[:,0]==CurrentAngle),i])
        AnalyzedData[ma,i,7]=np.std(SignalStrength[(SensorChangeData[:,0]==CurrentAngle),i])
        AnalyzedData[ma,i,[4,8]]=PredictThetaAngle(PredictedTheta[(SensorChangeData[:,0]==CurrentAngle),i])
        if CurrentAngle<0:
            CurrentAngle=158+8+abs(CurrentAngle+154)
        axs[0,0].errorbar(CurrentAngle,AnalyzedData[ma,i,1],AnalyzedData[ma,i,5], linestyle='None',marker='o', color=Colors[i])
        axs[0,1].errorbar(CurrentAngle,AnalyzedData[ma,i,3],AnalyzedData[ma,i,8], linestyle='None',marker='o', color=Colors[i])
        axs[1,0].errorbar(CurrentAngle,AnalyzedData[ma,i,2],AnalyzedData[ma,i,7], linestyle='None',marker='o', color=Colors[i])
        axs[1,1].errorbar(CurrentAngle,AnalyzedData[ma,i,4],AnalyzedData[ma,i,8], linestyle='None',marker='o', color=Colors[i])
    ma+=1


axs[0,0].set(xlabel='MotorAngle (deg)')
axs[0,1].set(xlabel='MotorAngle (deg)')
axs[1,0].set(xlabel='MotorAngle (deg)')
axs[1,1].set(xlabel='MotorAngle (deg)')

axs[0,0].set(ylabel='Bx [mT]')
axs[0,1].set(ylabel='||B|| [mT]')
axs[1,0].set(ylabel='By [mT]')
axs[1,1].set(ylabel='Theta (deg)')

plt.savefig(GraphName2)

names=['Angle','Bx','By','B','Theta','StdvBx', 'StdvBy', 'StdvB', 'StdvTheta']

with ExcelWriter(fileName3) as writer:
    for Variables in range (9):
        pd.DataFrame(AnalyzedData[:,:,Variables]).to_excel(writer,names[Variables])




plt.show()

# #Redo but with calibration (This only works with symetry)
# xMax=np.max([abs(np.max(AnalyzedData[:,0])),abs(np.min(AnalyzedData[:,0]))])
# yMax=np.max([abs(np.max(AnalyzedData[:,1])),abs(np.min(AnalyzedData[:,1]))])
# Normalizers=np.abs([np.max(AnalyzedData[:,0]),yMax,np.min(AnalyzedData[:,0]),yMax])

# NormMax=np.max(Normalizers)

# SignalStrengthNorm = np.zeros((np.size(SensorChangeData,0),NumberOfWhiskers))
# PredictedThetaNorm = np.zeros((np.size(SensorChangeData,0),NumberOfWhiskers))
# StdvSignalNorm = np.zeros((np.size(SensorChangeData,0),NumberOfWhiskers))
# StdvAngleNorm = np.zeros((np.size(SensorChangeData,0),NumberOfWhiskers))

# # Plot the angle and signal strength of each line
# xvalNorm=np.zeros(np.size(SensorChangeData,0))
# yvalNorm=np.zeros(np.size(SensorChangeData,0))

# for i in range(NumberOfWhiskers):
#     for MotorAngles in enumerate(MotorAnglesListed):
#         CurrentAngle=MotorAngles[1]
#         xvalNorm[(SensorChangeData[:,0]==CurrentAngle)]=np.convolve(SensorChangeData[(SensorChangeData[:,0]==CurrentAngle),4*i+1], np.ones(fil)/fil, mode='same')
#         yvalNorm[(SensorChangeData[:,0]==CurrentAngle)]=np.convolve(SensorChangeData[(SensorChangeData[:,0]==CurrentAngle),4*i+2], np.ones(fil)/fil, mode='same')

#     xvalNorm[(xval>0)]=xval[(xval>0)]/Normalizers[0]*NormMax
#     xvalNorm[(xval<0)]=xval[(xval<0)]/Normalizers[2]*NormMax
#     yvalNorm[(yval>0)]=yval[(yval>0)]/Normalizers[1]*NormMax
#     yvalNorm[(yval<0)]=yval[(yval<0)]/Normalizers[3]*NormMax
    
#     SignalStrengthNorm[:,i]=np.sqrt(np.square(xvalNorm)+np.square(yvalNorm))
#     PredictedThetaNorm[:,i] = np.arctan2(xvalNorm,yvalNorm)*180/3.141592

# AnalyzedDataNorm=np.zeros((numAngles,8))

# ma=0
# fig, axs = plt.subplots(2,2)
# fig.suptitle('Rotation Affect Normalized')
# for MotorAngles in enumerate(MotorAnglesListed):
#     CurrentAngle=MotorAngles[1]
#     print('CurrentAngle',CurrentAngle)
#     AnalyzedDataNorm[ma,0]=np.average(xvalNorm[(SensorChangeData[:,0]==CurrentAngle)])
#     AnalyzedDataNorm[ma,1]=np.average(yvalNorm[(SensorChangeData[:,0]==CurrentAngle)])
#     AnalyzedDataNorm[ma,2]=np.average(SignalStrengthNorm[(SensorChangeData[:,0]==CurrentAngle)])
#     AnalyzedDataNorm[ma,4]=np.std(xvalNorm[(SensorChangeData[:,0]==CurrentAngle)])
#     AnalyzedDataNorm[ma,5]=np.std(yvalNorm[(SensorChangeData[:,0]==CurrentAngle)])
#     AnalyzedDataNorm[ma,6]=np.std(SignalStrengthNorm[(SensorChangeData[:,0]==CurrentAngle)])
#     AnalyzedDataNorm[ma,[3,7]]=PredictThetaAngle(PredictedThetaNorm[(SensorChangeData[:,0]==CurrentAngle)])
#     if CurrentAngle<0:
#         CurrentAngle=158+8+abs(CurrentAngle+154)
#     axs[0,0].errorbar(CurrentAngle,AnalyzedDataNorm[ma,0],AnalyzedDataNorm[ma,4], linestyle='None',marker='o')
#     axs[0,1].errorbar(CurrentAngle,AnalyzedDataNorm[ma,2],AnalyzedDataNorm[ma,6], linestyle='None',marker='o')
#     axs[1,0].errorbar(CurrentAngle,AnalyzedDataNorm[ma,1],AnalyzedDataNorm[ma,5], linestyle='None',marker='o')
#     axs[1,1].errorbar(CurrentAngle,AnalyzedDataNorm[ma,3],AnalyzedDataNorm[ma,7], linestyle='None',marker='o')
#     ma+=1


# axs[0,0].set(xlabel='MotorAngle (deg)')
# axs[0,1].set(xlabel='MotorAngle (deg)')
# axs[1,0].set(xlabel='MotorAngle (deg)')
# axs[1,1].set(xlabel='MotorAngle (deg)')

# axs[0,0].set(ylabel='Bx [mT]')
# axs[0,1].set(ylabel='||B|| [mT]')
# axs[1,0].set(ylabel='By [mT]')
# axs[1,1].set(ylabel='Theta (deg)')

# plt.savefig(GraphName3)


# with open('MotorizedRotationTesting2.csv', 'a', newline='') as f_object:
#     CurrentAngle=int(MotorAngles[1])
#     # Pass this file object to csv.writer()
#     # and get a writer object
#     writer_object = csv.writer(f_object)
 
#     # Pass the list as an argument into
#     # the writerow()
#     ma=0
#     for MotorAngles in enumerate(MotorAnglesListed):
#         CurrentAngle=int(MotorAngles[1])
#         List=[Date,CurrentAngle,flowSpeed1,flowSpeed2,trial,WhiskerAspect,Flow1Angle,AlphaAngle,WhiskerShape,WhiskerName]+list(AnalyzedData[ma,:])
#         writer_object.writerow(List)
#         ma+=1
#     # Close the file object
#     f_object.close()

