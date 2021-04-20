%% This code is to calculate indoor and outdoor wet bulb temp from NOAA weather data
% Indoor wet bulb temp was calculated considering US living condition on
% socially distanced model. Please read the method section in the following
% article: https://www.researchgate.net/publication/349119706_Critical_wet_bulb_temperature_modulates_COVID-19_cases

% While outdoor wet bulb temperature is accurate (approximate at high precision), indoor wet bulb temp is
% interpolated from outdoor weather condition (temperature and dew point temperature). This interpolation may not work for other countries due to
% differences in living condition. This interpolation is also erroneous
% during summer due to cooling effect caused by indoor AC.

% Weather data needs to be downloaded from here: ftp://ftp.ncdc.noaa.gov/pub/data/noaa/2021/
% Weather station information can be found here: ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.txt

% Code formulation and writing: Md Mahmudur Rahman and Ahmed Islam,
% University of Louisville, USA.

% for contact: email:  mrahman@udel.edu , twitter: @mahmudme01 [please let me know if you find any error]

% indoor temp is considered as 21C

%%
clc
clear all


filenamehourly='419220-99999-2020_tejgaon_Dhaka2.txt';
TempIN=21; % A fixed indoor temp


% % Read data and discard garbage values. Store them in respective format
fid = fopen(filenamehourly); %use the appropriate file name
tline = fgetl(fid);
i=1;
while ischar(tline)
    %read station number
    Stn0 = extractAfter(tline,4);
    Stn1= extractBefore(Stn0,7);
    Stn(i)=str2num(Stn1);
    clear Stn0 Stn1
    
    %read Date 
    Date0 = extractAfter(tline,15);
    Date1= extractBefore(Date0,9);
    Date(i)=str2num(Date1);
    clear Date0 Date1
    
    %read time 
    Time0 = extractAfter(tline,23);
    Time1= extractBefore(Time0,5);
    Time(i)=str2num(Time1);
    clear Time0 Time1
    
    %read Temp 
    Temp0 = extractAfter(tline,87);
    Temp1= extractBefore(Temp0,6);
    Temp(i)=str2num(Temp1)/10;
    clear Temp0 Temp1
    
    %read Temp flag 
    Tflag0 = extractAfter(tline,92);
    Tflag1= extractBefore(Tflag0,2);
        if (str2num(Tflag1))
        Tflag(i)=str2num(Tflag1);
        else
        Tflag(i)=0;
        end
    clear Tflag0 Tflag1
    
    
    %read Dew point 
    DP0 = extractAfter(tline,93);
    DP1= extractBefore(DP0,6);
    DP(i)=str2num(DP1)/10;
    clear DP0 DP1
    
    %read Dew point flag
    DPflag0 = extractAfter(tline,98);
    DPflag1= extractBefore(DPflag0,2);
        if (str2num(DPflag1))
        DPflag(i)=str2num(DPflag1);
        else
        DPflag(i)=0;
        end
    clear DPflag0 DPflag1
    
    %read Pressure 
    Pr0 = extractAfter(tline,99);
    Pr1= extractBefore(Pr0,6);
    Pr(i)=str2num(Pr1)/10000;
    clear Pr0 Pr1
   
    tline = fgetl(fid);
    i=i+1;
end
%discard non-recorded temp data 
m=find(Temp>100);
Temp(m)=[];
Tflag(m)=[];
DPflag(m)=[];
Date(m)=[];
Time(m)=[];
Stn(m)=[];
DP(m)=[];
Pr(m)=[];
clear m
%discard unreliable (flagged) temp data
m=find(Tflag~=5&Tflag~=1);
Temp(m)=[];
DPflag(m)=[];
Date(m)=[];
Time(m)=[];
Stn(m)=[];
DP(m)=[];
Pr(m)=[];
clear m
%discard non-recorded dew point data 
m=find(DP>100);
Temp(m)=[];
DPflag(m)=[];
Date(m)=[];
Time(m)=[];
Stn(m)=[];
DP(m)=[];
Pr(m)=[];
clear m
%discard unreliable (flagged) dew point data
m=find(DPflag~=5&DPflag~=1);
Temp(m)=[];
Date(m)=[];
Time(m)=[];
Stn(m)=[];
DP(m)=[];
Pr(m)=[];
fclose(fid);
clear m i fid tline ans

% ttt=find(Time<=abs(100*timezone(tt))|Time>=abs(100*timezone(tt))+800);
%     Temp(ttt)=[];
%     Time(ttt)=[];
%     Date(ttt)=[];
%     %Stn(m)=[];
%     DP(ttt)=[];

Date2=datetime(Date,'ConvertFrom','yyyymmdd');
Temp_A=Temp.'; % Transposing Average Temperature
Date_A=Date2.'; % Transposing Date
DP_A=DP.'; % Transposing Dew Point Temperature

