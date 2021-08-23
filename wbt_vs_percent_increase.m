clear all
tic

DateInput=20201015; %YYYYMMDD
DateInput2=datetime(DateInput,'ConvertFrom','yyyymmdd');
  
Case_threshold=5; %select suitable cumulative cases below which county will be deleted


%% Find %increase from previous week (written by Ahmed)
   % Observation Starting
NextObservation=9;                % Observation Starting er Kotodin Por: if you put 7, that is 7 days later
ThirdObservation=18;              % Observation Starting er Kotodin Por: if you put 7, that is 14 days later

% 2) if you want to find any specific County, provide County Name and
%    State Name here

CountyNameInput='Montgomery';
StateNameInput='Alabama';

% -------------------------------------------------------------------------
% *************************************************************************
% -------------------------------------------------------------------------

fid=fopen('us-counties.txt'); %save the file from the following site, delete the header and save it as us-counties.txt
  %https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv

NYCA=textscan(fid,'%s %s %s %f %f %f','delimiter',',');
fclose(fid);
ny1=NYCA{1}; % date
ny2=NYCA{2}; % county
ny3=NYCA{3}; % state
ny4=NYCA{4}; % fips
ny5=NYCA{5}; % cases
ny6=NYCA{6}; % deaths

% Date for FIPS Record
ny1date = datetime(ny1);
ny1date_2 = datenum(ny1date);

NYmatrix1 = table(ny4,ny1date_2,ny2,ny3,ny5,ny6,'VariableNames',{'FIPS' 'Date1' 'County' 'State' 'Cases' 'Deaths'});

[U, I] = unique(ny4, 'first');
x = 1:length(ny4);
x(I) = [];
ny4(x)=[];
ny4(isnan(ny4))=[]; %county identifier- fips

%writetable(NYmatrix1,'1NYTIMESCASES.csv','Delimiter',',','QuoteStrings',false)
%ny_a2=datenum("22-Jun-2020");
%******************************************************************************************
for i=1:1:1
DateInput1=datenum(DateInput2);
LookupDate=DateInput1; % find cumulative cases upto this point
%disp(LookupDate);

ny_a2=LookupDate; % must pick this other wise everything will be very messy

%******************************       FIRST WEEK     *************************************
VFIPSy1 = NYmatrix1(NYmatrix1{:,2} == ny_a2,:);
%******************************       SECOND WEEK     *************************************
ny_a3=ny_a2+NextObservation;
VFIPSy2 = NYmatrix1(NYmatrix1{:,2} == ny_a3,:);
%******************************       THIRD WEEK     *************************************
ny_a4=ny_a2+ThirdObservation;
VFIPSy3 = NYmatrix1(NYmatrix1{:,2} == ny_a4,:);
%******************************************************************************************
Tjoin2=outerjoin(VFIPSy1,VFIPSy2,'Keys','FIPS');
Tjoin2VariableUpdate=table(Tjoin2{:,1},Tjoin2{:,3},Tjoin2{:,4},Tjoin2{:,2},Tjoin2{:,5},Tjoin2{:,6},...
                           Tjoin2{:,8},Tjoin2{:,11},Tjoin2{:,12},...
     'VariableNames',{'FIPS' 'County' 'State' 'DATE_1' 'CASE_1' 'DEATHS_1' 'DATE_2' 'CASE_2' 'DEATHS_2' });
Tjoin2VariableUpdate(any(ismissing(Tjoin2VariableUpdate),2), :) = [];
%-------------------------------------------------------------------------------------------
Tjoin3=outerjoin(Tjoin2VariableUpdate,VFIPSy3,'Keys','FIPS');
Tjoin2VariableUpdate3=table(Tjoin3{:,1},Tjoin3{:,2},Tjoin3{:,3},Tjoin3{:,4},Tjoin3{:,5},Tjoin3{:,6},...
                           Tjoin3{:,7},Tjoin3{:,8},Tjoin3{:,9},...
                           Tjoin3{:,11},Tjoin3{:,14},Tjoin3{:,15},...
     'VariableNames',{'FIPS' 'County' 'State' 'DATE_1' 'CASE_1' 'DEATHS_1' 'DATE_2' 'CASE_2' 'DEATHS_2' 'DATE_3' 'CASE_3' 'DEATHS_3' });
