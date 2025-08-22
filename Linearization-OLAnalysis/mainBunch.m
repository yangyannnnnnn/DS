%% Simulate the FMU using recorded measurements to compare the output
%{
open_system('test_fmu');
in = Simulink.SimulationInput('test_fmu');

in = in.setExternalInput([ScopeData1{1}.Values.Time, ScopeData1{1}.Values.Data, ...
                          ScopeData1{2}.Values.Data, ScopeData1{6}.Values.Data, ...
                          ScopeData1{5}.Values.Data, ScopeData1{4}.Values.Data, ...
                          ScopeData1{3}.Values.Data  ]);
out = sim(in);
%}
%% Main function for bunch run of linearization and controllability
% analysis of a system. 
%

ewtCond=85;
mFlowCond=[700,900];
%mFlowCond=750;
mFlowEvap=[550,700];
%mFlowEvap=600;
ewtEvap=55;

simulationInput={ewtCond,mFlowCond,mFlowEvap,ewtEvap};

temp=simulationInput;   % reshape to a matrix whose dimention=[case #, feature #]
[temp{:}]=ndgrid(simulationInput{:});
fmuInput=cell2mat(cellfun(@(m)m(:),temp,'uni',0));
    
stabilityResult=[];

R_result=[];            % R matrix in RGA analysis
S_result=[];            % Effective matrix in RGA analysis

R1_result=[];           % R matrix in RGA analysis for a subsystem where 
S1_result=[];           % input=[compSpd, exv]', and output=[liqLvl, lwtEvap]'        

R2_result=[];           % R matrix in RGA analysis for a subsystem where 
S2_result=[];           % input=[compSpd, exv]', and output=[Psuc, Pcond]'
caseNumber=size(fmuInput,1);
%}

closedLoopStability=[];
crossoverFreq=[];
phaseMargin=[];
controllerKp=[];
controllerTi=[];

normalizationPlot=false;
numOfFmu=6;

