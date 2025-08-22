close all;

%% User defined parameters

% === CONTROL ANALYSIS === %
% actuator to do the tuning for
% comment: default values will check all inputs in sys_model. Any subset can be selected. For example: {'exvOpening','cmprSpeed'} 
ctrl_actuator = sys_model.InputName';

% variable to control with selected actuator
% comment: default values will check all outputs in sys_model. Any subset can be selected. For example: {'pdis'; 'psuc'} 
ctrl_variable = sys_model.OutputName';

% calculate total number of input/output pairs to run
% comment: this should never be modified
totCases = size(ctrl_actuator, 2)*size(ctrl_variable, 2);

% controller type, most common options (all in parallel form): 'P', 'I', 'PI', 'PID', 'PIDF
% for a full list (also with 2-DOF controllers) see documentation of 'carrierTuneController'
% comment: set to empty string if to design a controller in standard form using ctrl_C0.
ctrl_type = {}; %reset
[ctrl_type{1:totCases}] = deal(""); %default: set to empty string for all input/output pairs

% define custom controller (allows having PID a controller in standard form) 
% needs to be defined using a pid, pidstd, pid2, or pidstd2 object.
% comment: only used if ctrl_type is an empty string
ctrl_C0 = {}; %reset
[ctrl_C0{1:totCases}] = deal(pidstd(1,1,0)); %default: set all elements to a PI in standard form

% phase margin
ctrl_PM = {}; %reset
[ctrl_PM{1:totCases}] = deal(60); %default: set all elements to 60degrees

% target value of cross over frequency 
% comment: set to -1 to automatically pick the cross over frequency based on the
% plant dynamics
ctrl_wc = {}; %reset
[ctrl_wc{1:totCases}] = deal(-1); %default: set all elements to -1

% design focus: balanced, reference-tracking or disturbance-rejection
ctrl_designFocus = {}; %reset
[ctrl_designFocus{1:totCases}] = deal("disturbance-rejection"); %default: set all elements to "disturbance-rejection"

% === ADVANCED === %
% filtering to reduce the number of states in  linear model
gFiltering = 1e-8;  %Default: 1e-8 (0 = keep all states) 

% boolean if to run the 'Verification' section of the script comparing the
% step responses between the full state model and the reduced one
runVerificationSection = true;

% step amplitude for step response comparison
% comment: Only used if runVerificationSection is true
stepAmplitudeVerification = 5;

%% Analysis

if ~exist('sys_model')
    error("Linearized system model does not exist in workspace. Please create system before running this script.")
end

%closed loop analysis
%margin(ctrl_tf*plant_tf)
disp("=== Closed loop analysis ===")
k = 0;

%reset structure
closedLoopAnalysisResult = {};
closedLoopAnalysisResult.actuator = {};
closedLoopAnalysisResult.y = {};
closedLoopAnalysisResult.ctrl = {};
closedLoopAnalysisResult.ctrl_info = {};
closedLoopAnalysisResult.ctrl_tf = {};
closedLoopAnalysisResult.plant_tf = {};
closedLoopAnalysisResult.go4 = {};

for i = 1:size(ctrl_actuator, 2)
    for j = 1:size(ctrl_variable, 2)
        k = k + 1;
        disp("=== Design PID controller with " + ctrl_PM{k} + " phase margin between actuator " + ctrl_actuator{i} + " and output " + ctrl_variable{j} + " ===");
        disp(" ")
        closedLoopAnalysisResult.actuator{end + 1} = ctrl_actuator{i};
        closedLoopAnalysisResult.y{end + 1} = ctrl_variable{j};
        
        [closedLoopAnalysisResult.ctrl{end + 1}, closedLoopAnalysisResult.ctrl_info{end + 1}, closedLoopAnalysisResult.ctrl_tf{end + 1}, closedLoopAnalysisResult.plant_tf{end + 1}] = carrierTunePID(sys_model, ctrl_actuator{i}, ctrl_variable{j}, ctrl_type{k}, ctrl_C0{k}, ctrl_wc{k}, ctrl_PM{k}, ctrl_designFocus{k}, gFiltering);
       
        closedLoopAnalysisResult.ctrl_info{end}
        closedLoopAnalysisResult.ctrl{end}

        disp("Plot Gang of four in both frequency and time domain.")
        disp(" ")

        closedLoopAnalysisResult.go4{end + 1} = carrierPlotGangOfFour(sys_model, ctrl_actuator{i}, ctrl_variable{j}, closedLoopAnalysisResult.ctrl_tf{end}, gFiltering);
    end
end

%% Verification
%Add step to run full system
%
