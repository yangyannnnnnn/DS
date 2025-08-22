clear all;
%%
close all;
%% User defined parameters

% === GENERAL SIMULATION SETTTINGS === %
% set simulation time. System is linearized at tspan[end]
tspan  = [0:100:3e4];

% FMU to linearize (needs to be FMI 2.0 compatible)
fmuPath = 'C:\Users\yany4\Downloads\Documents\Linearization_and_control_analysis\FMUs\Chiller_0allModels_Chiller23XRV_Validation_MCS_023XRVB4B4NPJR351_TemplateForDynamicValidation_0FMU.fmu';
%fmuPath = 'D:\Documents\Controls\Projects_Trial\Extremum_Seeking_Control\Chiller_0allModels_ARTP_Validation_TwoSingleCircuit_0ARTA_060T_02V_0forSimulink.fmu';

% FMU type to load
% comment: options are "me" and "cs"
fmuKind = 'me';
         
% === MODEL INPUTS === %
% list of inputs to linearize around
% comment: set as empty cell array to automatically find top level inputs of the model and use default value (=0)
u_set.names = {'exvOpening', 'cmprSpeed'};
%u_set.names = {'Tamb', 'fanSpeedA[1]', 'fanSpeedB[1]'};

% constant values of inputs during simulation
% comment: one value per cell array element of u_set.names needs to be set
u_set.values = {63.52, 87.523};
%u_set.values = {60, 40, 40};

% === MODEL OUTPUTS === %
% outputs to take into account for the linearization
% comment: set as empty cell array to autom.atically find top level outputs of the model  
y_set.names = {'p_dis', 'p_suc', 'LWT_evap'};
%y_set.names = {'SDT_cktA', 'SDT_cktB'};


% === MODEL PARAMETERS === %
% parameters to set in the model
% comment: if no parameters are to be changed leave as empty cell array
parameters.names = {};

% parameter values to set in the model
% comment: one value per cell array element of parameters.names needs to be set
parameters.values = {};

% === ADVANCED: ME SPECFICIC SIMULATION SETTTINGS === %
% set solver
% comment: valid options are 'ode45', 'ode23', 'ode113','ode15s', 'ode23s', 'ode23t' and 'ode23tb'
fmuSolver = 'ode15s';

% set relative tolerance
fmuRelTol = 1e-3;

% set absolute tolerance
fmuAbsTol = 1e-6;

%% Simulation

[fmu, tout, yout, yname] = carrierSimulateFMU(fmuPath, tspan, fmuKind, parameters, u_set, y_set, fmuSolver, fmuRelTol, fmuAbsTol);


disp("Plot selected outputs");
plot(tout,yout);
legend(yname);
grid on
title('Simulated outputs');

%% Linearize
%Load the FMU only - Skipping the simulation code group above 
fmu = loadFMU(fmuPath, 'loglevel', 'all', 'kind', fmuKind);
disp("Loaded FMU of type " + fmu.internal.fmuType + " generated using " + fmu.getGenerationTool()) 
fmu.initialize(); 

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