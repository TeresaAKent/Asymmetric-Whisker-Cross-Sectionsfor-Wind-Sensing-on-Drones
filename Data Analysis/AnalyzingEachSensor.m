%% Initialize
close all
WhiskerShape="NewCircle4";

%% Read the raw data from the experiments
% Open the first Example of the sensor
name1='Flow13.5Flow20Phi10Alpha0Trial1ShapeCircleAspect15WhiskerNameCircGDate20241006Delta.csv';
Sensor1a = readtable(name1);
Sensor1 = table2array(Sensor1a(150:end,:));
v1 = 2.5;
Trial(1) = extractBetween(name1,"Trial","Shape");
Date(1) = extractBetween(name1,"Date","Delta");
Column(1) =8;


% Open the second example of the sensor
name2='Flow13.5Flow20Phi10Alpha0Trial2ShapeCircleAspect15WhiskerNameCircGDate20241006Delta.csv';
Sensor2a = readtable(name2);
Sensor2 = table2array(Sensor2a(150:end,:));
v2=2;
Trial(2) = extractBetween(name2,"Trial","Shape");
Date(2) = Date(1);
Column(2) = Column(1);

% Opent the third example of the sensor
name3 = 'Flow13.5Flow20Phi10Alpha0Trial4ShapeCircleAspect15WhiskerNameCircGDate20241006Delta.csv';
Sensor3a = readtable(name3);
Sensor3 = table2array(Sensor3a(150:end,:));
v3= 4;
Trial(3) =extractBetween(name3,"Trial","Shape");
Date(3) = Date(1);
Column(3)=Column(1);

% Opent the fourth example of the sensor
name4 = 'Flow13.5Flow20Phi10Alpha0Trial2ShapeCircleAspect15WhiskerNameCircGDate20241006Delta.csv';
Sensor4a = readtable(name4);
Sensor4 = table2array(Sensor4a(150:end,:));
v4= 2;
Trial(4) = extractBetween(name4,"Trial","Shape");
Date(4) = Date(1);
Column(4)=Column(1);

% Opent the fifth example of the sensor
name5 ='Flow13.5Flow20Phi10Alpha0Trial4ShapeCircleAspect15WhiskerNameCircGDate20241006Delta.csv';
Sensor5a = readtable(name5);
Sensor5 = table2array(Sensor5a(150:end,:));
v5=4;
Trial(5) = extractBetween(name5,"Trial","Shape");
Date(5) = Date(1);
Column(5)=Column(1);

v=[v1,v2,v3, v4,v5];


%% Recurve the Data
MotorAngles = unique(Sensor3(:,1));
SensorSummary = zeros(size(MotorAngles,1),size(v,1));
SensorSummary(:,1)=MotorAngles;

for i = 1:size(MotorAngles)
    CellData1 = find(Sensor1(:,1) == MotorAngles(i));
    
    SensorSummary(i,2) = mean( movmean(rmoutliers(Sensor1(CellData1,Column(1))),5),1,'omitnan');
    SensorSummary(i,3) = mean( movmean(rmoutliers(Sensor1(CellData1,Column(1)+1)),5),1,'omitnan');
    CellData2 = find(Sensor2(:,1) == MotorAngles(i));
    SensorSummary(i,4) = mean( movmean(rmoutliers(Sensor2(CellData2,Column(2))),5),1,'omitnan');
    SensorSummary(i,5) = mean( movmean(rmoutliers(Sensor2(CellData2,Column(2)+1)),5),1,'omitnan');
    CellData3 = find(Sensor3(:,1) == MotorAngles(i));
    SensorSummary(i,6) = mean( movmean(rmoutliers(Sensor3(CellData3,Column(3))),5),1,'omitnan');
    SensorSummary(i,7) = mean( movmean(rmoutliers(Sensor3(CellData3,Column(3)+1)),5),1,'omitnan'); 
    CellData4 = find(Sensor4(:,1) == MotorAngles(i));
    SensorSummary(i,8) = mean( movmean(rmoutliers(Sensor4(CellData4,Column(4))),5),1,'omitnan');
    SensorSummary(i,9) = mean( movmean(rmoutliers(Sensor4(CellData4,Column(4)+1)),5),1,'omitnan'); 
    CellData5 = find(Sensor5(:,1) == MotorAngles(i));
    SensorSummary(i,10) = mean( movmean(rmoutliers(Sensor5(CellData5,Column(5))),5),1,'omitnan');
    SensorSummary(i,11) = mean( movmean(rmoutliers(Sensor5(CellData5,Column(5)+1)),5),1,'omitnan');    