% Iteratively simulate and linearize the system and perform open & closed
% loop analysis for all cases
%
for m=1:1%:(numOfFmu-1)
    fmuKind = 'me';
    switch m
        case 1
            % for 350T non eco
            fmuPath = 'D:\ADO\WCSW_Controls\WCSW_MBD\Models\PlantModels\FMU\23XRV_A2_TP_350\Chiller_0allModels_Chiller23XRV_Validation_unit_023XRVB4B4NPJR351_0eco_me.fmu';
            fmuPath = 'D:\Documents\Linearization\Linearization\Chiller_0allModels_Chiller23XRV_Validation_unit_023XRVB4B4NPJR351_me.fmu';;
            compSpeed=[64.2;63.7;79.9;79.2];
            EXVOpening=[47.4;47.5;55.1;55.4];
            fmuInput=[EXVOpening(1:caseNumber), compSpeed(1:caseNumber), fmuInput(:,1),fmuInput(:,2),fmuInput(:,3),fmuInput(:,4)];
            u_set.names = {'compSpeed','EXVOpening','EWTCond','m_flow_water_cond','m_flow_water_evap','EWTEvap'};
            u_set.ub_values = {130, 100,    60, 1500,   1500,   60};
            u_set.lb_values = {15,   10,     40, 400,    500,    40};
            y_set.names = {'LWT_evap','liquidLevel','Pdis','Psuc','Pcond','Tdis','SH_dis'};
        case 2
            % for 350T with eco
            fmuPath = 'D:\SW_control_git\WCSW_Controls\WCSW_23_Series_MBD\Models\PlantModels\FMU\23XRV_A2_TP_350\Chiller_0allModels_Chiller23XRV_Validation_unit_023XRVB4B4NPJR351_0eco_me.fmu';
            %
            EXVOpening=[48;48.2;57.8;58.2];
            compSpeed=[63.6;63.1;79.6;78.7];
            fmuInput=[EXVOpening(1:caseNumber), compSpeed(1:caseNumber), fmuInput(:,1),fmuInput(:,2),fmuInput(:,3),fmuInput(:,4)];
            u_set.names = {'compSpeed','EXVOpening','EWTCond','m_flow_water_cond','m_flow_water_evap','EWTEvap'};
            u_set.ub_values = {130, 100,    60, 1500,   1500,   60};
            u_set.lb_values = {15,   10,     40, 400,    500,    40};
            y_set.names = {'LWT_evap','liquidLevel','Pdis','Psuc','Pcond','Tdis','SH_dis'};
        case 3
            % for 400T non eco
            fmuPath = 'D:\SW_control_git\WCSW_Controls\WCSW_23_Series_MBD\Models\PlantModels\FMU\23XRV_A1_TR_400\Chiller_0allModels_Chiller23XRV_Validation_unit_023XRV4747ERVAA50_me.fmu';
            fmupath = 'D:\SW_control_git\WCSW_Controls\WCSW_23_Series_MBD\Models\PlantModels\FMU\23XRV_A1_TR_400\new\new_output\Chiller_0allModels_Chiller23XRV_Validation_unit_023XRV4747ERVAA50_0eco.fmu';
            compSpeed=[37.9;37.5;43.7;43.3];
            compSpeed=40;
            fmuInput=[compSpeed(1:caseNumber), fmuInput(:,1),fmuInput(:,2),fmuInput(:,3),fmuInput(:,4)];
            u_set.names = {'compSpeed','EWTCond','m_flow_water_cond','m_flow_water_evap','EWTEvap'};
            u_set.ub_values = {130,    60, 1500,   1500,   60};
            u_set.lb_values = {15,     40, 400,    500,    40};
            y_set.names = {'LWT_evap','liquidLevel','Pdis','Psuc','Pcond','Tdis','SH_dis'};
        case 4
            % for 400T with eco
            fmuPath = 'D:\SW_control_git\WCSW_Controls\WCSW_23_Series_MBD\Models\PlantModels\FMU\23XRV_A1_TR_400\Chiller_0allModels_Chiller23XRV_Validation_unit_023XRV4747ERVAA50_0eco_me.fmu';
            %
            compSpeed=[38.1;37.7;43.8;43.3];
            fmuInput=[compSpeed(1:caseNumber), fmuInput(:,1),fmuInput(:,2),fmuInput(:,3),fmuInput(:,4)];
            u_set.names = {'compSpeed','EWTCond','m_flow_water_cond','m_flow_water_evap','EWTEvap'};
            u_set.ub_values = {130,    60, 1500,   1500,   60};
            u_set.lb_values = {15,     40, 400,    500,    40};
            y_set.names = {'LWT_evap','liquidLevel','Pdis','Psuc','Pcond','Tdis','SH_dis'};
        case 5
            % for 500T non eco
            fmuPath = 'D:\SW_control_git\WCSW_Controls\WCSW_23_Series_MBD\Models\PlantModels\FMU\23XRV_A1_TR_500\Chiller_0allModels_Chiller23XRV_Validation_unit_023XRV5757ERVR451_me.fmu';
            compSpeed=[35.9;35.5;41.5;41];
            fmuInput=[compSpeed(1:caseNumber), fmuInput(:,1),fmuInput(:,2),fmuInput(:,3),fmuInput(:,4)];
            u_set.names = {'compSpeed','EWTCond','m_flow_water_cond','m_flow_water_evap','EWTEvap'};
            u_set.ub_values = {130,    60, 1500,   1500,   60};
            u_set.lb_values = {15,     40, 400,    500,    40};
            y_set.names = {'LWT_evap','liquidLevel','Pdis','Psuc','Pcond','Tdis','SH_dis'};
        case 6
            % for 500T with eco
            fmuPath = 'D:\SW_control_git\WCSW_Controls\WCSW_23_Series_MBD\Models\PlantModels\FMU\23XRV_A1_TR_500\Chiller_0allModels_Chiller23XRV_Validation_unit_023XRV5757ERVR451_0eco_me.fmu';
            compSpeed=[36.9;36.5;42.4;41.8];
            fmuInput=[compSpeed(1:caseNumber), fmuInput(:,1),fmuInput(:,2),fmuInput(:,3),fmuInput(:,4)];
            u_set.names = {'compSpeed','EWTCond','m_flow_water_cond','m_flow_water_evap','EWTEvap'};
            u_set.ub_values = {130,    60, 1500,   1500,   60};
            u_set.lb_values = {15,     40, 400,    500,    40};
            y_set.names = {'LWT_evap','liquidLevel','Pdis','Psuc','Pcond','Tdis','SH_dis'};
    end

    for idx=1:caseNumber
        u_set.values=num2cell(fmuInput(idx,:));
        disp(['========== Case: ',num2str((m-1)*caseNumber+idx), '==========']);
        
        exvEquiped=false;
        compEquiped=false;
        exvIdx=[];
        compIdx=[];
        for i=1:length(u_set.names)
                if strncmp(string(u_set.names(i)),"EXVOpening",length('EXVOpening'))
                    exvEquiped=1;
                    exvIdx=i;
                end
                if strncmp(string(u_set.names(i)),"compSpeed",length('compSpeed'))
                    compEquiped=1;
                    compIdx=i;
                end
        end
        
        if isfile(['sys_model_cl_eq',num2str((m-1)*caseNumber+idx),'.mat'])
            load(['sys_model_cl_eq',num2str((m-1)*caseNumber+idx),'.mat']);
        else
            % Simulate the fmu and linear the model
            SimulateAndLinearizeModel;
            save(['sys_model_cl_eq',num2str((m-1)*caseNumber+idx),'.mat'],'sys_model')
        end

        sys=sys_model;
        stabilityResult=[stabilityResult, isstable(sys)];
 
        % RGA analysis for full and sub systems
        sys_crit=sys_model;
        systf_crit=tf(sys_model);
        systf_zpk=zpk(systf_crit);
        %for k=1:size(systf_zpk.K,2)
        %    K=systf_zpk.K(:,k).*[1/150;1/30;1/300;1/300;1/300;1/200;1/50];
        %end
        
        [R,S]=rga(systf_zpk.K);
        systf_rga1=[systf_crit(1,:);systf_crit(2,:)];   % Subsystem 1 where 
                                                        % input=[compSpd, exv]' 
                                                        % output=[lwtEvap, liqLvl]'
        %{
        systf_zpk=zpk(systf_rga1);
        [R1,S1]=rga(systf_zpk.K);
        systf_rga2=[systf_crit(4,:);systf_crit(5,:)];   % Subsystem 2 where
                                                        % input=[compSpd, exv]', 
                                                        % output=[Psuc, Pcond]' 
        systf_zpk=zpk(systf_rga2);
        [R2,S2]=rga(systf_zpk.K);

        R_result=[R_result R];      % row dimension=output #,                                    
        S_result=[S_result S];      % column dimention=input # * case #

        R1_result=[R1_result R1];
        S2_result=[S2_result S2];

        R2_result=[R2_result R2];
        S1_result=[S1_result S1];
        %}
        dispEnable=true;
        %figure();
        %RunOpenLoopAnalysis_new;       % Step response, bode plot, pole-zero map, 

        %FindandEvaluateController; % Tune PID, bode plot for CL system, 
                                    % and plot gang of 4 (sensitivity analysis)
        %save(['closedLoopAnalysisResult_',num2str((m-1)*caseNumber+idx),'.mat'],'closedLoopAnalysisResult');

        ctrl_actuator = sys_crit.InputName';
        ctrl_variable = sys_crit.OutputName';

        totCases = size(ctrl_actuator, 2)*size(ctrl_variable, 2);

        [ctrl_PM{1:totCases}] = deal(60);
        if isfile(['closedLoopAnalysisResult_',num2str((m-1)*caseNumber+idx),'.mat'])
            load(['closedLoopAnalysisResult_',num2str((m-1)*caseNumber+idx),'.mat']);
            figure();
            l=[];
            k=0;
            tspan=1:35000;
            for i = 1:size(ctrl_actuator, 2)
                for j = 1:size(ctrl_variable, 2)
                    if strcmp(closedLoopAnalysisResult.actuator{(i-1)*size(ctrl_variable,2)+j}, 'compSpeed') || ...
                    strcmp(closedLoopAnalysisResult.actuator{(i-1)*size(ctrl_variable,2)+j}, 'EXVOpening')
                        k = k + 1;
                        %disp("=== Design PID controller with " + ctrl_PM{k} + " phase margin between actuator " + ctrl_actuator{i} + " and output " + ctrl_variable{j} + " ===");
                        closedLoopStability=[closedLoopStability closedLoopAnalysisResult.ctrl_info{(i-1)*size(ctrl_variable,2)+j}.Stable];
                        crossoverFreq=[crossoverFreq closedLoopAnalysisResult.ctrl_info{(i-1)*size(ctrl_variable,2)+j}.CrossoverFrequency];
                        phaseMargin=[phaseMargin closedLoopAnalysisResult.ctrl_info{(i-1)*size(ctrl_variable,2)+j}.PhaseMargin];
                        controllerKp=[controllerKp closedLoopAnalysisResult.ctrl{(i-1)*size(ctrl_variable,2)+j}.Kp];  
                        controllerTi=[controllerTi closedLoopAnalysisResult.ctrl{(i-1)*size(ctrl_variable,2)+j}.Ti];  
                        % complementary sensitivity function
                        % T=PC/(1+PC)
                        y=step(closedLoopAnalysisResult.go4{(i-1)*size(ctrl_variable,2)+j}.T);             
                        if i==1 && j==1
                            h=subplot(2,2,1);        
                            plot(y);
                            set(h,'Tag','step1');
                            l1=string("plant input: " + ctrl_actuator{i} + ". Plant output " + ctrl_variable{j});
                            l=[l l1];
                            legend(l);
                            title('T=PC/(1+PC)');grid on;
                        else
                            %h=findobj('Tag','step1');
                            h=subplot(2,2,1); 
                            set(h,'NextPlot','add');
                            plot(h,y);
                            l1=string("plant input: " + ctrl_actuator{i} + ". Plant output " + ctrl_variable{j});
                            l=[l l1];
                            legend(l);
                        end
                        % load disturbance sensitivity function
                        % PS=P/(1+PC)
                        y=step(tspan,closedLoopAnalysisResult.go4{(i-1)*size(ctrl_variable,2)+j}.PS);
                        if i==1 && j==1
                            h=subplot(2,2,2);
                            plot(y);xlim([0 40]);
                            set(h,'Tag','step2');
                            title('PS=P/(1+PC)');grid on;
                        else
                            %h=findobj(h,'Tag','step2');
                            h=subplot(2,2,2);
                            set(h,'NextPlot','add');
                            plot(h,y);xlim([0 40]);
                        end
                        % noise sensitivity function
                        % CS=C/(1+PC)
                        y=step(tspan, closedLoopAnalysisResult.go4{(i-1)*size(ctrl_variable,2)+j}.CS);
                        if i==1 && j==1
                            h=subplot(2,2,3);
                            plot(y);xlim([0 40]);
                            set(h,'Tag','step3');
                            title('CS=C/(1+PC)');grid on;
                        else
                            %h=findobj('Tag','step3');
                            h=subplot(2,2,3);
                            set(h,'NextPlot','add');
                            plot(h,y);xlim([0 40]);
                        end
                        % sensitivity function
                        % S=1/(1+PC)
                        y=step(closedLoopAnalysisResult.go4{(i-1)*size(ctrl_variable,2)+j}.S);
                        if i==1 && j==1
                            h=subplot(2,2,4);
                            plot(y);
                            set(h,'Tag','step4');
                            title('S=1/(1+PC)');grid on;
                        else
                            %h=findobj('Tag','step4');
                            h=subplot(2,2,4);
                            set(h,'NextPlot','add');
                            plot(h,y);
                        end   
                    end
                end
            end
        else
            disp('Warning: no closed-loop controller loaded.')
        end
    end
