
clear all

fid=fopen('FIPDEMOLONGLAT.csv');
C_data=textscan(fid,'%d %s %s %d %f %f %f','delimiter',',','HeaderLines',1);
fclose(fid);
state=C_data{3}; % state
county=C_data{2}; % county
fips=C_data{1}; % FIPS
pop=C_data{4}; % population
pop_density=C_data{5}; % population density
Lon_County=C_data{6}; % longitude for the county
Lat_County=C_data{7}; % latitude for the county

fid=fopen('weather_station2.csv');
W_data=textscan(fid,'%s %s %s %f %f','delimiter',',','HeaderLines',1);
fclose(fid);
Station_ID=W_data{1}; 
WBAN=W_data{2}; 
Station_Name=W_data{3}; 
Lat_WS=W_data{4}; % latitude for weather station
Lon_WS=W_data{5}; % longitude for weather station

Lat_WS(isnan(Lat_WS))=0; %convert any NAN to zero
Lon_WS(isnan(Lon_WS))=0;

%fond distance between county & weather station
%https://stackoverflow.com/questions/27928/calculate-distance-between-two-latitude-longitude-points-haversine-formula#:~:text=from%20math%20import%20cos%2C%20asin,*R*asin...
x=1;
for(i=1:1:size(county,1))
    k=1;
%     dist1(1)=0;
%     index_WS(1)=0;
    for(j=1:1:size(Lat_WS,1))
a = 0.5-cos((Lat_WS(j)-Lat_County(i))*(pi/180))/2 + ...
     cos(Lat_WS(j)*(pi/180)) * cos(Lat_County(i)*(pi/180)) * ...
     (1-cos((Lon_County(i)-Lon_WS(j))*(pi/180)))/2;

b=7917.5*asin(sqrt(a)); %b represents doistance in miles
if (b<100)
    dist1(k)=b;
    index_WS(k)=j;
    k=k+1;
    M=1;
end
    end
    if (M==1)
        dist2=sort(dist1);
        dist1=dist1';
        dist2=dist2';
            Station_C(i,1)=Station_ID(index_WS(find(dist1==dist2(1),1)));
            WBAN_C(i,1)=WBAN(index_WS(find(dist1==dist2(1),1)));
            dist_f(i,1)=dist2(1);
            
            for yy=1:1:10
            Station_C(i,2)=Station_ID(index_WS(find(dist1==dist2(yy),1)));
            WBAN_C(i,2)=WBAN(index_WS(find(dist1==dist2(yy),1)));
            dist_f(i,2)=dist2(yy);
            if dist_f(i,1)==dist_f(i,2)
                continue;
            else
                break;
            end
        end
    else
        Station_C(i,:)={'None'};
        WBAN_C(i,:)={'None'};
        mm(x)=i;
        x=x+1;
    end
    M=0;
    clear dist1 dist2 index_WS 
end

Station_C=Station_C';
WBAN_C=WBAN_C';
fips(mm)=[];
Station_C(mm,:)=[];
WBAN_C(mm,:)=[]; 
county(mm)=[];
state(mm)=[];
pop_density(mm)=[];
pop(mm)=[];
dist_f(mm,:)=[];

clear mm

%discard duplicate data
[U, I] = unique(fips, 'first');
x = 1:length(fips);
x(I) = [];
fips(x)=[];
Station_C(x,:)=[];
WBAN_C(x,:)=[]; 
county(x)=[];
state(x)=[];
pop_density(x)=[];
pop(x)=[];
dist_f(x,:)=[];

newdata=table(fips, Station_C(:,1), Station_C(:,2), WBAN_C(:,1), WBAN_C(:,2), county, state, pop_density, pop);
writetable(newdata,'countylist3.txt');