end

% SensorSummary(:,8:9) = circshift(SensorSummary(:,8:9),5,1)
% SensorSummary(:,2:3) = circshift(SensorSummary(:,2:3),2,1)

%Generate the F Curves
FCurves=zeros(size(MotorAngles,1),7);
FCurves(:,1) = MotorAngles;
for i=1:size(v,2)
    vValue=-.66*v(i)^2+12.36*v(i)-.112;
    StrengthCurve(:,i) = sqrt(SensorSummary(:,2+(i-1)*2).^2+SensorSummary(:,3+(i-1)*2).^2);
    StrengthCurve2(:,i)=StrengthCurve(:,i)./v(i)^2;
    % max(StrengthCurve(:,i),[],'all')
    FCurves(:,2+(i-1)*2) = SensorSummary(:,2+(i-1)*2)/median(StrengthCurve(:,i),'omitnan');
    FCurves(:,3+(i-1)*2) = SensorSummary(:,3+(i-1)*2)/median(StrengthCurve(:,i),'omitnan');
    % FCurves(:,2+(i-1)*2) = SensorSummary(:,2+(i-1)*2)/StrengthCurve(15,i);
    % FCurves(:,3+(i-1)*2) = SensorSummary(:,3+(i-1)*2)/StrengthCurve(15,i);
    % FCurves(:,2+(i-1)*2) = SensorSummary(:,2+(i-1)*2)./median(StrengthCurve2(:,i));
    % FCurves(:,3+(i-1)*2) = SensorSummary(:,3+(i-1)*2)./median(StrengthCurve2(:,i));
    % FCurves(:,2+(i-1)*2) = SensorSummary(:,2+(i-1)*2)/vValue;
    % FCurves(:,3+(i-1)*2) = SensorSummary(:,3+(i-1)*2)/vValue;
end



CombinedCurveX = mean(FCurves(:,2:2:end),2,'omitnan');
CombinedCurveY = mean(FCurves(:,3:2:end),2,'omitnan');

CombinedStrength = mean(sqrt(CombinedCurveX.^2+CombinedCurveY.^2));

ReferenceAngle=180-atan2d(CombinedCurveY,CombinedCurveX);
BestRoll=0;
% Calculate Asymmetry
AsymmetryMetric=100;
for i =1: size(ReferenceAngle)
    AsymmetryTemp=circshift(ReferenceAngle,i)-linspace(0,360,101).';
    AsymmetryTemp(AsymmetryTemp<-180)=AsymmetryTemp(AsymmetryTemp<-180)+360;
    AsymmetryTemp(AsymmetryTemp>180)=AsymmetryTemp(AsymmetryTemp>180)-360;
    AsymmetryMetricT=sqrt(mean(AsymmetryTemp.^2,'omitnan'));
    if AsymmetryMetricT<AsymmetryMetric
        AsymmetryMetric=AsymmetryMetricT;
        BestRoll=i;
    end
end

%Bu Curve
figure()
scatter(MotorAngles,circshift(FCurves(:,2:2:end),BestRoll),18,'filled')
hold on
plot(MotorAngles,circshift(CombinedCurveX,BestRoll),'k')
xlabel({"Flow Direction" '$\varphi$ [$^\circ]$'},'Interpreter','latex')
ylabel({"Relative Strength u Axis" "$F_u$"},'Interpreter','latex')
box on
xlim([0,360])
ylim([-2,2])

%legend(sprintf('v1= %.1f [m/s]',round(v(1),1)),sprintf('v2= %.1f [m/s]',round(v(2),1)),sprintf('v3= %.1f [m/s]',round(v(3),1)))
hold off

%Bw Curve
figure()
scatter(MotorAngles,circshift(FCurves(:,3:2:end),BestRoll),18,'filled')
hold on
plot(MotorAngles,circshift(CombinedCurveY,BestRoll),'k')
xlabel({"Flow Direction" '$\varphi$ [$^\circ]$'},'Interpreter','latex')
ylabel({"Relative Strength w Axis" "$F_w$"},'Interpreter','latex')
%legend(sprintf('v1= %.1f [m/s]',round(v(1),1)),sprintf('v2= %.1f [m/s]',round(v(2),1)),sprintf('v3= %.1f [m/s]',round(v(3),1)))
box on
hold off
xlim([0,360])
ylim([-2,2])