end
%}
m=1;
stepAnalysis=false;
if stepAnalysis
    for k=1:length(sys_model.OutputName)
        figure();        
        l=[];
        for p=((m-1)*caseNumber+1):(m*caseNumber)
            disp(['===== Loading Case: ',num2str(p), '=====']);
            if isfile(['sys_model_cl_eq',num2str(p),'.mat'])
                load(['sys_model_cl_eq',num2str(p),'.mat']); 
                exvEquiped=false;
                compEquiped=false;
                exvIdx=[];
                compIdx=[];
                for i=1:length(sys_model.InputName)
                        if strncmp(string(sys_model.InputName(i)),"EXVOpening",length('EXVOpening'))
                            exvEquiped=1;
                            exvIdx=i;
                        end
                        if strncmp(string(sys_model.InputName(i)),"compSpeed",length('compSpeed'))
                            compEquiped=1;
                            compIdx=i;
                        end
                end
                if length(compIdx)<1 && length(exvIdx)<1
                    disp('No compressor and exv equipped!')
                    break
                end
                if length(compIdx)>=1
                    u_set.names = sys_model.InputName{exvIdx,1};
                    y_set.names = sys_model.OutputName{k,1};
                    dispEnable=true;
                    %figure();
                    createBode=false;
                    createStep=true;
                    RunOpenLoopAnalysis_new;        % Step response
                end
            end
        end
    end
