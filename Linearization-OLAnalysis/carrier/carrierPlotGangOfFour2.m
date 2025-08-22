function [gang4_tf,cl_stable_flags] = carrierPlotGangOfFour2(sys_model, input, output, ctrl_model,w_range,bode_opts,omit_unstable)
% carrierPlotGangOfFour2 Generate the Gang of 4Four transfer functions and plot
% their responses for a closed loop system, given the plant and controller models.
%
%   [gang4_tf,cl_stable_flags] = carrierPlotGangOfFour2(sys_model, inputs, outputs, ctrl_model)
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
%   The function returns the four transfer functions S, T, PS and CS in a
%   structure.
%
%   sys_model -   'sys_model' is a Matlab LTI (linear time invariant) system model object
%                  with the inputs, outputs and states name info.
%                  Typically created using function 'carrierLinearizeFMU' or 'ss' or 'tf'.
%
%                  This can be a single LTI model or an array of LTI models or a 1-D cell array
%                  of LTI models.
%
%   input     -   Input name (actuator). Name as used in 'sys_model' or its elements
%
%   output    -   Output name (Variable to control). Name as used in 'sys_model'
%                 or its elements
%
%   ctrl_model   -   Controller transfer function. The controller is a common controller
%                    when an array of plant models is specified.
%
%   w_range     -  Frequency range for Bode plots, as a cell array, in
%                  rad/s. Default is  {2*pi*1e-3, 2*pi*1e2} which is 1 mHz to 100 Hz. 
%
%   bode_opts   -   Bode options object for bode plot. System default is
%                   used if empty or not provided.
%
%  omit_unstable - Omit plots for unstable closed loop case. Default is true. 
%
% Outputs
%   gang4_tf    - Structure with the Gang of Four transfer functions of the
%                 same type as sys_model (single LTI or LTI array or cell array) 
%
%   cl_stable_flags - Closed loop stability indicator flag(s). An array of flags is returned
%                     when sys_model is an LTI array or cell array

if(nargin<7 | isempty(omit_unstable))
   omit_unstable = true;
end

if(nargin<6 | isempty(bode_opts))
   bode_opts = bodeoptions;
end

if(nargin<5 | isempty(w_range))
   w_range = {2*pi*1e-3, 2*pi*1e2}; % default is 1 mHz to 100 Hz
end

if(nargin<4)
    error('Not enough input arguments.')
end

% Type of system model
sys_is_cell = iscell(sys_model);

% Identify input/output indices

if isempty(input),
    warning('No input name specified. Using the first input.')
    input_index = 1;
else
    if sys_is_cell
        try % sys_model is a cell array
            input_index = find(strcmp(input,sys_model{1}.InputName));
        catch
            error('Variable ''%s'' not found in model input variables.',input);
        end
    else
        try % assume sys_model to be an LTI array or a single LTI system
            input_index = find(strcmp(input,sys_model.InputName));
        catch
            error('Variable ''%s'' not found in model input variables.',input);
        end
    end
end

if isempty(output),
    warning('No output name specified. Using the first output.')
    output_index = 1;
else
    if sys_is_cell
        try % sys_model is a cell array
            output_index = find(strcmp(output,sys_model{1}.OutputName));
        catch
            error('Variable ''%s'' not found in model output variables.',output);
        end
    else
        try % assume sys_model to be an LTI array or a single LTI system
            output_index = find(strcmp(output,sys_model.OutputName));
        catch
            error('Variable ''%s'' not found in model output variables.',output);
        end
    end
end

