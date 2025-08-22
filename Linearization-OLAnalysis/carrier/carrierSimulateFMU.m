function [fmu, t, u, y, yname] = carrierSimulateFMU(fmuPath, tspan, parameters, u_set, y_set, fmuSolver, fmuRelTol, ...
                                                 fmuAbsTol, PIctrl, fmuLogLevel)
%carrierSimulateFMU Simulate FMU
%   [fmu, tout, uout, yout, yname] = carrierSimulateFMU(fmuPath, tspan, parameters, u_set, y_set, fmuSolver, fmuRelTol, 
%                                                 fmuAbsTol, PIctrl, fmuLogLevel)
%
%   Simulate an FMU and return the fmu object, time array, input values, output values and output names.
%  
%   tspan       - Value can take three forms:
%                     A vector of two elements [T0 TF] simulates from time T0 to TF and returns the solution at the time
%                     points selected by the solver.
% 
%                     A vector of more than two elements [T0 T1 ... TF] simulates from time T0 to TF and returns the
%                     solution at the specified time points.
% 
%                     A struct of options for simulating until the system reaches steady state. The struct should be
%                     created by the function carrierTspan. See the documentation of carrierTspan for details.
%
%   u_set       - Value is a cell array with structs used to set the input signals to the FMU. The struct must have the
%                 fields "name" and one of "vec" and "fcn". "name" is set to the name of the input variable. The field
%                 "vec" is used if the input data is provided in a vector where the first column is the sample times and
%                 the second is the data values. "fcn" is used if the input signal is provided with a function handle.
%                 The function handle takes the time as input argument and the output is the value to set. If no input
%                 signals are set, u_set can be an empty array.
%
%   y_set       - Value is a struct with the optional field "name". "name" is a cell array with the variable names to
%                 include in the output results 'yout' and 'yname'. 
%
%   fmuSolver   - Value is set to the name of the solver used. It can be one of: 'ode45','ode23','ode113','ode15s',
%                 'ode23s','ode23t','ode23tb'.
%
%   fmuRelTol   - Relative tolerance of solver.
%
%   fmuAbsTol   - Absolute tolerance of solver.
%
%   fmuLogLevel - FMU log level. Optional, default is 'warning'.

if ~exist('fmuLogLevel', 'var')
    fmuLogLevel = 'warning';
end

fmu = loadFMU(fmuPath, 'loglevel', fmuLogLevel, 'kind', 'me');
disp("Loaded FMU of type " + fmu.internal.fmuType + " generated using " + fmu.getGenerationTool() + ".")
disp("Proceeding with initialization...") 
fmu.initialize();
disp("FMU initialized.")

%set parameters
%
if ~isempty(parameters.names)
    fmu.set(parameters.names, parameters.values)
end
%
%set constant inputs as starting points
nu = length(u_set.names);
input = cell(1, nu);
mv = zeros(1,nu); %manipulated variables
for k = 1 : nu
    input{k}.name = u_set.names{k};
    input{k}.fcn = @(t) u_set.values{k};
    mv(k) = u_set.values{k};
end
err = zeros(1,nu); %initial error values for PI controllers

%set output vector
states = fmu.getStates();
ny = length(y_set.names);
yname = y_set.names;
output.toplevel = false; %do not include default output variables
output.writefile = false; %do not generate a result file

% set initial value of input vector
u = mv;

disp("Simulating: " + fmuPath) 

%simulate
options = odeset('RelTol', fmuRelTol, 'AbsTol', fmuAbsTol);
if isstruct(tspan) % simulate until steady state
    %get steady state options
    tf = tspan.tf;
%     step_length = tspan.step_length;
    step_length = PIctrl.time_inteval;%use PI controller time interval as simulation time step
    hysteresis_time = tspan.hysteresis_time;
    ss_tol = tspan.ss_tol;
    ss_eps = tspan.ss_eps;
    transient = true;
    xn = fmu.get(states)';
    y = fmu.get(y_set.names);
    t = 0;
    tn = 0;
    output.name = [yname, states.name']; %add states to solver output
    
    %simulate until steady state
    i = 0;
    while transient
        %simulate one step
        i = i + 1;
        xn_old = xn;
%         y1_old = y(end,1);
        err_old = err;
        mv_old = mv;
        [tout, yout, ~] = fmu.simulate([tn, tn+step_length], 'FREE_AFTER_SIMULATION', false, 'Solver', fmuSolver, 'OPTIONS', options, 'Input', input, 'Output', output);
        xn = yout(end, ny+1:end);
        yn = yout(end, 1:ny);
        tn = tout(end);
        t(end+1) = tn; %#ok<AGROW>
        y(end+1,:) = yout(end, 1:ny); %#ok<AGROW>
        
        % calculate mv values from PI controllers for closed-loops
        for k = 1 : nu
            if y_set.closeloop{k} == 1
                [mv(k), err(k)] = carrierPIcontroller(y_set.refvalues{k}, yn(k), PIctrl.kp_values{k}, PIctrl.ti_values{k}, PIctrl.time_inteval, u_set.ub_values{k},...
                    u_set.lb_values{k}, mv_old(k), err_old(k));
                input{k}.fcn = @(t) mv(k);
            else
                mv(k) = mv_old(k);
            end
        end
        u = [u;mv];
        
        %check steady state
        if tn > hysteresis_time
            reldiff = (xn-xn_old) ./ (abs(xn_old)+ss_eps);
            if max(abs(reldiff)) < ss_tol %all states steady
                transient = false;
                steady_state = true;
            elseif tn > tf %final time reached without steady state
                transient = false;
                steady_state = false;
            else
                if mod(i, 50) == 0 %print unsteady states
                    unsteady_states = states.name{abs(reldiff) > ss_tol}
                    fprintf("Number of unsteady states at time %.3g s: %d.\n", tn, length(unsteady_states))
                end
            end
        end
    end
    if steady_state
        fprintf("Steady state reached after %.2f seconds.\n", tn)
    else
        disp("Failed to reach steady state.")
        fprintf("Unstable state is: ", unsteady_states)
        %pause(1e4);
    end
else %simulate with fixed time
    output.name = yname;
    [t, y, yname] = fmu.simulate(tspan, 'FREE_AFTER_SIMULATION', false, 'Solver', fmuSolver, 'OPTIONS', options, ...
                                 'Input', input, 'Output', output);
    u = [];
    for k = 1:nu
        u = [u,u_set.values{k}*ones(length(t),1)];
    end
end