end

numOfFmu=1;
m=1;
gangOf4=true;
if gangOf4
    exvAnalysis=true;
    if exvAnalysis
        ctrl_actuator = {'EXVOpening'};
    else
        ctrl_actuator = {'compSpeed'};
    end
    ctrl_variable = sys_crit.OutputName';
    
    disp('===== Plotting gang of 4 =====');
    for i = 2:2
        for j = 1:size(ctrl_variable, 2)
            %
            figure();
            for p=((m-1)*caseNumber+1):(m*caseNumber)
                if isfile(['closedLoopAnalysisResult_',num2str(p),'.mat'])
                    load(['closedLoopAnalysisResult_',num2str(p),'.mat']);
                    if strcmp(closedLoopAnalysisResult.actuator{(i-1)*size(ctrl_variable,2)+j}, ctrl_actuator)
                        bode(closedLoopAnalysisResult.go4{(i-1)*size(ctrl_variable,2)+j}.T);
                        grid; title('T=PC/(1+PC)');
                        grid on;hold on;
                    end
                end
            end

            %
            figure();
            for p=((m-1)*caseNumber+1):(m*caseNumber)
                if isfile(['closedLoopAnalysisResult_',num2str(p),'.mat'])
                    load(['closedLoopAnalysisResult_',num2str(p),'.mat']);
                    if strcmp(closedLoopAnalysisResult.actuator{(i-1)*size(ctrl_variable,2)+j}, ctrl_actuator)
                        bode(closedLoopAnalysisResult.go4{(i-1)*size(ctrl_variable,2)+j}.PS);
                        title('PS=P/(1+PC)');grid on;hold on;
                    end
                end
            end
            
            figure();
            for p=((m-1)*caseNumber+1):(m*caseNumber)
                if isfile(['closedLoopAnalysisResult_',num2str(p),'.mat'])
                    load(['closedLoopAnalysisResult_',num2str(p),'.mat']); 
                    if strcmp(closedLoopAnalysisResult.actuator{(i-1)*size(ctrl_variable,2)+j}, ctrl_actuator)
                        bode(closedLoopAnalysisResult.go4{(i-1)*size(ctrl_variable,2)+j}.CS);
                        title('CS=C/(1+PC)');grid on;hold on;
                    end
                end
            end
            
            figure();
            for p=((m-1)*caseNumber+1):(m*caseNumber)
                if isfile(['closedLoopAnalysisResult_',num2str(p),'.mat'])
                    load(['closedLoopAnalysisResult_',num2str(p),'.mat']);
                    if strcmp(closedLoopAnalysisResult.actuator{(i-1)*size(ctrl_variable,2)+j}, ctrl_actuator)
                        bode(closedLoopAnalysisResult.go4{(i-1)*size(ctrl_variable,2)+j}.S);
                        title('S=1/(1+PC)');grid on;hold on;
                    end
                end
            end
            %}
            
        end
    end
