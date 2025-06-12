close all


% Open the first Example of the sensor
Sensor1a = readtable('NewTriangle2FCurve.csv');
Sensor1 = table2array(Sensor1a);
Experimenta1 = table2array(readtable('NewTriangle2Data.csv'));
MotorAngles=sort(Experimenta1(:,1));
DetailedSensor1X = Interpolate(MotorAngles,Sensor1(:,1));
DetailedSensor1Y = Interpolate(MotorAngles,Sensor1(:,2));
p = table2array(readtable('NewTriangle2Calibration.csv'));
f1 = polyval(p,linspace(0,5,1000));
Info = readtable('NewTriangle2Info.csv');
v=table2array(Info(1,2:6));
Multiplier=median(p(1).*v.^2+p(2).*v+p(3))/median(sqrt(DetailedSensor1Y.^2+DetailedSensor1X.^2));


%open the second instance of the sesnor
Sensor2a = readtable('NewTriangle1FCurve.csv');
Sensor2 = table2array(Sensor2a);
Experimenta2 = table2array(readtable('NewTriangle1Data.csv'));
DetailedSensor2X = Interpolate(MotorAngles,Sensor2(:,1));
DetailedSensor2Y = Interpolate(MotorAngles,Sensor2(:,2));
p2 = table2array(readtable('NewTriangle1Calibration.csv'));
f2 = polyval(p,linspace(0,5,1000));
Info = readtable('NewTriangle1Info.csv');
v2=table2array(Info(1,2:6));
Multiplier2=median(p2(1).*v2.^2+p2(2).*v2+p2(3))/median(sqrt(DetailedSensor2Y.^2+DetailedSensor2X.^2));

% Open sensor 3
Sensor3a = readtable('NewCross3FCurve.csv');
Sensor3 = table2array(Sensor3a);
Experimenta3 = table2array(readtable('NewCircle2Data.csv'));
DetailedSensor3X = Interpolate(MotorAngles,Sensor3(:,1));
DetailedSensor3Y = Interpolate(MotorAngles,Sensor3(:,2));
p3 = table2array(readtable('NewCircle2Calibration.csv'));
f3 = polyval(p3,linspace(0,5,1000));
Info = readtable('NewCircle1Info.csv');
v3=table2array(Info(1,2:6));


Strength1=sqrt(sum(Sensor1.^2,2));
Strength2=sqrt(sum(Sensor2.^2,2));
Strength3=sqrt(sum(Sensor3.^2,2));