%Theta Curve
figure()
DataAngles=180-atan2d(FCurves(:,3:2:end),FCurves(:,2:2:end));

MotorAngles2=repmat(MotorAngles,1,5)
ThetaData=180-circshift(atan2d(FCurves(:,3:2:end),FCurves(:,2:2:end)),BestRoll);
indx1=find(MotorAngles2>90);
indx2=find(ThetaData<30);
indexes=intersect(indx1,indx2);
ThetaData(indexes)=ThetaData(indexes)+360;

scatter(MotorAngles,ThetaData,18,'filled')
hold on
ThetaControl=180-circshift(atan2d(CombinedCurveY,CombinedCurveX),BestRoll);
indx3=find(ThetaControl<30);
indx4=find(MotorAngles>90);
indexes=intersect(indx3,indx4)
ThetaControl(indexes)=ThetaControl(indexes)+360;
plot(MotorAngles,ThetaControl,'k')
xlabel({"Flow Direction" '$\varphi$ [$^\circ]$'},'Interpreter','latex')
ylabel({"Sensed Direction" '$\theta$ $[^\circ$]'},'Interpreter','latex')
xlim([0,360])
ylim([0,380])
%legend(sprintf('v1= %.1f [m/s]',round(v(1),1)),sprintf('v2= %.1f [m/s]',round(v(2),1)),sprintf('v3= %.1f [m/s]',round(v(3),1)))
box on
hold off


%Strength Curve
figure()
Strength=sqrt(FCurves(:,3:2:end).^2+FCurves(:,2:2:end).^2);
%Strength=sqrt(SensorSummary(:,3:2:end).^2+SensorSummary(:,2:2:end).^2)./v.^2;
scatter(MotorAngles,circshift(Strength,BestRoll),18,'filled')
hold on
CurveStrength=sqrt(CombinedCurveY.^2+CombinedCurveX.^2);
plot(MotorAngles,circshift(CurveStrength,BestRoll),'k')
xlabel({"Flow Direction" '$\varphi$ [$^\circ]$'},'Interpreter','latex')
ylabel({"Relative Strength" "$\overrightarrow{F}$"},'Interpreter','latex')
ylim([0,2.25])
xlim([0,360])
%legend(sprintf('v1= %.1f [m/s]',round(v(1),1)),sprintf('v2= %.1f [m/s]',round(v(2),1)),sprintf('v3= %.1f [m/s]',round(v(3),1)))
box on
hold off

% Velcoity Curve
figure(5)
array=colororder;
y=zeros(size(v,2),1);
for i =1:size(v,2)
    Signal1=sqrt(SensorSummary(:,2+(i-1)*2).^2+SensorSummary(:,3+(i-1)*2).^2);
    Divide=sqrt(CombinedCurveX.^2+CombinedCurveY.^2);
    Signal=Signal1./Divide;
    y(i)=mean(Signal,'omitnan');
    errorbar(v(i),mean(Signal,'omitnan'),std(Signal,'omitnan'),'-o', "MarkerSize",4,"LineWidth",2,"MarkerFaceColor",array(i,:))
    %scatter(v(i),StrengthCurve(53,i))
    % scatter(v(i),StrengthCurve(5,i))
    hold on
end
ylim([0,100])
v2=v;
v2(end+1)=0;
y(end+1)=0;
y2=StrengthCurve(53,:);
y2(end+1)=0;

p = polyfit(v2,y,2)
vPrime=sort(v2);
f1 = polyval(p,linspace(0,5,1000));
plot(linspace(0,5,1000),f1,'k')
%plot(linspace(1,5,100),linspace(1,5,100).^2,'k')
xlabel({"Velocity" '$v$ [m/s]'},'Interpreter','latex')
ylabel({"Signal Strength $\frac{\overrightarrow{B}}{\overrightarrow{F}}$  [mT]"},'Interpreter','latex')

% Solve for the Forward Error
ExpectedSignal=zeros(size(MotorAngles,1),size(SensorSummary,2));
ExpectedSignal(:,1)=MotorAngles;
for i =1:size(v,2)
    ExpectedSignal(:,(i-1)*2+2:(i-1)*2+3)=[CombinedCurveX,CombinedCurveY]*(p(1)*v(i)^2+p(2)*v(i)+p(3));
