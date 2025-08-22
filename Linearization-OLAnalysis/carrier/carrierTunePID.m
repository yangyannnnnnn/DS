function [controller, controller_info, ctrl_tf, plant_tf] = carrierTunePID(sys_model, input, output,type, C0, wcc, phaseMargin, designFocus, lmtGramians)
    %carrierTuneController Tune PID controller..
    %   [controller, controller_info, ctrl_tf, plant_tf] = carrierTunePID(sys_model, input, output,type, C0, wcc, phaseMargin, designFocus, lmtGramians)
    %
    %   Tune a PID controller
    %  
    %   sys_model -   'sys_model' is a Matlab 'ss' object containing the A, B, C and D matrices
    %                 of the linear system as well as the inputs, outputs and states.
    %                 Typically created using function 'carrierLinearizeFMU' or 'ss'.
    %
    %   input -       Name of actuator used to control selected variable 
    %                 (name as used in 'sys_model')
    %
    %   output -      Variable to control (name as used in 'sys_model')
    %                   
    %   type -        The string type specifies the controller type among the 
    %                 following:
    %  
    %                       'P'     Proportional only control
    %                       'I'     Integral only control
    %                       'PI'    PI control
    %                       'PD'    PD control  
    %                       'PDF'   PD control with first order derivative filter 
    %                       'PID'   PID control
    %                       'PIDF'  PID control with first order derivative filter
    %                       'PI2'   2-dof PI control
    %                       'PD2'   2-dof PD control  
    %                       'PDF2'  2-dof PD control with first order derivative filter 
    %                       'PID2'  2-dof PID control
    %                       'PIDF2' 2-dof PID control with first order derivative filter
    %                       'I-PD'  2-DOF PID control with b = 0, c = 0
    %                       'I-PDF' 2-DOF PID control with first order derivative filter and b = 0, c = 0
    %                       'ID-P'  2-DOF PID control with b = 0, c = 1
    %                       'IDF-P' 2-DOF PID control with first order derivative filter and b = 0, c = 1
    %                       'PI-D'  2-DOF PID control with b = 1, c = 0
    %                       'PI-DF' 2-DOF PID control with first order derivative filter and b = 1, c = 0
    %                   
    %                 If 'type' is left as an empty strong 'C0' is used instead. 
    % 
    %   C0 -          Define custom controller (allows having PID a controller in standard form) 
    %                 needs to be defined using a pid, pidstd, pid2, or
    %                 pidstd2 object. Input is ony used if TYPE is an empty
    %                 string.
    %                   
    %   wcc -         Target value of open loop (C*P)cross over frequency. Set to -1 to automatically 
    %                 pick the cross over frequency based on the plant dynamics.
    %                   
    %
    %   phaseMargin - Target value of phase margin (default: 60deg)
    %
    %   designFocus - Design focus: balanced, reference-tracking or disturbance-rejection
    %
    %   lmtGramians - Threshold of grammians to filter states (see help balreal for more information)


    % Generate the gang of four transfer functions for given input and output.
    % In default, the controller will be PI control, and automatically tuned by pidtune() function.   

    if(nargin<5)
       error('Not enough input arguments.')
    end

    if ~(designFocus == "balanced" || designFocus == "reference-tracking" || designFocus == "disturbance-rejection")
        error('Input designFocus must be set to balanced, reference-tracking or disturbance-rejection');
    end

    input_index = -1;
    for i=1:1:length(sys_model.InputName)
        if(strcmp(input, sys_model.InputName{i}))
            input_index=i;
        end
    end

    if input_index==-1
        error('Variable ''%s'' not found in model input variables.',input);
    end

    output_index = -1;
    for i=1:1:length(sys_model.OutputName)
        if(strcmp(output, sys_model.OutputName{i}))
            output_index=i;
        end
    end

    if output_index==-1
        error('Variable ''%s'' not found in model output variables.',input);
    end

    sys_ss = sys_model;

    %reduce number of states
    %sys_ss = carrierReduceSSModel(sys_ss, lmtGramians);

    sys_tf = tf(sys_ss);
    plant_tf = sys_tf(output_index, input_index);

    opts = pidtuneOptions('PhaseMargin',phaseMargin,'DesignFocus',designFocus);

    % Set and tune PI controller to ctrl_tf if it's not specified by user. 
    if type == "" && ~(isa(C0,'pid') || isa(C0,'pidstd') || isa(C0,'pid2') || isa(C0,'pidstd2'))
        error('Either specify type or C0')
    elseif type ~= "" 
        %Use type
        disp('Tuning contoller: ' + string(type));
        if wcc == -1
            [controller, controller_info] = pidtune(plant_tf, type, opts);
        else
            [controller, controller_info] = pidtune(plant_tf, type, wcc, opts);
        end
    else
        %Use custom
        disp('Tuning custom contoller');
        if wcc == -1
            [controller, controller_info] = pidtune(plant_tf, C0, opts);
        else
            [controller, controller_info] = pidtune(plant_tf, C0, wcc, opts);
        end
    end

    ctrl_tf = tf(controller);

    % plot the bode plot for open loop system ctrl_tf*plant_tf
    %figure('Name', 'Bode, open loop response (P*C): ' + string(input) + '/' + string(output));
    bode_figure = bodeplot(ctrl_tf*plant_tf);grid on;%title('Open loop bode plot for C(s)*P(s) for ' + string(input) + '/' + string(output))
    %bode_figure.showCharacteristic("PeakResponse");
    %bode_figure.showCharacteristic("MinimumStabilityMargins");
end