end

%% Controller validation
s=tf('s');
Kp=0.019;
Ti=0.0023;
Ki=Kp/Ti;
C=-Kp+Ki/s;
%sys=sys_model(1,1); % compSpd/LWT
sys=sys_model(2,2); % EXV/liquidLvl
figure();
step(sys);

H=feedback(C*sys,1);
figure();
[mag,phase,wout] = bode(H);
Mag=20*log10(mag(:));
Phase=phase(:);
%semilogx(wout,Phase,'LineWidth',3);
%bode(H);
margin(mag,phase,wout);
%set(findall(gcf,'type','line'),'linewidth',2)
%xlim([0,100]);

%% RGA
%}
%{
% RGA analysis over disturbances
countR1=zeros(4,1);         % 4*1 vector to count good IO pairing
                            % performance for subsystem 1
                            % bit 4: total#, 
                            % bit 3: # under low condition, 
                            % bit 2: # under center condition,
                            % bit 1: # under high condition,
countR2=zeros(4,1);         % 4*1 vector to count good IO pairing
                            % performance for subsystem 2
                            % bit 4: total#, 
                            % bit 3: # under low condition, 
                            % bit 2: # under center condition,
                            % bit 1: # under high condition,
countR=zeros(7*2,4);        % 4*1 vector to count good IO pairing
                            % performance for defined critical system 
                            % bit 4: total#, 
                            % bit 3: # under low condition, 
                            % bit 2: # under center condition,
                            % bit 1: # under high condition,

for i=1:2:size(R_result,2)
    caseNum=ceil(i/2);
    
    conditionEwtCond_1=((caseNum-1)/3==ceil((caseNum-1)/3));
    conditionEwtCond_2=((caseNum-2)/3==ceil((caseNum-2)/3));
        
    conditionFlowEvap_1=((rem(caseNum,9)>=1) && (rem(caseNum,9)<=3));
    conditionFlowEvap_2=((rem(caseNum,9)>=4) && (rem(caseNum,9)<=6));
    
    conditionFlowCond_1=((rem(caseNum,27)>=1) && (rem(caseNum,27)<=9));
    conditionFlowCond_2=((rem(caseNum,27)>=10) && (rem(caseNum,27)<=18));

    conditionEwtEvap_1=((caseNum-1)/27==ceil((caseNum-1)/27));
    conditionEwtEvap_2=((((caseNum-1)/27)>=1) && (((caseNum-1)/27)<2));
    
    cond1=conditionFlowCond_1;
    cond2=conditionFlowCond_2;
    if cond1  
        if R1_result(1,caseNum*2-1)<=1.2 && R1_result(1,caseNum*2-1)>=0.8
            countR1(1,1)=countR1(1,1)+1;
            countR1(2,1)=countR1(2,1)+1;
        end
        if R2_result(1,caseNum*2-1)<=1.2 && R2_result(1,caseNum*2-1)>=0.8
            countR2(1,1)=countR2(1,1)+1;
            countR2(2,1)=countR2(2,1)+1;
        end
        for k=(caseNum*2-1):(caseNum*2)
            temp=double(k/2==ceil(k/2));
            for j=1:size(R,1)
                if R_result(j,k)<=1.2 && R_result(j,k)>=0.8
                    countR(j+temp*(size(R,1)),1)=countR(j+temp*(size(R,1)),1)+1;
                    countR(j+temp*(size(R,1)),2)=countR(j+temp*(size(R,1)),2)+1;
                end
            end
        end
    elseif cond2
        if R1_result(1,caseNum*2-1)<=1.2 && R1_result(1,caseNum*2-1)>=0.8
            countR1(1,1)=countR1(1,1)+1;
            countR1(3,1)=countR1(3,1)+1;
        end
        if R2_result(1,caseNum*2-1)<=1.2 && R2_result(1,caseNum*2-1)>=0.8
            countR2(1,1)=countR2(1,1)+1;
            countR2(3,1)=countR2(3,1)+1;
        end
        for k=(caseNum*2-1):(caseNum*2)
            temp=double(k/2==ceil(k/2));
            for j=1:size(R,1)
                if R_result(j,k)<=1.2 && R_result(j,k)>=0.8
                    countR(j+temp*(size(R,1)),1)=countR(j+temp*(size(R,1)),1)+1;
                    countR(j+temp*(size(R,1)),3)=countR(j+temp*(size(R,1)),3)+1;
                end
            end
        end
    else
        if R1_result(1,caseNum*2-1)<=1.2 && R1_result(1,caseNum*2-1)>=0.8
            countR1(1,1)=countR1(1,1)+1;
            countR1(4,1)=countR1(4,1)+1;
        end
        if R2_result(1,caseNum*2-1)<=1.2 && R2_result(1,caseNum*2-1)>=0.8
            countR2(1,1)=countR2(1,1)+1;
            countR2(4,1)=countR2(4,1)+1;
        end
        for k=(caseNum*2-1):(caseNum*2)
            temp=double(k/2==ceil(k/2));
            for j=1:size(R,1)
                if R_result(j,k)<=1.2 && R_result(j,k)>=0.8
                    countR(j+temp*(size(R,1)),1)=countR(j+temp*(size(R,1)),1)+1;
                    countR(j+temp*(size(R,1)),4)=countR(j+temp*(size(R,1)),4)+1;
                end
            end
        end
    end
end
temp1=[];
for j=1:size(countR,2)
    temp=reshape(countR(:,j),[ceil(size(countR,1)/2),2]);
    temp1=[temp1,temp];
end
countR=temp1;


disp(['Case # with good R1 matrix is: ', num2str(countR1(1,1)), ' out of ', num2str(caseNum)]);
disp(['Case # with good R1 matrix under low edge condition is: ', num2str(countR1(2,1)), ' out of ', num2str(caseNum/3)]);
disp(['Case # with good R1 matrix under center condition is: ', num2str(countR1(3,1)), ' out of ', num2str(caseNum/3)]);
disp(['Case # with good R1 matrix under high edge condition is: ', num2str(countR1(4,1)), ' out of ', num2str(caseNum/3)]);
%}
