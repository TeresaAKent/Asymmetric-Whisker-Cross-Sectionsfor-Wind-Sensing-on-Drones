close all


% Open the first Example of the sensor
Sensor1a = readtable('NewCircle1FCurve.csv');
Sensor1 = table2array(Sensor1a);
Experimenta1 = table2array(readtable('NewCircle1Data.csv'));
MotorAngles=sort(Experimenta1(:,1));
DetailedSensor1X = Interpolate(MotorAngles,Sensor1(:,1));
DetailedSensor1Y = Interpolate(MotorAngles,Sensor1(:,2));
p = table2array(readtable('NewCircle1Calibration.csv'));
f1 = polyval(p,linspace(0,5,1000));
Info = readtable('NewCircle1Info.csv');
v=table2array(Info(1,2:6));
Multiplier=median(p(1).*v.^2+p(2).*v+p(3))/median(sqrt(DetailedSensor1Y.^2+DetailedSensor1X.^2));


%open the second instance of the sesnor
Sensor2a = readtable('NewCircle2FCurve.csv');
Sensor2 = table2array(Sensor2a);
Experimenta2 = table2array(readtable('NewCircle2Data.csv'));
DetailedSensor2X = Interpolate(MotorAngles,Sensor2(:,1));
DetailedSensor2Y = Interpolate(MotorAngles,Sensor2(:,2));
p2 = table2array(readtable('NewCircle2Calibration.csv'));
f2 = polyval(p,linspace(0,5,1000));
Info = readtable('NewCircle2Info.csv');
v2=table2array(Info(1,2:6));
Multiplier2=median(p2(1).*v2.^2+p2(2).*v2+p2(3))/median(sqrt(DetailedSensor2Y.^2+DetailedSensor2X.^2));

% Open sensor 3
Sensor3a = readtable('NewCircle3FCurve.csv');
Sensor3 = table2array(Sensor3a);
Experimenta3 = table2array(readtable('NewCircle3Data.csv'));
DetailedSensor3X = Interpolate(MotorAngles,Sensor3(:,1));
DetailedSensor3Y = Interpolate(MotorAngles,Sensor3(:,2));
p3 = table2array(readtable('NewCircle3Calibration.csv'));
f3 = polyval(p3,linspace(0,5,1000));
Info = readtable('NewCircle3Info.csv');
v3=table2array(Info(1,2:6));

BValues1=sqrt(Experimenta1(:,2:2:end).^2+Experimenta1(:,3:2:end).^2);
BValues2=sqrt(Experimenta2(:,2:2:end).^2+Experimenta2(:,3:2:end).^2);
BValues3=sqrt(Experimenta3(:,2:2:end).^2+Experimenta3(:,3:2:end).^2);

mean1 = mean(BValues1,1);
mean2 = mean(BValues2,1);
mean3 = mean(BValues3,1);


std1 = std(BValues1,1);
std2 = std(BValues2,1);
std3 = std(BValues3,1);

figure()
subplot(1,2,1)
title('Pre Processed Data')
%errorbar(v,mean1,std1,'s',"LineStyle","none")
hold on
errorbar(v2([1,2,3,5]),mean2([1,2,3,5]),std2([1,2,3,5]),'s',"MarkerSize",5,"LineStyle","none","MarkerEdgeColor","blue","MarkerFaceColor",[0.65 0.85 0.90])
hold on

errorbar(v3([1,2,3,5]),mean3([1,2,3,5]),std3([1,2,3,5]),'s',"MarkerSize",5,"LineStyle","none","MarkerEdgeColor","red","MarkerFaceColor",[1.0 0.5 0.5])
hold on
xlim([0,4])
ylim([0,35])
xlabel('Velocity [m/s]')
ylabel({"$||B||_2 [mT]$"},'Interpreter','latex')
box on
subplot(1,2,2)
title('Post Processed Data')
mValues=SolveForMs(Experimenta1,v);
mValues2=SolveForMs(Experimenta2,v2);
mValues3=SolveForMs(Experimenta3,v3);
mAvg=mean([mValues2,mValues3]);

NewExpData = Normalize(Experimenta1, mValues,mAvg);
NewExpData2 = Normalize(Experimenta2, mValues2,mAvg);
NewExpData3 = Normalize(Experimenta3, mValues3,mAvg);