end
Divisor = SensorSummary(:,2:end);
Divisor(abs(Divisor)<5)=Divisor(abs(Divisor)<5)./abs(Divisor(abs(Divisor)<5))*5;
FullMagError=SensorSummary(:,2:end)-ExpectedSignal(:,2:end);
FullMagError(isnan(SensorSummary(:,2:end))==1)=NaN;
MagneticError =sqrt(mean((FullMagError).^2,'all','omitnan'))
%PercentError=sqrt(mean(((SensorSummary(:,2:end)-ExpectedSignal(:,2:end))./mean(abs(ExpectedSignal(:,2:end)),1)).^2,'omitnan'))

% Solve for the Reverse Error Single Sensor
for i=1:size(v,2)
    Hold = DataAngles(:,i)-ReferenceAngle.';
    [~,q] = min(abs(Hold), [], 2);
    TempGuess=MotorAngles(q);
    TempGuess(isnan(DataAngles(:,i)))=NaN;
    GuessAngles(:,i)=TempGuess;
    FX=CombinedCurveX(q);
    FY=CombinedCurveY(q);
    %BPrime=sqrt(FX.^2+FY.^2);
    Strength2=sqrt(SensorSummary(:,2+(i-1)*2).^2+SensorSummary(:,3+(i-1)*2).^2);
    %Strength2(isnan(SensorSummary(:,2:end))==1)=NaN;
    yVal=Strength2./sqrt(FX.^2+FY.^2);
    [~,vLookUp]=min(abs(yVal-f1),[],2);
    vLookUp(isnan(Strength2)==1)=NaN;
    vEstimates(:,i)=5*vLookUp/1000;
end

vError=sqrt(mean((vEstimates-v).^2,'all','omitnan'))
ThetaError = GuessAngles-MotorAngles;
ThetaError(ThetaError>180)=ThetaError(ThetaError>180)-360;
ThetaError(ThetaError<-180)=ThetaError(ThetaError<-180)+360;
RMSETheta=sqrt(mean(ThetaError.^2,'all','omitnan'))
RMSETheta2=sqrt(mean(ThetaError.^2,1,'omitnan'))


% Calculate v accuracy

% Calculate Asymmetry
AsymmetryMetric=100;
for i =1: size(ReferenceAngle)
    AsymmetryTemp=circshift(ReferenceAngle,i)-linspace(0,360,101).';
    AsymmetryTemp(AsymmetryTemp<-180)=AsymmetryTemp(AsymmetryTemp<-180)+360;
    AsymmetryTemp(AsymmetryTemp>180)=AsymmetryTemp(AsymmetryTemp>180)-360;
    AsymmetryMetricT=sqrt(mean(AsymmetryTemp.^2,'omitnan'));
    if AsymmetryMetricT<AsymmetryMetric
        AsymmetryMetric=AsymmetryMetricT;
    end
end
AsymmetryMetric

% Update the Reference File

% Create an Output file
SavedArray = [WhiskerShape, v, Trial, Date, Column, MagneticError, vError,RMSETheta, AsymmetryMetric,BestRoll];
writematrix([circshift(CombinedCurveX,BestRoll),circshift(CombinedCurveY,BestRoll)],WhiskerShape+'FCurve.csv') 
writematrix(circshift(SensorSummary,BestRoll,1), WhiskerShape+'Data.csv')
writematrix(SavedArray,WhiskerShape+'Info.csv')
writematrix(p,WhiskerShape+'Calibration.csv')


% New output file
% Save a file which has all of the temporal data rolled
shortestColumn=min(size(Sensor1,1),size(Sensor2,1),size(Sensor3,1),size(Sensor4,1),size(Sensor5,1))
Table=table(rem(Sensor1(1:shortestColumn,1)+MotorAngles(BestRoll),360),...
    Sensor1(1:shortestColumn,Column(1)),Sensor1(1:shortestColumn,Column(1)+1),...
    Sensor2(1:shortestColumn,Column(2)),Sensor2(1:shortestColumn,Column(2)+1),...
    Sensor3(1:shortestColumn,Column(3)),Sensor3(1:shortestColumn,Column(3)+1),...
    Sensor4(1:shortestColumn,Column(4)),Sensor4(1:shortestColumn,Column(4)+1),...
    Sensor5(1:shortestColumn,Column(5)),Sensor5(1:shortestColumn,Column(5)+1),'VariableNames', {'MotorAngles', 'Bu1', 'Bw1', 'Bu2', 'Bw2','Bu3', 'Bw3', 'Bu4', 'Bw4','Bu5', 'Bw5'});
writetable(Table,WhiskerShape+'RawData.csv')