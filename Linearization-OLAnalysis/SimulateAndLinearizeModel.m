close all;
%% User defined parameters

% === GENERAL SIMULATION SETTTINGS === %
% set simulation time. System is linearized at tspan[end]
tspan  = [0:100:2e3];

% FMU to linearize (needs to be FMI 2.0 compatible)
fmuPath = 'C:\Users\yany4\Downloads\Cascade_w_BD_5T_HP_CSME.fmu';

% FMU type to load
% comment: options are "me" and "cs"
fmuKind = 'me';
         
% === MODEL INPUTS === %
% list of inputs to linearize around
% comment: set as empty cell array to automatically find top level inputs of the model and use default value (=0)
%
u_set.names = {'High_Side_EXV_Position', 'High_Side_Compressor_speed_Input_RPM',...
   'ODU_EXV_Position','ODU_Compressor_speed_Input_RPM'};


% constant values of inputs during simulation
% comment: one value per cell array element of u_set.names needs to be set
u_set.values = {235,4000,...
    220,3600};
%u_set.values={};

% === MODEL PARAMETERS === %
% parameters to set in the model
% comment: if no parameters are to be changed leave as empty cell array
parameters.names = ...
    {'Outdoor_air_humidity_input_percentage','Outdoor_air_temperature_input_F',...
    'Indoor_air_humidity_input_percentage','IDU_fan_air_flow_input_CFM',...
    'Indoor_air_temperature_input_F',...
    'ODU_Reversing_valve_0_cooling','ODU_PEV_Switch','ODU_fan_air_flow_input_RPM',...
    'Aux_loop_reversing_valve_0_cooling','Aux_Loop_Outdoor_fan_speed_RPM',...
    'Aux_Loop_Compressor_speed_Input_RPM',...
    'Solenoid_1_State','Solenoid_2_State','Solenoid_3_State','Solenoid_4_State',...
    'System_Charge_Main_Loop_input_kg','Aux_Loop_Charge_input_kg'};

% parameter values to set in the model
% comment: one value per cell array element of parameters.names needs to be set
parameters.values = ...
    {0.4,5,...
    0.538,1750,...
    70,...
    true,false,800,...
    true,1110,...
    3600,...
    false,false,false,true,...
    5.5,0.35};

% === MODEL OUTPUTS === %
% outputs to take into account for the linearization
% comment: set as empty cell array to automatically find top level outputs of the model  
y_set.names = {'High_Comp_Tsh_suc_R','High_Comp_p_suc_psi_abs','ODU_Comp_Tsh_suc_R',...
    'High_Comp_p_dis_psi_abs','ODU_Comp_p_suc_psi_abs','ODU_Comp_p_dis_psi_abs'};
%{
y_set.names = {'High_Comp_Tsh_suc_R','High_Comp_Tsh_dis_R','High_Comp_p_suc_psi_abs','High_Comp_p_dis_psi_abs',...
    'Aux_Comp_Tsh_suc_R','Aux_Comp_Tsh_dis_R','Aux_Comp_p_suc_psi_abs','Aux_Comp_p_dis_psi_abs',...
    'ODU_Comp_Tsh_suc_R','ODU_Comp_Tsh_dis_R','ODU_Comp_p_suc_psi_abs','ODU_Comp_p_dis_psi_abs',...
    'ODU_Liquid_Line_T_F','ODU_Coil_T_F','ODU_Evap_Out_Tsh_R'};
%}
y_set.refvalues ={10,200,400,...
    8,200,400};
y_set.closeloop = {0,0,...
    0,0,...
    0,0};



% === ADVANCED: ME SPECFICIC SIMULATION SETTTINGS === %
% set solver
% comment: valid options are 'ode45', 'ode23', 'ode113','ode15s', 'ode23s',
% 'ode23t' and 'ode23tb', 'Cvode'
fmuSolver = 'ode23';

% set relative tolerance
fmuRelTol = 1e-3;

% set absolute tolerance
fmuAbsTol = 1e-6;

% PI controllers are added for closed-loop simulation
% the first input is used to control the first output and the second input is used to control the second output
% set propotional gains for two PI controllers
PIctrl.kp_values = {-0.15,0.15,0,...
    0.15,0,0};

% set integral time constants for two PI controllers
PIctrl.ti_values = {60,60,60,...
    0,0,0};
% set sampling time inteval for controllers
PIctrl.time_inteval = 1;

%% Simulation

[fmu, tout, yout, yname] = carrierSimulateFMU(fmuPath, tspan, parameters, u_set, y_set, fmuSolver, fmuRelTol, fmuAbsTol, PIctrl);


disp("Plot selected outputs");
plot(tout,yout);
legend(y_set.names);
grid on
title('Simulated outputs');

%% Linearize
disp("=== Linearization ===") 
[sys_model, isC] = carrierLinearizeFMU(u_set.names', y_set.names', fmu);
disp("---") 
disp("Linear system created.") 
disp(" ") 
disp("INPUTS:");
sys_model.InputName
disp("---") 
disp("OUTPUTS:");
sys_model.OutputName
disp("---")
disp("Number of states: " + string(size(sys_model.StateName, 1)));
disp(" ") 
disp("Script finished. Linear system is stored in workspace in structure 'sys_model' ") 


%% Verification


%% Release FMU

%close and release fmu instance
fmu.fmiTerminate();
fmu.fmiFreeInstance();