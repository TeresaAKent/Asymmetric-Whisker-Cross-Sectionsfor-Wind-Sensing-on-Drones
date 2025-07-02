RawData = readtable('Data31.csv');
RawData2 = table2array(RawData);

DataNormalized=RawData2(:,2:5)-median(RawData2(1:12,2:5));

DataFiltered= KernealWOOutliers(DataNormalized);
DataFiltered2= KernealWOOutliers(DataFiltered);

Time = RawData2(:,1)/1000;
Strengths = sqrt(DataFiltered2(:,1:2:end).^2+DataFiltered2(:,2:2:end).^2);
Directions = atan2(DataFiltered2(:,2:2:end),DataFiltered2(:,1:2:end));

figure()
plot(Time(1:end-30),Strengths)
% 
Binary1=Strengths(:,1)>1.5;
Binary2=Strengths(:,2)>1.5;

figure()
for j =1:size(Directions,1)
    if Binary1(j)==1 && Binary2(j)==1
        scatter(Time(j),Directions(j,1)*180/3.14159+120,10,[1,0.5,0],'filled')
        scatter(Time(j),Directions(j,2)*180/3.14159,10,'b','filled')
        % scatter(Time(j),Directions(j,1)*180/3.14159+120,10,[0.5,0.5,0.5],'filled')
        hold on
    end
end

xlim([16,17.4])
xlabel("Time [s]")
ylabel("Sensed Direction")
box on


function Filtered = KernealWOOutliers(Data)
    for i = 1:size(Data,1)-15
        Filtered(i,:) = mean(rmoutliers(Data(i:i+15,:)),1);
    end


end