% % Calculate wet bulb temp

%find wet bulb temp outdoor
e=6.11*10.^(7.5.*DP_A./(237.3+DP_A)); %Vapor pressure
es=6.11*10.^(7.5.*Temp_A./(237.3+Temp_A)); %saturated vapor pressure
rh=100.*e./es;
TwOut=Temp_A.*atan(0.151977.*(rh+ 8.313659).^(1/2))+atan(Temp_A+rh)...
    -atan(rh-1.676331)+0.00391838.*(rh).^(3/2).*atan(0.023101.*rh)-4.686035;

%find wet bulb temp indoor assuming absolute humidity do not change

AH_R= 1323.9*10.^(7.5.*DP_A./(DP_A+243.5))./(273.15+Temp_A);
rhIN_A=AH_R.*(273.15+TempIN)./(6.112*exp((17.67*TempIN)/(TempIN+243.5))*2.1674);

es_in=6.11*10^(7.5*TempIN/(237.3+TempIN));

DPIN_A=237.3.*log(es_in.*rhIN_A/611)./(7.5*log(10)-log(es_in.*rhIN_A/611));

%considering correction factor. For details see method section in the
%aforementioned article

scale_factor=1./(0.0129.*TwOut+0.827); 
%scale_factor=1; %when correction factor is not considered
    
    sss=find(scale_factor<1);
    
TwIN_A=scale_factor.*(TempIN.*atan(0.151977.*(rhIN_A+ 8.313659).^(1/2))+atan(TempIN+rhIN_A)...
    -atan(rhIN_A-1.676331)+0.00391838.*(rhIN_A).^(3/2).*atan(0.023101.*rhIN_A)-4.686035); % Indoor WBT

TwIN_A(sss)=TempIN.*atan(0.151977.*(rhIN_A(sss)+ 8.313659).^(1/2))+atan(TempIN+rhIN_A(sss))...
    -atan(rhIN_A(sss)-1.676331)+0.00391838.*(rhIN_A(sss)).^(3/2).*atan(0.023101.*rhIN_A(sss))-4.686035;

% --------------------------------------------------------------------------------------------------------------------

% % now write code for averaging by the day & get standard deviation.
n=1;
j=1;
k=1;
count=0;
while(n<=size(Temp,2)-1)
    Date_ref=Date(n);
    while(Date_ref==Date(n))
        if (n==size(Temp,2))
            break
        end
        n=n+1;
    end
    TempM(k)=mean(Temp(j:n-1));       % Temperature Mean 
    TempS(k)=std(Temp(j:n-1));        % Temperature Std Dev
    DPM(k)=mean(DP(j:n-1));           % Temperature Mean 
    DPS(k)=std(DP(j:n-1));            % Temperature Std Dev
    wHoutMean(k)=mean(TwOut(j:n-1));  % WetBulb Outside Mean
    wHoutstddev(k)=std(TwOut(j:n-1)); % WetBulb Outside Std Dev
    wHin2Mean(k)=mean(TwIN_A(j:n-1));  % WetBulb Inside Mean Rony Bhai Method
    wHin2stddev(k)=std(TwIN_A(j:n-1)); % WetBulb Inside Std Dev Rony Bhai Method
    rhM(k)=mean(rh(j:n-1));
    rhS(k)=std(rh(j:n-1));
    Dmean(k)=mean(Date_A(j:n-1));
    count(k)=size(Temp(j:n-1),2);
    k=k+1;
    j=n;
end
unreliabel_days=find(count<20);

Dmean2 = Dmean.';         % Transposing Date

%Outdoor
bubblechart(Dmean2,wHoutMean,wHoutstddev,'blue');
bubblesize([1 10]);
hold on
%plot(Dmean2,wHoutMean,'--','color',[0 0 1]);
%yyaxis left
ylabel('Wet Bulb Temperature, C')

%Outdoor all data
%  hold on
 plot(Date_A,TwOut,'|b');
 plot(Date_A,TwIN_A,'|r');


% hold on
% bubblechart(Dmean2,rhM,rhS,'blue');
% bubblesize([1 10]);
% %yyaxis right
% ylabel('relative humidity, %')
% plot(Date_A,rh,'|g');

% hold on
% bubblechart(Dmean2,TempM,TempS,'red');
% bubblesize([1 10]);
% %yyaxis right
% ylabel('Outdoor Temperature, C')

%Indoor
bubblechart(Dmean2,wHin2Mean,wHin2stddev,'red');
bubblesize([1 10]);
%plot(Dmean2,wHin2Mean,'--','color',[1 0 0]);
legend('Outdoor','','Indoor','','FontSize',12)
bubblesize([1 10]);

%plot(Dmean2,wHin2Mean,'--','color',[1 0 0]);

%title('Name as your suitable title')

bubblelegend('Standard deviation, C','Location','eastoutside')