Tjoin2VariableUpdate3(any(ismissing(Tjoin2VariableUpdate3),2), :) = [];


TabVar16=((Tjoin2VariableUpdate3{:,8}-Tjoin2VariableUpdate3{:,5})./(Tjoin2VariableUpdate3{:,5}))*100;
TabVar17=((Tjoin2VariableUpdate3{:,11}-Tjoin2VariableUpdate3{:,8})./(Tjoin2VariableUpdate3{:,8}))*100;
TabVar18=100*(((Tjoin2VariableUpdate3{:,11}-Tjoin2VariableUpdate3{:,8})-(Tjoin2VariableUpdate3{:,8}-Tjoin2VariableUpdate3{:,5}))./((Tjoin2VariableUpdate3{:,8}-Tjoin2VariableUpdate3{:,5})));
TabVar18b=(Tjoin2VariableUpdate3{:,11}-Tjoin2VariableUpdate3{:,8});

ConstructTableOUTPUT=table(Tjoin2VariableUpdate3{:,1},Tjoin2VariableUpdate3{:,2},...
                           Tjoin2VariableUpdate3{:,3},TabVar18,Tjoin2VariableUpdate3{:,11}-Tjoin2VariableUpdate3{:,8},...
                            'VariableNames',{'FIPS' 'County' 'State' 'INCREASE %' 'Cases of Week3'}) ;
MaxMinCasesIncrease=sortrows(ConstructTableOUTPUT,4,'descend');

%writetable(ConstructTableOUTPUT,'FIPSObservation.csv','Delimiter',',')

% mmm=find((Tjoin2VariableUpdate3{:,8}-Tjoin2VariableUpdate3{:,5})<Case_threshold); %dicard cases less than threshold
% TabVar18(mmm)=0;
% TabVar18b(mmm)=0;

for(ii=1:1:size(ny4,1))
    mm=find(Tjoin2VariableUpdate3{:,1}==ny4(ii));
        if isempty(mm)
        %Increase_C(i,ii)=0;
        Increase_Cb(i,ii)=0;
        Cases_prev_week_C(i,ii)=0;
        else
        %Increase_C(i,ii)=TabVar18(mm);
        Increase_Cb(i,ii)=TabVar18b(mm);
        Cases_prev_week_C(i,ii)=Tjoin2VariableUpdate3{mm,8}-Tjoin2VariableUpdate3{mm,5};
        end
end
clear ii mm
%Increase_C(i,:)=TabVar18;
%aa(i)=size(TabVar18,1);

% mmm=find((Tjoin2VariableUpdate3{:,11}-Tjoin2VariableUpdate3{:,8})>Case_threshold); 
% FIPS_C=Tjoin2VariableUpdate3{mmm,1};
% County_C=Tjoin2VariableUpdate3{mmm,2};
% State_C=Tjoin2VariableUpdate3{mmm,3};
% Increase_C=TabVar18(mmm);
% Cases_C=Tjoin2VariableUpdate3{mmm,11}-Tjoin2VariableUpdate3{mmm,8};

DateInput2=DateInput2+1;
clear mmm ans ConstructTableOUTPUT fid LookupDate MaxMinCasesIncrease ny_a2 ny_a3 ny_a4 
clear TabVar16 TabVar17 Tjoin2 Tjoin2VariableUpdate
clear Tjoin2VariableUpdate3 Tjoin3 VFIPSy1 VFIPSy2 VFIPSy3  
end

