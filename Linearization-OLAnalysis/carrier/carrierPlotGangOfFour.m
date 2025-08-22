function [gang4_tf] = carrierPlotGangOfFour(sys_model, input, output, ctrl_tf, lmtGramians)
    %carrierPlotGangOfFour Generate the Go4 transfer functions and plot the responses 
    %   
    %   [gang4_tf] = carrierPlotGangOfFour(sys_model, input, output, ctrl_tf, lmtGramians)
    %
    %   Plot gang of four in frequency (bode plots) and time domain (step
    %   responses). The folling input/output relations are plotted:
    %
    %
    %       1: Y/Ysp   -   Output to setpoint
    %       2: Y/D     -   Output to disturbance
    %       3: U/Ysp   -   Control signal to setpoint
    %       4: Y/N     -   Output to noise 
    %  
    %   The function returns the four transfer functions S, T, PS and CS.
    %
    %   sys_model -   'sys_model' is a Matlab 'ss' object containing the A, B, C and D matrices
    %                  of the linear system as well as the inputs, outputs and states.
    %                  Typically created using function 'carrierLinearizeFMU' or 'ss'.
    %
    %   input     -   Input name (actuator). Name as used in 'sys_model' 
    %                  
    %
    %   output    -   Output name (Variable to control). Name as used in 'sys_model'
    %
    %   ctrl_tf   -   Controller transfer function
    %
    %   lmtGramians - Threshold of grammians to filter states (see help balreal for more information)

    if(nargin<4)
       error('Not enough input arguments.')
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
    sys_ss = carrierReduceSSModel(sys_ss, lmtGramians);

    sys_tf = tf(sys_ss);
    plant_tf = sys_tf(output_index, input_index);
    
    gang4_tf.S = 1/(1+ctrl_tf*plant_tf);
    gang4_tf.T = 1 - gang4_tf.S;
    gang4_tf.PS = plant_tf/(1+plant_tf*ctrl_tf);
    gang4_tf.CS = ctrl_tf/(1+plant_tf*ctrl_tf);

    % plot the step response for gang of four.
    figure('Name', 'Go4 step responses: ' + string(input) + '/' + string(output));
    subplot(2,2,1);
    step(gang4_tf.T);title('T (y(s)/y\_sp(s))');grid on;
    subplot(2,2,2);
    step(gang4_tf.PS);title('PS (y(s)/d(s))');grid on;
    subplot(2,2,3);
    step(gang4_tf.CS);title('CS (u(s)/y\_sp(s))');grid on;
    subplot(2,2,4);
    step(gang4_tf.S);title('S (y(s)/n(s))');grid on;

    % plot the bode plot for gang of four.
    figure('Name', 'Go4 Bode plots: ' + string(input) + '/' + string(output));
    subplot(2,2,1);
    bodeplot(gang4_tf.T);title('T (y(s)/y\_sp(s))');grid on;
    subplot(2,2,2);
    bodeplot(gang4_tf.PS);title('PS (y(s)/d(s))');grid on;
    subplot(2,2,3);
    bodeplot(gang4_tf.CS);title('CS (u(s)/y\_sp(s))');grid on;
    subplot(2,2,4);
    bodeplot(gang4_tf.S);title('S (y(s)/n(s))');grid on;
end