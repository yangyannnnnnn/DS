close all;
%% User defined parameters
%This script returns the open loop analysis between defined input/output
%combinations. All results are stored in the struct 'openLoopVariables'
%
%For more information what is returned please see the help section of
%'carrierOpenLoopAnalysis'.
%
%NOTE: This script assumes there is a linearized system model in the
%workspace called 'sys_model'. This system can be created by running
%'SimulateAndLinearizeModel.m'
%

% === OPEN LOOP ANALYSIS === %
% list of inputs to perform open loop analysis on
% comment: analysis is repeated for each input/output combination
u_analyse = u_set;

% list of outputs to perform open loop analysis on
% comment: analysis is repeated for each input/output combination
y_analyse = {'High_Comp_Tsh_suc_R','High_Comp_p_suc_psi_abs','High_Comp_p_dis_psi_abs',...
    'ODU_Comp_Tsh_suc_R','ODU_Comp_p_suc_psi_abs','ODU_Comp_p_dis_psi_abs'};

% if true Bode plots and step responses for each input/output combination
% is added.
createPlots = false;

% === ADVANCED === %
% filtering to reduce the number of states in  linear model
gFiltering = 1e-8;  %Default: 1e-8 (0 = keep all states) 

% boolean if to run the 'Verification' section of the script comparing the
% step responses between the full state model and the reduced one
runVerificationSection = false;

% step amplitude for step response comparison
% comment: Only used if runVerificationSection is true
stepAmplitudeVerification = 5;

%% Open loop analysis

if ~exist('sys_model')
    error("Linearized system model does not exist in workspace. Please create system before running this script.")
end

% define system under control
%sys_model=sys_model_OAT25_3Loop_Odcompr3600;


%open loop analysis
disp("=== Open loop analysis ===") 

%reset structure
openLoopAnalysisResult = {};
openLoopAnalysisResult.u = {};
openLoopAnalysisResult.y = {};
openLoopAnalysisResult.Gm = {};
openLoopAnalysisResult.Pm = {};
openLoopAnalysisResult.Wcg = {};
openLoopAnalysisResult.Wcp = {};
openLoopAnalysisResult.plant_tf = {};

for i = 1:length(u_analyse.names)
    for j = y_analyse
        disp("Create Bode plot and transfer function between input " + u_analyse.names{i} + " and output " + j(1)) 
        openLoopAnalysisResult.u{end + 1} = u_analyse.values{1};
        openLoopAnalysisResult.y(end + 1) = j(1);
        %
        [openLoopAnalysisResult.Gm{end + 1},openLoopAnalysisResult.Pm{end + 1},...
            openLoopAnalysisResult.Wcg{end + 1},openLoopAnalysisResult.Wcp{end + 1},...
            openLoopAnalysisResult.plant_tf{end + 1}] = ...
            carrierOpenLoopAnalysis(sys_model, {u_analyse.names{i}}, j(1), gFiltering, createPlots);
        %}

        disp("Gain margin: " + string(openLoopAnalysisResult.Gm{end}) + ", Phase margin: " + string(openLoopAnalysisResult.Pm{end})) 
        disp(" ") 
    end
end

% nominalation 

sys_crit=[openLoopAnalysisResult.plant_tf{1,1:6};...
    openLoopAnalysisResult.plant_tf{1,7:12};...
    openLoopAnalysisResult.plant_tf{1,13:18};...
    openLoopAnalysisResult.plant_tf{1,19:24};]';
scaled_sys = prescale(ss(sys_crit));

% RGA analysis
systf_zpk=zpk(scaled_sys);
[R,S]=rga(systf_zpk.K);
disp("=== Relative gain analysis ===")
disp("R matrix is: ");
disp(R);
disp("The S matrix is: ");
disp(S);

%% Verification
%compare full system against reduced
if runVerificationSection
    disp("=== Validation - compare step response of full state model against reduced one ===") 
    %Full state transfer functions
    sys=scaled_sys;
    systf_fullStates=tf(sys); 

    %reduce number of states
    sys_ss = carrierReduceSSModel(sys, gFiltering);    
    systf_reducedStates=tf(sys_ss); %reduced transfer functions

    %plot all input/output pairs
    opt = stepDataOptions('InputOffset',0,'StepAmplitude',stepAmplitudeVerification);
    for i=1:size(systf_fullStates,2)
        for j=1:size(systf_fullStates,1)
            thisStep = 'input/output compared: ' + string(sys_model.InputName{i}) + '/' + sys_model.OutputName{j} + ', step = ' + string(stepAmplitudeVerification);
            figure('name', 'Validation ' + string(sys_model.InputName{i}) + '/' + sys_model.OutputName{j});
            step(systf_fullStates(j,i), systf_reducedStates(j,i), opt);
            disp("Plotted step response comparison for " + string(sys_model.InputName{i}) + '/' + sys_model.OutputName{j}) 
            legend('Full state model', 'Reduced state model');
            title(thisStep);
            grid on;
        end
    end
end