for ii=1:1:size(Increase_Cb(1,:),2)
%max_index=find(Increase_C(:,ii)==max(Increase_C(:,ii))); %change to max or min
max_increase(ii)=min(Increase_Cb(:,ii)); %change to max or min
%max_increase(ii)=min(Increase_Cb(max_index:end,ii)); %change to max or min
%mm=find(Increase_Cb(:,ii)==min(Increase_Cb(max_index:end,ii))); %change to max or min
mm=find(Increase_Cb(:,ii)==min(Increase_Cb(:,ii))); %change to max or min
Increase_date(ii)=datetime(DateInput,'ConvertFrom','yyyymmdd')+mm(1)-1;
Cases_prev_week(ii)=Cases_prev_week_C(mm(1),ii);
end
max_increase=max_increase';
Increase_date=Increase_date';
Cases_prev_week=Cases_prev_week';
pp=find(max_increase==0);
ny4(pp)=[];
Increase_date(pp)=[];
max_increase(pp)=[];
Cases_prev_week(pp)=[];
FIPS_C=ny4;

clear ii mm pp
%% Find weather data

myFolder = 'C:\Users\Rony\Downloads\COVID_WET_BULB-20201127T011322Z-001\COVID_WET_BULB\c_10nv20';
fid=fopen('countylist3.txt');
data=textscan(fid,'%d %s %s %s %s %f %f %s %s %f %d','delimiter',',','HeaderLines',1);
fips_W=data{1};
Station_ID(:,1)=data{2};
Station_ID(:,2)=data{3};
WBAN(:,1)=data{4};
WBAN(:,2)=data{5};
County_W=data{8};
State_W=data{9};
pop_density_W=data{10};
population_W=data{11};
fclose(fid);

 b=1;
 s=1;
%myFolder = 'C:\Users\Rony\Downloads\COVID_WET_BULB-20201127T011322Z-001\COVID_WET_BULB\c_10nv20\weather_data';
for(jj=1:1:size(FIPS_C,1))
    DP=[];
    %Date_ref=yyyymmdd(Increase_date(jj));
    mm=find(fips_W==FIPS_C(jj));
    if isempty(mm)
        continue
    end
    County(jj)=County_W(mm);
    State(jj)=State_W(mm);
    pop_density(jj)=pop_density_W(mm);
    population(jj)=population_W(mm);
 
    fid=-1;
    for aa=1:1:2
        Date_ref=yyyymmdd(Increase_date(jj));
        if (str2double(Station_ID(mm,aa))==999999)
            Station=WBAN(mm,aa);
            F = sprintf('*-%s-*.txt',char(Station));
        else
            Station=Station_ID(mm,aa)
            F = sprintf('*%s*.txt',char(Station));
        end

        S = dir(fullfile(myFolder,F));
   
    while(~isempty(S))
        N = S.name;
        fid = fopen(N) %use the appropriate file name
        tline = fgetl(fid);
        jj
        aa
        i=1;
        while ischar(tline)
