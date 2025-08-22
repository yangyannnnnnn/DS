function [Gm,Pm,Wcg,Wcp,plant_tf] = carrierOpenLoopAnalysis2(sys_model, input, output, rom_order, createPlots, compute_margins)
    %carrierOpenLoopAnalysis - Open loop analysis of SISO plant model from 'input' and 'output' in
    % a possibly MIMO 'sys_model'
    %
    % [sys_red, margins] = carrierOpenLoopAnalysis(sys_model, input, output, lmtGramians, createPlots)
    %
    %   sys_model - 'sys_model' is a Matlab 'ss' object containing the A, B, C and D matrices
    %               of the linear system as well as the inputs, outputs and states.
    %               Typically created using function 'carrierLinearizeFMU' or 'ss'.
    %
    %   input -     Name of input to analyse (name as used in 'sys_model')
    %
    %   output -    Name of output to analyse  (name as used in 'sys_model')
    %
    %   rom_order - target order for reduced order model to be obtained via
    %               balred. If not given, empty or inf, no order reduction is performed
    % 
    %   createPlots - if true, bode, step responses and pole-zero plots are
    %                 plotted for teh selected I/O subsystem. Default is true.
    % 
    %   compute_margins  - if true, the function returns in a struct the following data: 
    % 
    %                       Gm     -    Gain margin of open loop system
    %                       Pm     -    Phase margin of open loop system
    %                       Wcg    -    Frequency at gain margin
    %                       Wcp    -    Frequency at phase margin (i.e., system bandwidth)
    %                      
    %                     Default is false. Option is useful for loop gain
    %                     models L = P*C or C*P. 
    %
    % Outputs
    %   sys_red   -  SISO state space model from selected input to output,
    %                after model order reduction. Structural minimal
    %                realization is performed if model order reduction is
    %                not chosen via rom_order input. 
    %
    %  margins    -  Struct with gain, phase margins and the corresponding
    %                frequencies in rad/s
    % 
    
    if(nargin<6 | isempty(compute_margins))
        compute_margins = false; 
    end

    if(nargin<5 | isempty(createPlots))
        createPlots = true;
    end

    if(nargin<4 | isempty(rom_order) | isinf(rom_order))
        reduce_order = false;
    elseif rom_order>=0
        reduce_order = true;
    else 
        error('Invalid reduced model order specified.')
    end

    if(nargin<3)
        error('Not enough arguments')
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
    % sys_ss = carrierReduceSSModel(sys_model, rom_order);
    if reduce_order
        sys_red = balred(sys_model(output_index,input_index), rom_order);
    else
        sys_red = sminreal(sys_model(output_index,input_index));
    end
    
%     sys_tf = tf(sys_red);
%     plant_tf = sys_tf(output_index, input_index);

      plant_tf = tf(sys_red);

      if createPlots
          figure('Name', 'Bode: ' + string(input) + '/' + string(output));
          P = bodeoptions('cstprefs');
          P.Title.String = string(input) + '/' + string(output);
          bode_figure = bodeplot(plant_tf, P);grid on;
          %  bode_figure.showCharacteristic("PeakResponse");
          if compute_margins
              bode_figure.showCharacteristic("MinimumStabilityMargins");
          end
          
          figure('Name', 'step: ' +  string(input) + '/'  + string(output))
          opt = stepDataOptions('InputOffset',0,'StepAmplitude',1);
          step(plant_tf, opt)
          title('step: ' +  string(input) + '/'  + string(output));
          grid on;
          
          figure('Name', 'Pole-Zero: ' +  string(input) + '/'  + string(output))
          opt = pzoptions;
          pzmap(plant_tf, opt)
          title('Pole-Zero: ' +  string(input) + '/'  + string(output));
          grid on;
          
      end

    if compute_margins
        [Gm,Pm,Wcg,Wcp] = margin(plant_tf);
        margins.Gm = Gm;
        margins.Pm = Pm;
        margins.Wcp = Wcp;
        margins.Wcg = Wcg;
    else
        margins = [];
    end
    
end

