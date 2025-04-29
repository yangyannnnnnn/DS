%% Script for LAB test data Analysis
clear;
%% User Input for Test file location
[test_data, test_data_location] = uigetfile('.csv');

%% Save Data as .mat file in same directory and create data table variable
time_data = save_ccn_as_timetable(test_data_location,test_data);

% time_table_data = merge_table_times(data);
save_file_name = split(test_data,'.');


%% Pre-processing of Table

check_for_nan = isnan(time_data.oat_value);
time_data = time_data(~check_for_nan, :);

% %Check if operating_mode is all cooling -- rmv rows w/ cooling if found
% logicalIndex = time_data.operating_mode == 1;
% time_data.operating_mode(logicalIndex) = 0;

% Save final TimeTable
save([test_data_location '\' save_file_name{1} '.mat'],"time_data");

% Calulate simulated time in Seconds
SimTime = seconds(time_data.Time(1:end) - time_data.Time(1))+500; %add 500 seconds for initialization

%% Signal and Dataset Creation 

% Create a Simulink.SimulationData.Signal element for each event
Outdoor_Air_Temperature = Simulink.SimulationData.Signal;
Outdoor_Air_Temperature.Values = timeseries([time_data.oat_value(1); time_data.oat_value],[0; SimTime]);
Outdoor_Air_Temperature.Name = 'Outdoor_Air_Temperature';

Outdoor_Air_Humidity = Simulink.SimulationData.Signal;
Outdoor_Air_Humidity.Values = timeseries([.531 .531]',[0; SimTime(end,1)]);
Outdoor_Air_Humidity.Name = 'Outdoor_Air_Humidity';

Indoor_Air_Temperature = Simulink.SimulationData.Signal;
Indoor_Air_Temperature.Values = timeseries([70 70]',[0; SimTime(end,1)]);
Indoor_Air_Temperature.Name = 'Indoor_Air_Temperature';

Indoor_Air_Humidity = Simulink.SimulationData.Signal;
Indoor_Air_Humidity.Values = timeseries([.4 .4]',[0; SimTime(end,1)]);
Indoor_Air_Humidity.Name = 'Indoor_Air_Humidity';

Mode_Schedule = Simulink.SimulationData.Signal;
Mode_Schedule.Values = timeseries([0 0]',[0; SimTime(end,1)]);
Mode_Schedule.Name = 'Mode_Schedule';

Staging_Schedule = Simulink.SimulationData.Signal;
Staging_Schedule.Values = timeseries([time_data.odu_demand(1); time_data.odu_demand],[0; SimTime]);
Staging_Schedule.Name = 'Staging_Schedule';

Defrost_Schedule = Simulink.SimulationData.Signal;
Defrost_Schedule.Values = timeseries([0; time_data.reqForceDefro],[0; SimTime]);
Defrost_Schedule.Name = 'Defrost_Schedule';

initial_compressor_rpm_act = Simulink.SimulationData.Signal;
initial_compressor_rpm_act.Values = timeseries([900 900 900 900 900 900 900 900 2700]', [0 500 500 507 507 520 520 540 540]);
initial_compressor_rpm_act.Name = 'initial_compressor_rpm_act';

initial_oat = Simulink.SimulationData.Signal;
initial_oat.Values = timeseries([5 5 5 5 5 5 5 5 5]', [0 500 500 507 507 520 520 540 540]);
initial_oat.Name = 'initial_oat';

initial_outdoor_airflow_cfm = Simulink.SimulationData.Signal;
initial_outdoor_airflow_cfm.Values = timeseries([0 0 0 0 0 0 460 460 460]', [0 500 500 507 507 520 520 540 540]);
initial_outdoor_airflow_cfm.Name = 'initial_outdoor_airflow_cfm';

initial_indoor_airflow_cfm = Simulink.SimulationData.Signal;
initial_indoor_airflow_cfm.Values = timeseries([977 977 977 977 977 977 977 977 977]', [0 500 500 507 507 520 520 540 540]);
initial_indoor_airflow_cfm.Name = 'initial_indoor_airflow_cfm';

initial_exv_steps_act = Simulink.SimulationData.Signal;
initial_exv_steps_act.Values = timeseries([35 35 35 35 35 35 35 35 35]', [0 500 500 507 507 520 520 540 540]);
initial_exv_steps_act.Name = 'initial_exv_steps_act';

Comp_Min_Demand = Simulink.SimulationData.Signal;
Comp_Min_Demand.Values = timeseries([960 60 960]', [0 50 SimTime(end,1)]);
Comp_Min_Demand.Name = 'Comp_Min_Demand';

Comp_Max_Demand = Simulink.SimulationData.Signal;
Comp_Max_Demand.Values = timeseries([3660 3660 3660]', [0 50 SimTime(end,1)]);
Comp_Max_Demand.Name = 'Comp_Max_Demand';

Indoor_Airflow_Demand = Simulink.SimulationData.Signal;
Indoor_Airflow_Demand.Values = timeseries([time_data.solVal2Cmd(1); time_data.solVal2Cmd], [0; SimTime]);
Indoor_Airflow_Demand.Name = 'Indoor_Airflow_Demand';

ODF_Demand = Simulink.SimulationData.Signal;
ODF_Demand.Values = timeseries([0; 800],[0; SimTime(end,1)]);
ODF_Demand.Name = 'ODF_Demand';

% Add the element to the dataset
dataset = createDataset(Defrost_Schedule,Indoor_Air_Humidity,Indoor_Air_Temperature,...
    Mode_Schedule,Outdoor_Air_Humidity,Outdoor_Air_Temperature,Staging_Schedule,...
    initial_compressor_rpm_act,initial_exv_steps_act,initial_indoor_airflow_cfm,...
    initial_oat,initial_outdoor_airflow_cfm,Comp_Min_Demand,Comp_Max_Demand,...
    Indoor_Airflow_Demand,ODF_Demand);

clear Comp_Min_Demand Comp_Max_Demand Defrost_Schedule Indoor_Airflow_Demand ...
    Indoor_Air_Temperature Indoor_Air_Humidity initial_outdoor_airflow_cfm ...
    initial_oat initial_indoor_airflow_cfm initial_exv_steps_act initial_compressor_rpm_act ...
    Mode_Schedule ODF_Demand Outdoor_Air_Temperature Outdoor_Air_Humidity Staging_Schedule ...
    test_data test_data_location save_file_name logicalIndex col rowsToRemove time_data

%% Save data as table and .mat
function data = save_ccn_as_timetable(folder,file)
data = readtimetable([folder '\' file],'RowTimes','Time','VariableNamingRule','preserve','ReadVariableNames',true);
end

%% Create Time Table
% function return_table = merge_table_times(in_table)
% %CCN log implementation currently. Merge Date and Time columns
% 
% Time = in_table.Time;
% %HH:mm:ss = Time column. may be string
% 
% if isstring(Time) || ischar(Time)
%     Time = strtrim(Time);%remove leading white spaces
%     Time = datetime(Time, 'InputFormat', 'hh:mm:ss aa','TimeZone','local');%convert to datetime 
%     newTime = in_table.Date + timeofday(Time);%take only time of day since it adds a date by default
% else
%     if iscell(Time)
%         Time = datetime(Time, 'InputFormat', 'hh:mm:ss aa','TimeZone','local');%convert to datetime 
%         newTime = in_table.Date + timeofday(Time);%take only time of day since it adds a date by default
%     else
%         newTime = in_table.Date + timeofday(Time);
%     end
% end
% %new format from CCN = dd-MMM-uuuu HH:mm:ss
% 
% return_table = removevars(in_table,'Date');
% return_table = removevars(return_table,'Time');
% return_table = table2timetable(return_table,'RowTimes',newTime);
% end

%% Create Dataset

function dataset = createDataset(D_S,IAH,IAT,M_S,OAH,OAT,S_S,init_COMP,init_EXV,init_ID_AF,init_OAT,init_OD_AF,C_Min_D,C_Max_D,ID_D,ODF_D)

%Initialize the dataset
dataset = Simulink.SimulationData.Dataset();

dataset.Name = 'DOE Ht Test Cases';
dataset = addElement(dataset,D_S);          %Defrost Schedule
dataset = addElement(dataset,IAH);          %Indoor Air Humidity
dataset = addElement(dataset,IAT);          %Indoor Air Temperature
dataset = addElement(dataset,M_S);          %Mode Schedule
dataset = addElement(dataset,OAH);          %Outdoor Air Humidity
dataset = addElement(dataset,OAT);          %Outdoor Air Temperature
dataset = addElement(dataset,S_S);          %Staging Schedule
dataset = addElement(dataset,init_COMP);    %initial compressor speed
dataset = addElement(dataset,init_EXV);     %initial exv steps
dataset = addElement(dataset,init_ID_AF);   %initial indoor airflow
dataset = addElement(dataset,init_OAT);     %initial oat
dataset = addElement(dataset,init_OD_AF);   %initial outdoor airflow
dataset = addElement(dataset,C_Min_D);      %compressor min demand
dataset = addElement(dataset,C_Max_D);      %compressor max demand
dataset = addElement(dataset,ID_D);         %indoor airflow demand
dataset = addElement(dataset,ODF_D);        %outdoor demand rpm

end