if sys_is_cell
    
    n_plants = length(sys_model);
        
    gang4_tf.S = cell(size(sys_model));
    gang4_tf.T = cell(size(sys_model));
    gang4_tf.PS = cell(size(sys_model));
    gang4_tf.CS = cell(size(sys_model));
    
    cl_stable_flags = logical(zeros(n_plants,1));
        
    for i=1:n_plants
        plant_io = sys_model{i}(output_index,input_index); % extract the plant from cell array
        gang4_tf.S{i} = 1/(1+ctrl_model*plant_io);
        gang4_tf.T{i} = 1 - gang4_tf.S{i};
        gang4_tf.PS{i} = plant_io * gang4_tf.S{i};
        gang4_tf.CS{i} = ctrl_model * gang4_tf.S{i};
        
        % Take structural minimal realizations
        gang4_tf.S{i} = sminreal(gang4_tf.S{i});
        gang4_tf.T{i} = sminreal(gang4_tf.T{i});
        gang4_tf.PS{i} = sminreal(gang4_tf.PS{i});
        gang4_tf.CS{i} = sminreal(gang4_tf.CS{i});
        
        if omit_unstable
            cl_stable_flags(i) = isstable(gang4_tf.T{i}) & isstable(gang4_tf.S{i}) & isstable(gang4_tf.PS{i}); 
        else 
            cl_stable_flags(i) = true; % do not perform stability check
        end
    end
    
    % plot the step response for gang of four.
    figure('Name', 'Go4 step responses: ' + string(input) + '/' + string(output));
    subplot(2,2,1);
    step(gang4_tf.T{cl_stable_flags});title('T (y(s)/y\_sp(s))');grid on;
    subplot(2,2,2);
    step(gang4_tf.PS{cl_stable_flags});title('PS (y(s)/d(s))');grid on;
    subplot(2,2,3);
    step(gang4_tf.CS{cl_stable_flags});title('CS (u(s)/y\_sp(s))');grid on;
    subplot(2,2,4);
    step(gang4_tf.S{cl_stable_flags});title('S (y(s)/n(s))');grid on;
    
    % plot the bode plot for gang of four.
    figure('Name', 'Go4 Bode plots: ' + string(input) + '/' + string(output));
    subplot(2,2,1);
    bodeplot(gang4_tf.T{cl_stable_flags},w_range,bode_opts);
    title('T (y(s)/y\_sp(s))');grid on;
    subplot(2,2,2);
    bodeplot(gang4_tf.PS{cl_stable_flags},w_range,bode_opts);
    title('PS (y(s)/d(s))');grid on;
    subplot(2,2,3);
    bodeplot(gang4_tf.CS{cl_stable_flags},w_range,bode_opts);
    title('CS (u(s)/y\_sp(s))');grid on;
    subplot(2,2,4);
    bodeplot(gang4_tf.S{cl_stable_flags},w_range,bode_opts);
    title('S (y(s)/n(s))');grid on;
    
else % sys_model is an LTI array
    
    n_plants = length(sys_model);
    
    plant_io = sys_model(output_index,input_index,:);
    
    gang4_tf.S = 1/(1+ctrl_model*plant_io);
    gang4_tf.T = 1 - gang4_tf.S;
    gang4_tf.PS = plant_io*gang4_tf.S;
    gang4_tf.CS = ctrl_model*gang4_tf.S;
    
    % Take structural minimal realizations
    gang4_tf.S{i} = sminreal(gang4_tf.S{i});
    gang4_tf.T{i} = sminreal(gang4_tf.T{i});
    gang4_tf.PS{i} = sminreal(gang4_tf.PS{i});
    gang4_tf.CS{i} = sminreal(gang4_tf.CS{i});
    
    if omit_unstable
        cl_stable_flags = isstable(gang4_tf.T,'elem') & isstable(gang4_tf.S,'elem') & isstable(gang4_tf.CS,'elem');
    else
        cl_stable_flags = logical(ones(n_plants,1));
    end
    
    % plot the step response for gang of four
    figure('Name', 'Go4 step responses: ' + string(input) + '/' + string(output));
    
    subplot(2,2,1);
    stepplot(gang4_tf.T(:,:,cl_stable_flags));
    title('T (y(s)/y\_sp(s))');grid on;
    
    subplot(2,2,2);
    stepplot(gang4_tf.PS(:,:,cl_stable_flags));
    title('PS (y(s)/d(s))');grid on;
    
    subplot(2,2,3);
    stepplot(gang4_tf.CS(:,:,cl_stable_flags));
    title('CS (u(s)/y\_sp(s))');grid on;
    
    subplot(2,2,4);
    stepplot(gang4_tf.S(:,:,cl_stable_flags));
    title('S (y(s)/n(s))');grid on;
    
    % plot the bode plot for gang of four
    figure('Name', 'Go4 Bode plots: ' + string(input) + '/' + string(output));
    
    subplot(2,2,1);
    bodeplot(gang4_tf.T(:,:,cl_stable_flags),w_range,bode_opts);
    title('T (y(s)/y\_sp(s))');grid on;
    
    
    subplot(2,2,2);
    bodeplot(gang4_tf.PS(:,:,cl_stable_flags),w_range,bode_opts);
    title('PS (y(s)/d(s))');grid on;
    
    subplot(2,2,3);
    bodeplot(gang4_tf.CS(:,:,cl_stable_flags),w_range,bode_opts);
    title('CS (u(s)/y\_sp(s))');grid on;
    
    subplot(2,2,4);
    bodeplot(gang4_tf.S(:,:,cl_stable_flags),w_range,bode_opts);
    title('S (y(s)/n(s))');grid on;
    
