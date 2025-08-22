% close all;
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
u_analyse = u_set.names;

% list of outputs to perform open loop analysis on
% comment: analysis is repeated for each input/output combination
y_analyse = y_set.names;

% if true Bode plots and step responses for each input/output combination
% is added.

% if true, perform state reduction before time/frequency analyssis
reduceState = true;

% === ADVANCED === %
% filtering to reduce the number of states in  linear model
gFiltering = 1e-8;  %Default: 1e-8 (0 = keep all states) 

% boolean if to run the 'Verification' section of the script comparing the
% step responses between the full state model and the reduced one
runVerificationSection = true;

% step amplitude for step response comparison
% comment: Only used if runVerificationSection is true
stepAmplitudeVerification = 1;

%% Open loop analysis

if ~exist('sys_model')
    error("Linearized system model does not exist in workspace. Please create system before running this script.")
end

%open loop analysis
disp("=== Open loop analysis ===") 

%reset structure
%{
openLoopAnalysisResult = {};
openLoopAnalysisResult.u = {};
openLoopAnalysisResult.y = {};
openLoopAnalysisResult.Gm = {};
openLoopAnalysisResult.Pm = {};
openLoopAnalysisResult.Wcg = {};
openLoopAnalysisResult.Wcp = {};
openLoopAnalysisResult.plant_tf = {};
%
for i = u_analyse
    for j = y_analyse
        disp("Create Bode plot and transfer function between input " + i{1} + " and output " + j{1}) 
        openLoopAnalysisResult.u{end + 1} = i{1};
        openLoopAnalysisResult.y{end + 1} = j{1};
        [openLoopAnalysisResult.Gm{end + 1},openLoopAnalysisResult.Pm{end + 1},openLoopAnalysisResult.Wcg{end + 1},openLoopAnalysisResult.Wcp{end + 1},openLoopAnalysisResult.plant_tf{end + 1}] = carrierOpenLoopAnalysis(sys_model, i{1}, j{1}, gFiltering, createPlots);
       
        disp("Gain margin: " + string(openLoopAnalysisResult.Gm{end}) + ", Phase margin: " + string(openLoopAnalysisResult.Pm{end})) 
        disp(" ") 
    end
end
%}

if reduceState
    %reduce number of states
    sys_ss = carrierReduceSSModel(sys_model, gFiltering);
    if exvEquiped
        sys_crit = [sys_ss(:,compIdx) sys_ss(:,exvIdx)];
    else
        sys_crit = sys_ss(:,compIdx);
    end
end
opt = stepDataOptions('InputOffset',0,'StepAmplitude',stepAmplitudeVerification);

for input_index=exvIdx:exvIdx%:size(systf_crit,2)
    for output_index=k:k%1:size(systf_crit,1)
        if createStep
            %centralized plot
            tspan=50000;
            t = (0:1:tspan)';
            h=step(sys_crit(output_index,input_index),t,opt);
            plot(h,'lineWidth',5);
            xlim([0 tspan]);
        end
        if createBode
            bode(sys_crit(output_index,input_index))
        end
        l1=string("case" + num2str(p));
        l=[l l1];
        legend(l);
        title("Step responses from " + sys_crit.InputName(input_index) + " to " + sys_crit.OutputName(output_index));
        hold on; 
        %legend(sys_ss.InputName(input_index) + " / " + sys_ss.OutputName(output_index));            
    end
end


%% Verification
%{
%compare full system against reduced
if runVerificationSection
    disp("=== Validation - compare step response of full state model against reduced one ===") 
    %Full state transfer functions
    sys=sys_model;
    systf_fullStates=tf(sys); 

    %reduce number of states
    sys_ss = carrierReduceSSModel(sys, gFiltering);    
    systf_reducedStates=tf(sys_ss); %reduced transfer functions

    %plot all input/output pairs
    opt = stepDataOptions('InputOffset',0,'StepAmplitude',stepAmplitudeVerification);
    for input_index=1:size(systf_fullStates,2)
        for j=1:size(systf_fullStates,1)
            thisStep = 'input/output compared: ' + string(sys_model.InputName{input_index}) + '/' + sys_model.OutputName{j} + ', step = ' + string(stepAmplitudeVerification);
            figure('name', 'Validation ' + string(sys_model.InputName{input_index}) + '/' + sys_model.OutputName{j});
            step(systf_fullStates(j,input_index), systf_reducedStates(j,input_index), opt);
            disp("Plotted step response comparison for " + string(sys_model.InputName{input_index}) + '/' + sys_model.OutputName{j}) 
            legend('Full state model', 'Reduced state model');
            title(thisStep);
            grid on;
        end
    end
end
%}