%     
            %read Date 
            Date0 = extractAfter(tline,15);
            Date1= extractBefore(Date0,9);
            Date(i)=str2num(Date1);
            clear Date0 Date1
    
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
            
            tline = fgetl(fid);
            i=i+1;
       end
    %discard non-recorded temp data 
    m=find(Temp>100);
    Temp(m)=[];
    Tflag(m)=[];
    DPflag(m)=[];
    Date(m)=[];
    %Stn(m)=[];
    DP(m)=[];
    clear m
    %discard unreliable (flagged) temp data
    m=find(Tflag~=5&Tflag~=1);
    Temp(m)=[];
    DPflag(m)=[];
    Date(m)=[];
    %Stn(m)=[];
    DP(m)=[];
    clear m Tflag
    %discard non-recorded dew point data 
    m=find(DP>100);
    Temp(m)=[];
    DPflag(m)=[];
    Date(m)=[];
    %Stn(m)=[];
    DP(m)=[];
    clear m 
    %discard unreliable (flagged) dew point data
    m=find(DPflag~=5&DPflag~=1);
    Temp(m)=[];
    Date(m)=[];
    %Stn(m)=[];
    DP(m)=[];
    fclose(fid);
    
    clear m i tline ans Stn DPflag N
    
    if(size(DP,2)<8000)
        Date_ref=[]
        FIPS_discard(jj)=FIPS_C(jj)
        DP_discard(jj)=size(DP,2)
        clear Temp Date DP 
        break;
    end
    
    n=find(Date==Date_ref,1);
    if isempty(n)
        clear Temp Date DP 
        break;
    end

    %% Calculate average wet bulb temp
    TempIN=21;

    %find wet bulb temp outdoor
    e=6.11*10.^(7.5.*DP./(237.3+DP)); %Vapor pressure
    es=6.11*10.^(7.5.*Temp./(237.3+Temp)); %saturated vapor pressure
    rh=100.*e./es;

    TwOut=Temp.*atan(0.151977.*(rh + 8.313659).^(1/2)) + atan(Temp+rh)-...
        atan(rh-1.676331)+0.00391838.*(rh).^(3/2).*atan(0.023101.*rh)-4.686035;

    %find wet bulb temp indoor assuming absolute humidity do not change
    AH= 1323.9*10.^(7.5.*DP./(DP+243.5))./(273.15+Temp);
    rhIN=AH.*(273.15+TempIN)./(6.112*exp((17.67*TempIN)/(TempIN+243.5))*2.1674);
    %es_in=6.11*10^(7.5*TempIN/(237.3+TempIN));
    %DPIN=237.3.*log(es_in.*rhIN/611)./(7.5*log(10)-log(es_in.*rhIN/611));
    
    %scale_factor=1./(0.0129.*TwOut+0.827); %from collecting data
    scale_factor=1; %from collecting data
    %sss=find(scale_factor<1);
    TwIN=scale_factor.*(TempIN.*atan(0.151977.*(rhIN + 8.313659).^(1/2)) + atan(TempIN+rhIN)-...
        atan(rhIN-1.676331)+0.00391838.*(rhIN).^(3/2).*atan(0.023101.*rhIN)-4.686035);
    
    %TwIN(sss)=TempIN.*atan(0.151977.*(rhIN(sss) + 8.313659).^(1/2)) + atan(TempIN+rhIN(sss))-...
    %    atan(rhIN(sss)-1.676331)+0.00391838.*(rhIN(sss)).^(3/2).*atan(0.023101.*rhIN(sss))-4.686035;
    
    clear scale_factor sss

    %% now write code for averaging by the day & get standard deviation. 

    j=n;
        avg_days=1;
        max_TwINT=0;
        min_TwINT=0;
        max_TwOutT=0;
        min_TwOutT=0;
        max_TempT=0;
        min_TempT=0;
        max_rhT=0;
        min_rhT=0;
        while(avg_days<10) %9 days average
            cc=1;
            while(Date_ref==Date(n))
                mm_TwIN(cc)=TwIN(n);
                mm_TwOut(cc)=TwOut(n);
                mm_Temp(cc)=Temp(n);
                mm_rh(cc)=rh(n);
                n=n+1;
                cc=cc+1;
                if n>size(Date,2)
                    break;
                end
            end
            if n>size(Date,2)
                ss(s)=Station;
                s=s+1;
                break;
            end
        Date_ref=Date(n);
        avg_days=avg_days+1;
        max_TwINT=max_TwINT+max(mm_TwIN);
        min_TwINT=min_TwINT+min(mm_TwIN);
        max_TwOutT=max_TwOutT+max(mm_TwOut);
        min_TwOutT=min_TwOutT+min(mm_TwOut);
        max_TempT=max_TempT+max(mm_Temp);
        min_TempT=min_TempT+min(mm_Temp);
        max_rhT=max_rhT+max(mm_rh);
        min_rhT=min_rhT+min(mm_rh);
        clear mm_TwIN mm_TwOut mm_Temp mm_rh
        end 
        
        size(Temp(j:n-1))
        max_TwINM(jj)=max_TwINT/9;              %devide by the avg date
        min_TwINM(jj)=min_TwINT/9;              %devide by the avg date
        max_TwOutM(jj)=max_TwOutT/9;              
        min_TwOutM(jj)=min_TwOutT/9;              
        max_TempM(jj)=max_TempT/9;              
        min_TempM(jj)=min_TempT/9;
        max_rhM(jj)=max_rhT/9;              
        min_rhM(jj)=min_rhT/9;
        
        TempM(jj)=mean(Temp(j:n-1));
        TempS(jj)=std(Temp(j:n-1));
        TwINM(jj)=mean(TwIN(j:n-1));
        TwINS(jj)=std(TwIN(j:n-1));
        TwOutM(jj)=mean(TwOut(j:n-1));
        TwOutS(jj)=std(TwOut(j:n-1));
        rhM(jj)=mean(rh(j:n-1));
        rhS(jj)=std(rh(j:n-1));
        %DPM(jj)=mean(DP(j:n-1));
        
        %count(jj)=size(Temp(j:n-1),2)/9;

    %unreliabel_days(jj)=find(count(jj)<140);

        S=[];  
    end
    
        if fid == -1 | isempty(Date_ref)
            S=[];
            continue
        else
            break;
        end
    end