Direction1=atan2d(Sensor1(:,2),Sensor1(:,1));
Direction1(Direction1-MotorAngles<-180)=Direction1(Direction1-MotorAngles<-180)+360;
% Direction1(22:end)=Direction1(22:end)+360;
%Direction1(32=Direction1(32:end)+90
%Direction1(84:end)=Direction1(84:end)+360;
% Direction1(76:end)=Direction1(76:end)+360;
%Direction1=circshift(Direction1,-1);
%Direction1(end)=Direction1(end)+360;

Direction2=atan2d(Sensor2(:,2),Sensor2(:,1));
Direction2(Direction2-MotorAngles<-180)=Direction2(Direction2-MotorAngles<-180)+360;
%Direction2(29:end)=Direction2(29:end)+360;
% Direction2(end-12:end)=Direction2(end-12:end)-360
% Direction2=Direction2+90;Direction1(76:end)=Direction1(76:end)+360
% Direction2(75:end)=Direction2(75:end)+360

%Direction2(62:end)=Direction2(62:end)+360;
%Direction2(75:82)=Direction2(75:82)-360;
%Direction2=circshift(Direction2,-1);
%Direction2(1:18)=Direction2(1:18)-360;

%Direction2(end)=Direction2(end)+360;

Direction3=atan2d(Sensor3(:,2),Sensor3(:,1));
Direction3(Direction3-MotorAngles<-180)=Direction3(Direction3-MotorAngles<-180)+360;
%Direction3(70:end)=Direction3(70:end)+360;
% Direction3=circshift(Direction3,52);
% Direction3(19:end)=Direction3(19:end)+360;
% Direction3=Direction3-90;
%Direction3=circshift(Direction3,1);
%Direction3(71:81)=Direction3(71:81)+360;
%Direction3(71:end)=Direction3(71:end)-360;
%Direction2(12:22)=Direction2(12:22)+360

%% Single Data Plot
figure()
subplot(2,1,1)
s=scatter(MotorAngles,Experimenta1(:,4),15,[0.8500 0.3250 0.0980],'filled')
xlim([0,360])
ylim([-50,50])
xlabel({"Flow Direction" '$\varphi$ [$^\circ]$'},'Interpreter','latex')
ylabel({"Magnetic Field Strength" "$B_u$ [mT]"},'Interpreter','latex')
box on
h1 = xline(60, 'cyan',"Sensor 1",'LineWidth',4 );
h2 = xline(120,'green',"Sensor 2",'LineWidth',4);
datatip(s,61.2,4.33789)
datatip(s,122.4,-14.6198)

subplot(2,1,2)
t=scatter(MotorAngles,Experimenta1(:,5),15,[0.8500 0.3250 0.0980],'filled')
xlim([0,360])
ylim([-50,50])
xlabel({"Flow Direction" '$\varphi$ [$^\circ]$'},'Interpreter','latex')
ylabel({"Magnetic Field Strength" "$B_v$ [mT]"},'Interpreter','latex')
h3 = xline(60, 'cyan',"Sensor 1", 'LineWidth',4);
h4 = xline(120, 'green',"Sensor 2",'LineWidth',4);
datatip(t,61.2,35.3578)
datatip(t,122.4,20.4014)
box on


%% Gif 1 Graph
h = figure;
set(gcf, 'color', 'white');
subplot(2,1,1)
plot(linspace(1,359,360), DetailedSensor1X,'k','LineWidth',2)
hold on
xlabel({"Flow Direction" '$\varphi$ [$^\circ]$'},'Interpreter','latex')
xlim([0,360])
ylim([-1.5,1.5])
ylabel({"Model Strength" "$\overrightarrow{F_u}$"},'Interpreter','latex')
h1 = xline(0, 'cyan',"Sensor 1",'LineWidth',4 );
h2 = xline(60,'green',"Sensor 2",'LineWidth',4);

subplot(2,1,2)
plot(linspace(1,359,360),DetailedSensor1Y,'k','LineWidth',2)
hold on 
xlabel({"Flow Direction" '$\varphi$ [$^\circ]$'},'Interpreter','latex')
xlim([0,360])
ylim([-1.5,1.5])
ylabel({"Model Strength" "$\overrightarrow{F_v}$"},'Interpreter','latex')
axis tight manual % this ensures that getframe() returns a consistent size
h3 = xline(0, 'cyan',"Sensor 1", 'LineWidth',4);
h4 = xline(60, 'green',"Sensor 2",'LineWidth',4);


filename = 'Frame1Algorithm.gif';
for n = 1:1:359
    set(gcf, 'color', 'white');
    h1.Value = n;
    h3.Value = n;

    secondVal = mod(n+60,360);
    h2.Value = secondVal;
    h4.Value = secondVal;
    drawnow
    % Capture the plot as an image
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    % Write to the GIF File
    if n == 1
        imwrite(imind,cm,filename,'gif', 'DelayTime', .1,'Loopcount',inf);
    else
        imwrite(imind,cm,filename,'gif','DelayTime', .1,'WriteMode','append');
    end
end

%% Gif 2 Bar Graph

% Pre process the data
% Roll data for sensor 2
RolledDetailX2=circshift(DetailedSensor1X,60,1);
RolledDetailY2=circshift(DetailedSensor1Y,60,1);
% Calculate the Signal Strength
Sensor1Strength=sqrt(DetailedSensor1X.^2+DetailedSensor1Y.^2);
Sensor2Strength = sqrt(RolledDetailX2.^2+RolledDetailY2.^2);
Strengths=max(Sensor1Strength,Sensor2Strength);
% Divide each sensor value
NormalizedModelArray=[DetailedSensor1X, DetailedSensor1Y,RolledDetailX2,RolledDetailY2]./Strengths;

h = figure;
axis tight manual % this ensures that getframe() returns a consistent size
filename = 'BarGraph.gif';
for n = 1:1:359
    set(gcf, 'color', 'white');
    % Draw plot for y = x.^n
    x = [NormalizedModelArray(n,1), NormalizedModelArray(n,2), NormalizedModelArray(n,3), NormalizedModelArray(n,4)];
    xUpdate = x;
    bar(xUpdate,'FaceColor','black')
    s = {'B_{u,1}', 'B_{v,1}', 'B_{u,2}', 'B_{v,2}'};
    xticklabels(s)
    ylabel("Signal Strength")
    ylim([-1,1])
    drawnow
    % Capture the plot as an image
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);

    % Write to the GIF File
    if n == 1
        imwrite(imind,cm,filename,'gif', 'DelayTime', .1,'Loopcount',inf);
    else
        imwrite(imind,cm,filename,'gif','DelayTime', .1,'WriteMode','append');
    end