BValues1=sqrt(NewExpData(:,2:2:end).^2+NewExpData(:,3:2:end).^2);
BValues2=sqrt(NewExpData2(:,2:2:end).^2+NewExpData2(:,3:2:end).^2);
BValues3=sqrt(NewExpData3(:,2:2:end).^2+NewExpData3(:,3:2:end).^2);

mean1 = mean(BValues1,1);
mean2 = mean(BValues2,1);
mean3 = mean(BValues3,1);

std1 = std(BValues1,1);
std2 = std(BValues2,1);
std3 = std(BValues3,1);

%errorbar(v,mean1,std1,'s',"LineStyle","none")
hold on
errorbar(v2([1,2,3,5]),mean2([1,2,3,5]),std2([1,2,3,5]),'s',"MarkerSize",5,"LineStyle","none","MarkerEdgeColor","blue","MarkerFaceColor",[0.65 0.85 0.90])
hold on,
errorbar(v3([1,2,3,5]),mean3([1,2,3,5]),std3([1,2,3,5]),'s',"MarkerSize",5,"LineStyle","none","MarkerEdgeColor","red","MarkerFaceColor",[1.0 0.5 0.5])

plot(linspace(0,4,100),mAvg*linspace(0,4,100).^2,'k-')

[SSR,SST]=CalcSSR(v2([1,2,3,5]),v3([1,2,3,5]),mean2([1,2,3,5]),mean3([1,2,3,5]),mAvg)


xlim([0,4])
ylim([0,35])
xlabel('Velocity [m/s]')
ylabel({"$||B||_2$ [mT] "},'Interpreter','latex')

box on

function [SSR,SST]=CalcSSR(xData1,xData2,mean1,mean2,mAvg)
    yPred1=mAvg*xData1.^2;
    yPred2=mAvg*xData2.^2;
    SSR=sum((mean1-yPred1).^2)+sum((mean2-yPred2).^2);
    meany1=mean(mean1);
    meany2=mean(mean2);
    SST=sum((mean1-meany1).^2)+sum((mean2-meany2).^2);
    RMSE=sqrt(SSR/8)

    xPred1=sqrt(mean1/mAvg);
    xPred2=sqrt(mean2/mAvg);
    RMSEV=sqrt((sum((xPred1-xData1).^2)+sum((xPred2-xData2).^2))/8)
    
end
function YOut = Interpolate(xs,ys)
    dist=xs-linspace(0,359,360);
    dist(dist>180)=dist(dist>180)-360;
    dist(dist<-180)=dist(dist<-180)+360;
    
    YOut=ones(360,1);
    for i=0:359
        [~, I]=sort(abs(dist(:,i+1)));
        bottom=xs(I(2))-xs(I(1));
        bottom(abs(bottom)<1) = sign(bottom)*1;
        YOut(i+1) = ys(I(1)) + (i-xs(I(1))) * (ys(I(2))-ys(I(1)))/bottom;
    end       

end

function mValues=SolveForMs(ExperimentalData,v)
    posy=max(ExperimentalData(:,3:2:end),[],1);
    posx=max(ExperimentalData(:,2:2:end),[],1);
    negy=min(ExperimentalData(:,3:2:end),[],1);
    negx=min(ExperimentalData(:,2:2:end),[],1);
    mpy=abs(mean(posy/v.^2));
    mpx=abs(mean(posx/v.^2));
    mny=abs(mean(negy/v.^2));
    mnx=abs(mean(negx/v.^2));
    mValues=[mpy,mpx,mny,mnx];
end

function NewExpData = Normalize(ExperimentalData, mValues,mAvg)
    %mAvg=mean(mValues);
    NewExpData=ExperimentalData;
    xVals=ExperimentalData(:,2:2:end);
    yVals=ExperimentalData(:,3:2:end);
    xVals(xVals>0)=xVals(xVals>0)*mAvg/mValues(2);
    xVals(xVals<0)=xVals(xVals<0)*mAvg/mValues(4);
    yVals(yVals>0)=yVals(yVals>0)*mAvg/mValues(1);
    yVals(yVals<0)=yVals(yVals<0)*mAvg/mValues(3);
    NewExpData(:,2:2:end)=xVals;
    NewExpData(:,3:2:end)=yVals;
end