clear Temp Date DP e es rh TwOut TwIN AH rhIN es_in DPIN n j k nn 
end
toc

%read successful values
mmm=find(TempM);

max_TwINM_f=max_TwINM(mmm)';
min_TwINM_f=min_TwINM(mmm)';
max_TwOutM_f=max_TwOutM(mmm)';
min_TwOutM_f=min_TwOutM(mmm)';
max_TempM_f=max_TempM(mmm)';
min_TempM_f=min_TempM(mmm)';
max_rhM_f=max_rhM(mmm)';
min_rhM_f=min_rhM(mmm)';

TempM_f=TempM(mmm)';
TempS_f=TempS(mmm)';
TwINM_f=TwINM(mmm)';
TwINS_f=TwINS(mmm)';
TwOutM_f=TwOutM(mmm)';
TwOutS_f=TwOutS(mmm)';
rhM_f=rhM(mmm)';
rhS_f=rhS(mmm)';
pop_density_f=pop_density(mmm)';
population_f=population(mmm)';
County_f=County(mmm)';
State_f=State(mmm)';

FIPS_f=FIPS_C(mmm);
Increase_date_f=Increase_date(mmm);
max_increase_f=max_increase(mmm);
Cases_prev_week_f=Cases_prev_week(mmm);

% County_NAN2=County( );
% State_NAN2=County(find(~State));

clear kk k ii mmm

mm=find(isnan(TempM_f));

max_TwINM_f(mm)=[];
min_TwINM_f(mm)=[];
max_TwOutM_f(mm)=[];
min_TwOutM_f(mm)=[];
max_TempM_f(mm)=[];
min_TempM_f(mm)=[];
max_rhM_f(mm)=[];
min_rhM_f(mm)=[];

TempM_f(mm)=[];
TempS_f(mm)=[];
TwINM_f(mm)=[];
TwINS_f(mm)=[];
TwOutM_f(mm)=[];
TwOutS_f(mm)=[];
rhM_f(mm)=[];
rhS_f(mm)=[];
pop_density_f(mm)=[];
population_f(mm)=[];
County_f(mm)=[];
State_f(mm)=[];

FIPS_f(mm)=[];
Increase_date_f(mm)=[];
max_increase_f(mm)=[];
Cases_prev_week_f(mm)=[];

data_f=table(FIPS_f,County_f,State_f,Increase_date_f,max_increase_f,TwINM_f,TwINS_f,max_TwINM_f,min_TwINM_f,TwOutM_f,TwOutS_f,max_TwOutM_f,min_TwOutM_f,...
    TempM_f,TempS_f,max_TempM_f,min_TempM_f,rhM_f,rhS_f,max_rhM_f,min_rhM_f,Cases_prev_week_f,pop_density_f,population_f);

%clearvars -except data_f
