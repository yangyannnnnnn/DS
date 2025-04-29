function convertMat2Excel(filename)
% MATFILE2EXCEL extracts signals from MAT (for Cascade project)
%
% file shall be a *.mat file 
% filename shall NOT have the .mat at the end
% For example, filename = 'case1_var_oat'; Command: MatFile2Excel(case1_var_oat)
%
load_system('Cascade_Ctrl_MBD') 
dataIn = load(filename);
%try
    %simout = dataIn.simout;
%    DEF = dataIn.DEF;
%catch
%    simout.logsout = dataIn;
%    save([filename,'.mat'],'simout');
    DEF = [];
%end
logsoutfile = dataIn.data; 
%logsoutfile = simout.logsout; %extracting logsout from the simout

%%
%Writing the data into a matrix
i = 0;
i=i+1;Matrix(:,i) = logsoutfile.getElement('<currObjExv>').Values.Time; Names{i} = 'Time';
L=length(Matrix(:,i));

%% Operation Condition
i=i+1;Matrix(:,i) = logsoutfile.getElement('outdoor_air_temperature').Values.data(1:L); Names{i} = 'OAT';
i=i+1;Matrix(:,i) = logsoutfile.getElement('High_ref_m_flow_lb_h').Values.data(1:L); Names{i} = 'High_Loop_Mass_Flow';
i=i+1;Matrix(:,i) = logsoutfile.getElement('outdoor_airflow_rpm').Values.data(1:1); Names{i} = 'ODU_Air_Flow';
i=i+1;Matrix(:,i) = logsoutfile.getElement('odu_indoor_airflow_cfm').Values.data(1:1); Names{i} = 'IDU_Air_Flow';
i=i+1;Matrix(:,i) = logsoutfile.getElement('Solenoid_1_State').Values.data(1:1); Names{i} = 'Solenoid1';
i=i+1;Matrix(:,i) = logsoutfile.getElement('Solenoid_2_State').Values.data(1:1); Names{i} = 'Solenoid2';
i=i+1;Matrix(:,i) = logsoutfile.getElement('Solenoid_3_State').Values.data(1:1); Names{i} = 'Solenoid3';
i=i+1;Matrix(:,i) = logsoutfile.getElement('Solenoid_4_State').Values.data(1:1); Names{i} = 'Solenoid4';

%% High Pressure Loop
i=i+1;Matrix(:,i) = logsoutfile.getElement('High_suction_superheat').Values.data(1:L); Names{i} = 'High_Loop_SH';
i=i+1;Matrix(:,i) = logsoutfile.getElement('<currObjExv>').Values.data(1:L); Names{i} = 'High_Loop_SH_Setpoint';
i=i+1;Matrix(:,i) = logsoutfile.getElement('High_exv_cmd').Values.data(1:L); Names{i} = 'High_Loop_EXV';
i=i+1;Matrix(:,i) = logsoutfile.getElement('High_discharge_pressure').Values.data(1:L); Names{i} = 'High_Loop_DP';
i=i+1;Matrix(:,i) = logsoutfile.getElement('High_suction_pressure').Values.data(1:L); Names{i} = 'High_Loop_SP';
i=i+1;Matrix(:,i) = logsoutfile.getElement('High_compr_cmd').Values.data(1:L); Names{i} = 'High_Loop_Compr';

%% Outdoor Loop
tempVar=logsoutfile.getElement('odu_suction_superheat');
i=i+1;Matrix(:,i) = tempVar{1}.Values.data(1:L); Names{i} = 'ODU_SH';
i=i+1;Matrix(:,i) = logsoutfile.getElement('odu_exv_steps').Values.data(1:1); Names{i} = 'ODU_EXV';
tempVar=logsoutfile.getElement('odu_discharge_pressure');
i=i+1;Matrix(:,i) = tempVar{1}.Values.data(1:L); Names{i} = 'ODU_DP';
i=i+1;Matrix(:,i) = logsoutfile.getElement('odu_compr_suction_pressure').Values.data(1:L); Names{i} = 'ODU_SP';
i=i+1;Matrix(:,i) = logsoutfile.getElement('odu_compressor_speed_rpm_act').Values.data(1:1); Names{i} = 'ODU_Compr';

%% Auxiliary Loop
i=i+1;Matrix(:,i) = logsoutfile.getElement('Aux_suction_superheat').Values.data(1:L); Names{i} = 'Aux_SH';
% Aux EXV pending exposed
i=i+1;Matrix(:,i) = logsoutfile.getElement('Aux_discharge_pressure').Values.data(1:L); Names{i} = 'Aux_DP';
i=i+1;Matrix(:,i) = logsoutfile.getElement('Aux_suction_pressure').Values.data(1:L); Names{i} = 'Aux_SP';
i=i+1;Matrix(:,i) = logsoutfile.getElement('Aux_compr_cmd').Values.data(1:L); Names{i} = 'Aux_Compr';
i=i+1;Matrix(:,i) = logsoutfile.getElement('Aux_od_fan_cmd').Values.data(1:L); Names{i} = 'Aux_ODF';

%% Array to Table
T = array2table(Matrix,'VariableNames',Names); 
%Create a table with the Matrix data and associated signal names

%% Table to Excel

ExcelFileName=[filename,'.xlsx'];
%replace(filename,'.mat','xlsx');
writetable(T,ExcelFileName,'FileType', 'spreadsheet'); %Writing the data to Excel file

if ~isempty(DEF)
    % Add DEF information to sheet #2
    DEF_t = struct2table(DEF);
    DEF_t(:, table2array(varfun(@isstruct, DEF_t))) = [];
    DEF_t = [DEF_t, struct2table(DEF.FMU)];
    
    DEF_t.git_commit = string(DEF.Env.git_commit);
    DEF_t.git_branch = string(DEF.Env.git_branch);
    DEF_t.git_date = string(DEF.Env.git_date);
    writetable(DEF_t, ExcelFileName, 'Sheet', 2);
end