end

%% Error Graph
figure()

Error=sum((NormalizedModelArray-[0.12, 1.00, -.41, 0.57]).^2,2);
plot(linspace(0,359,360),Error,'k','LineWidth',2)
xline(61.8,'r',"True Value",'LineWidth',4)
[~,I]=min(Error);
xline(I,'b',"Predicted Value",'LineWidth',4)
xlabel({"Flow Direction" '$\varphi$ [$^\circ]$'},'Interpreter','latex')
ylabel("Error")
xlim([0,359])

%% Gif 3 Rotating Triangles
g = figure;
axis tight manual % this ensures that getframe() returns a consistent size
filename = 'Triangle.gif';
for n = 1:1:359
    clf
    set(gcf, 'color', 'white');
    Angle = n
    polyin = polyshape([-0.666 .333 0.333],[0 .577 -.577]);
    poly1 = rotate(polyin,60,[0,0]);
    hold on
    polyin2 = polyshape([-3 -2 -2],[0 .577 -.577]);
    plot([polyin2 poly1],'FaceColor', [0.9290 0.6940 0.1250], 'FaceAlpha',1)
    hold on
    length = 0.5;
    X = [-2.5-cosd(Angle)-length*cosd(Angle) -2.5-cosd(Angle)];
    Y = [-sind(Angle)-length*sind(Angle)   -sind(Angle)];
    X2 = [-cosd(Angle)-length*cosd(Angle) -cosd(Angle)];
    Y2 = [-sind(Angle)-length*sind(Angle)   -sind(Angle)];
    % Arrow 2 centered on 0.5 0.5
    plot(X,Y,'Color',[0.0,1.0,1.0],'LineWidth',6)
    hold on
    plot(X2,Y2,'Color',[0,1.0,0],'LineWidth',6)
    hold on
    if rem(n,120)<15
        scatter(X(2),Y(2),150,'c>','filled') 
        hold on 
        scatter(X2(2),Y2(2),150,'g>','filled') 
        hold on 
    elseif rem(n,120)>105
        scatter(X(2),Y(2),150,'c>','filled') 
        hold on 
        scatter(X2(2),Y2(2),150,'g>','filled') 
        hold on 
    elseif rem(n,120)<45
        scatter(X(2),Y(2),150,'cv','filled') 
        hold on 
        scatter(X2(2),Y2(2),150,'gv','filled') 
        hold on 
    elseif rem(n,120)<75
        scatter(X(2),Y(2),150,'c<','filled') 
        hold on 
        scatter(X2(2),Y2(2),150,'g<','filled') 
        hold on 
    else
        scatter(X2(2),Y2(2),150,'g^','filled') 
        hold on 
        scatter(X(2),Y(2),150,'c^','filled') 
        hold on 
    end
    axis equal
    axis off
    xlim([-4.5,2.5])
    ylim([-3.5,1.5])

    % Arrow 1 centered on 2.5 0.5
    % Arrows should be sqrt2 off the box
    


    drawnow
    % Capture the plot as an image
    frame = getframe(g);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    if n == 1
        imwrite(imind,cm,filename,'gif', 'DelayTime', .1,'Loopcount',inf);
    else
        imwrite(imind,cm,filename,'gif','DelayTime', .1,'WriteMode','append');
    end
end



figure()
subplot(2,1,1)
scatter(MotorAngles,Experimenta1(:,2:2:end),15,'filled')
xlim([0,360])
ylim([-50,50])
xlabel({"Flow Direction" '$\varphi$ [$^\circ]$'},'Interpreter','latex')
ylabel({"Magnetic Field Strength" "$B_u$ [mT]"},'Interpreter','latex')
box on
subplot(2,1,2)
scatter(MotorAngles,Experimenta1(:,3:2:end),15,'filled')
xlim([0,360])
ylim([-50,50])
xlabel({"Flow Direction" '$\varphi$ [$^\circ]$'},'Interpreter','latex')
ylabel({"Magnetic Field Strength" "$B_v$ [mT]"},'Interpreter','latex')
box on
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