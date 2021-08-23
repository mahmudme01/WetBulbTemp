clear all
tic

myFolder = 'C:\Users\Rony\Downloads\COVID_WET_BULB-20201127T011322Z-001\COVID_WET_BULB\c_10nv20';
fid=fopen('countylist3.txt');
data=textscan(fid,'%d %s %s %s %s %f %f %s %s %f %d','delimiter',',','HeaderLines',1);
Station_ID1=data{2};
WBAN1=data{4};
Station_ID2=data{3};
WBAN2=data{5};
fclose(fid);

%myFolder = 'C:\Users\Rony\Downloads\COVID_WET_BULB-20201127T011322Z-001\COVID_WET_BULB\weather_data\Opened_2';
for(jj=1:1:size(Station_ID1,1))
    
    if (str2double(Station_ID1(jj))==999999)
        Station=WBAN1(jj);
        F = sprintf('*-%s-*.txt',char(Station));
    else
        Station=Station_ID1(jj);
        F = sprintf('*%s*.txt',char(Station));
    end

    %F = sprintf('*%s*.txt',char(Station));
    S = dir(fullfile(myFolder,F));
    
    
    while(~isempty(S))
        N = S.name;
        copyfile( N, 'C:\Users\Rony\Downloads\COVID_WET_BULB-20201127T011322Z-001\COVID_WET_BULB\test')
        S=[];
    end
 
end

clear Station F S N

for(jj=1:1:size(Station_ID2,1))

    Date_ref=20200419; %YYYYMMDD
    
    if (str2double(Station_ID2(jj))==999999)
        Station=WBAN2(jj);
        F = sprintf('*-%s-*.txt',char(Station));
    else
        Station=Station_ID2(jj);
        F = sprintf('*%s*.txt',char(Station));
    end

    %F = sprintf('*%s*.txt',char(Station));
    S = dir(fullfile(myFolder,F));
    
    
    while(~isempty(S))
        N = S.name;
        copyfile( N, 'C:\Users\Rony\Downloads\COVID_WET_BULB-20201127T011322Z-001\COVID_WET_BULB\test')
        S=[];
    end
 
end
toc

