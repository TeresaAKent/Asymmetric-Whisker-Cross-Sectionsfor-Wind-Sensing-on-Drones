% Open a delta file
%Solve for angle



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
Sensor2a = readtable('NewCircle1FCurve.csv');
Sensor2 = table2array(Sensor2a);
Experimenta2 = table2array(readtable('NewCircle1Data.csv'));
DetailedSensor2X = Interpolate(MotorAngles,Sensor2(:,1));
DetailedSensor2Y = Interpolate(MotorAngles,Sensor2(:,2));
p2 = table2array(readtable('NewCircle1Calibration.csv'));
f2 = polyval(p,linspace(0,5,1000));
Info = readtable('NewCircle1Info.csv');
v2=table2array(Info(1,2:6));
Multiplier2=median(p2(1).*v2.^2+p2(2).*v2+p2(3))/median(sqrt(DetailedSensor2Y.^2+DetailedSensor2X.^2));


ExperimentaData = table2array(readtable('Flow1LowFlow20Phi10Alpha0Trial14Shape2Square1CrossAspect15WhiskerNameCircGDate20241026Delta.csv'));

%MotorAngles = unique(ExperimentaData(:,1));
Column1=8;
Column2=8;
SensorSummary = zeros(size(MotorAngles,1),size(v,1));
SensorSummary(:,1)=MotorAngles;

Shift1 = 0;
Shift2 = 0;
BestOffset=1;

MotorAngles1 =circshift(MotorAngles,Shift1);
MotorAngles2 = circshift(MotorAngles,Shift2);
Offset =BestOffset;
MotorAnglesPrime = circshift(MotorAngles2,Offset,1);

MassiveTable=zeros(size(MotorAngles,1),150);

% For each angle i between 0 and 360 degPrees
for i = 2:2
    % For filter sizes between 1 and 150 of size j
    for j = 1:150
        % Get data set 1
        CellData1 = find(ExperimentaData(:,1) == MotorAngles1(i));
        Signal1X = movmean(ExperimentaData(CellData1,Column1),j);
        Signal1Y = movmean(ExperimentaData(CellData1,Column1+1),j);

        %Get data set 2 at the offset that is best
        CellData2 = find(ExperimentaData(:,1) == MotorAnglesPrime(i));
        Signal2X = movmean(ExperimentaData(CellData2,Column2),j);
        Signal2Y = movmean(ExperimentaData(CellData2,Column2+1),j);

        PairOffsetGuess = FindClosestSimultaneous3 (DetailedSensor1X*Multiplier, DetailedSensor1Y*Multiplier, Multiplier2*DetailedSensor2X,Multiplier2*DetailedSensor2Y, Signal1X, Signal1Y, Signal2X , Signal2Y , int32(MotorAngles(Offset)));
        Error=PairOffsetGuess-MotorAngles1(i);
        Error(Error>180) = Error(Error>180)-360;
        Error(Error<-180) = Error(Error<-180)+360;
        
        MassiveTable(i,j)=sum((Error).^2,'all');
    end
    AverageGuess(i)=median(PairOffsetGuess);
end
NumSampError2 = sqrt(sum(MassiveTable,1)/(150*i));

figure()
% plot(linspace(1,150,150)/150,NumSampError,'-ok')
% hold on
plot(linspace(1,150,150),NumSampError2,'-x')
xlabel("Number of Samples")
ylabel({"RMSE $\hat{\varphi}$"  "[$^\circ$] "},'Interpreter','latex')

function AngleArray = FindClosestSimultaneous3 (AllXCurve1, AllYCurve1, AllXCurve2, AllYCurve2, AllXData1, AllYData1, AllXData2, AllYData2, Offset)
     % Look Up Table
    RolledAllXCurve = circshift(AllXCurve2,Offset,1);
    RolledAllYCurve = circshift(AllYCurve2,Offset,1);
    AngleArray = zeros(size(AllXData1,1),size(AllXData2,2));

    LookUp = [AllXCurve1 AllYCurve1 RolledAllXCurve RolledAllYCurve];
    LookUp = LookUp./max(sqrt(LookUp(:,1:2:end).^2+LookUp(:,2:2:end).^2),[],2);
    for jj =1:size(AllXData2,2)
        DataTable = [AllXData1(:,jj), AllYData1(:,jj), AllXData2(:,jj), AllYData2(:,jj)];
        DataTable = DataTable./max(sqrt(DataTable(:,1:2:end).^2+DataTable(:,2:2:end).^2),[],2);
        dist = zeros(360,size(AllXData1,1));
        for ii = 1:4
            dist = dist+(LookUp(:,ii)-DataTable(:,ii).').^2;
        end
        % dist = movmean(dist,5,1);
        for angle = 1:size(AllXData1,1)
            [~, AngleArray(angle,jj)]=min(dist(:,angle));
        end
    end
    AngleArray(isnan(AllXData1)==1)=NaN;
    AngleArray(isnan(AllXData2)==1)=NaN;

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