end 

if omit_unstable
    warning([num2str(n_plants-sum(cl_stable_flags)),' out of ',num2str(n_plants),' unstable cases omitted from plots!'])
end

end % end of function

%% CODE THAT STILL NEEDS DEVELOPMENT & TESTING... DID NOT WORK.

% Below code was tried to get different colors for different elements in the case of an LTI array system model
% It tries to plot the step & bode responses one at a time with hold on.

%     % Setup figures 
%     fh1 = figure('Name', 'Go4 step responses: ' + string(input) + '/' + string(output));
%     clf
%         
%     fh2 = figure('Name', 'Go4 Bode plots: ' + string(input) + '/' + string(output));
%     clf 
%     
%     for i=1:n_plants
%         plant_io = sys_model(output_index,input_index,i);
%         
%         gang4_tf.S(:,:,i) = 1/(1+ctrl_model*plant_io);
%         gang4_tf.T(:,:,i) = 1 - gang4_tf.S(:,:,i);
%         gang4_tf.PS(:,:,i) = plant_io*gang4_tf.S(:,:,i);
%         gang4_tf.CS(:,:,i) = ctrl_model*gang4_tf.S(:,:,i);
%         
%         
%         % plot the step response for gang of four (inside the loop to use
%         % different colors)
%         figure(fh1);
%         subplot(2,2,1);
%         stepplot(gang4_tf.T(:,:,i));
%         title('T (y(s)/y\_sp(s))');grid on; hold on;
%      
%         subplot(2,2,2);
%         stepplot(gang4_tf.PS(:,:,i));
%         title('PS (y(s)/d(s))');grid on; hold on;
%     
%         subplot(2,2,3);
%         stepplot(gang4_tf.CS(:,:,i));
%         title('CS (u(s)/y\_sp(s))');grid on; hold on;
%     
%         subplot(2,2,4);
%         stepplot(gang4_tf.S(:,:,i));
%         title('S (y(s)/n(s))');grid on; hold on;
%         
%         % plot the bode plot for gang of four (inside the loop to use
%         % different colors)
%         figure(fh2);
%         subplot(2,2,1);
%         bodeplot(gang4_tf.T(:,:,i));
%         title('T (y(s)/y\_sp(s))');grid on; hold on;
%     
%         subplot(2,2,2);
%         bodeplot(gang4_tf.PS(:,:,i));
% 
%         subplot(2,2,3);
%         bodeplot(gang4_tf.CS(:,:,i));
%         title('PS (y(s)/d(s))');grid on; hold on;
%         title('CS (u(s)/y\_sp(s))');grid on; hold on;
%         
%         subplot(2,2,4);
%         bodeplot(gang4_tf.S(:,:,i));
%         title('S (y(s)/n(s))');grid on; hold on;
%         
%     end
