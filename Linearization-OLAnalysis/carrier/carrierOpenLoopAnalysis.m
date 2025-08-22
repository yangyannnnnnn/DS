function [ Gm,Pm,Wcg,Wcp,plant_tf ] = carrierOpenLoopAnalysis(sys_model, input, output, lmtGramians, createPlots)
    %carrierOpenLoopAnalysis - Open loop analysis of 'input' and 'output' in
    %'sys_model'
    %
    %[Gm,Pm,Wcg,Wcp,plant_tf ] = carrierOpenLoopAnalysis(sys_model, input, output, lmtGramians, createPlots)
    %
    %   sys_model - 'sys_model' is a Matlab 'ss' object containing the A, B, C and D matrices
    %               of the linear system as well as the inputs, outputs and states.
    %               Typically created using function 'carrierLinearizeFMU' or 'ss'.
    %
    %   input -     Name of input to analyse (name as used in 'sys_model')
    %
    %   output -    Name of output to analyse  (name as used in 'sys_model')
    %
    %The function returns the Bode plot and the step response of the selected input/output pair as well as:
    % 
    %   Gm     -    Gain margin of open loop system
    %   Pm     -    Phase margin of open loop system
    %   Wcg    -    Frequency at gain margin
    %   Wcp    -    Frequency at phase margin
    %
   
    

    if(nargin<5)
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
        error('Variable ''%s'' not found in model output variables.',output);
    end

    %reduce number of states
    sys_ss = carrierReduceSSModel(sys_model, lmtGramians);

    sys_tf = tf(sys_ss);
    plant_tf = sys_tf(output_index, input_index);

    if createPlots
        figure('Name', 'Bode: ' + string(input) + '/' + string(output));
        P = bodeoptions('cstprefs');
        P.Title.String = string(input) + '/' + string(output);
        bode_figure = bodeplot(plant_tf, P);grid on;
        bode_figure.showCharacteristic("PeakResponse");
        bode_figure.showCharacteristic("MinimumStabilityMargins");

        figure('Name', 'step: ' +  string(input) + '/'  + string(output))
        opt = stepDataOptions('InputOffset',0,'StepAmplitude',1);
        step(plant_tf, opt)
        title('step: ' +  string(input) + '/'  + string(output));
        grid on;
    end

    [Gm,Pm,Wcg,Wcp] = margin(plant_tf);

end

