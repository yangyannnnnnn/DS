function [sys, u0, y0] = carrierCreateSurrogateModel(fmuPath, tspan, parameters, u_set, y_set, p_doe, u_doe, order, ...
                                           fmuSolver, fmuRelTol, fmuAbsTol, fmuLogLevel)
%CARRIERCREATESURROGATEMODEL Simulate a DOE and create a piecewise linear system of the linearized and reduced systems
%   [sys, u0, y0] = carrierCreateSurrogateModel(fmuPath, tspan, parameters, u_set, y_set, p_doe, u_doe, order, ...
%                                               fmuSolver, fmuRelTol, fmuAbsTol, fmuLogLevel)
%
%   Simulates the FMU once for each point in the DOE, linearizes at the final time point, performs balanced order
%   reduction of the linearized system, and finally constructs a surrogate model through piecewise interpolation of the
%   linearized systems.
%
%   The DOE is constructed by full factorial sampling of all the provided values for parameters and inputs.
%
%   The outputs are the surrogate model sys, which should be used with the Simulink block LPV System from the Control
%   System Toolbox, together with the corresponding linearized input and output offsets u0 and y0, which should be used
%   to parametrize the LPV System.
%
%   Inputs:
%
%   fmuPath     - Value is a string providing the path to the FMU to be simulated.
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
%   parameters  - Value is a struct used to set the parameters of the FMU that are constant in the DOE. The struct must
%                 have the fields "name" and "values". "name" is a cell array of the names of the parameters and
%                 "values" is a cell array with the corresponding values.
%
%   u_set       - Value is a struct used to set the input signals to the FMU that are constant in the DOE. The struct
%                 must have the fields "name" and "values". "name" is a cell array of the names of the input variables
%                 and "values" is a cell array with the corresponding values.
%
%   y_set       - Value is a struct with the optional field "name". "name" is a cell array with the variable names to
%                 include in the output results 'y' and 'yname'.
%
%   p_doe       - Value is a struct used to set the parameters of the FMU that vary in the DOE. The struct must have the
%                 fields "name" and "values". "name" is a cell array of the names of the parameters and "values" is a
%                 cell array with the vector of corresponding values.
%
%   u_doe       - Value is a struct used to set the input signals to the FMU that vary in the DOE. The struct must have
%                 the fields "names" and "values". "names" is a cell array of the names of the input variables and
%                 "values" is a cell array with the corresponding values.
%
%   order       - Order of the surrogate model.
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

%setup full factorial DoE
np = length(parameters.names);
nu = length(u_set.names);
ny = length(y_set.names);
np_doe = length(p_doe.names);
nu_doe = length(u_doe.names);
doe_values = [p_doe.values, u_doe.values];
doe_mtrx = cell(1, np_doe+nu_doe);
[doe_mtrx{:}] = ndgrid(doe_values{:});
doe_vct = cellfun(@(v) reshape(v, 1, []), doe_mtrx, 'UniformOutput', false);
N = length(doe_vct{1});

%prepare data storage
A = nan(order, order, N);
B = nan(order, nu, N);
C = nan(ny, order, N);
D = nan(ny, nu, N);
u0 = nan(nu, 1, N, 1);
y0 = nan(ny, 1, N, 1);

for i = 1 : N
    %collect parameters
    parameters_i = struct();
    parameters_i.names = [parameters.names, p_doe.names];
    parameters_i.values = cell(1, np+np_doe);
    if np > 0
        parameters_i.values{1:np} = parameters.values;
    end
    for k = 1 : np_doe
        parameters_i.values{np+k} = doe_vct{k}(i);
    end
    
    %collect inputs
    u_set_i = struct();
    u_set_i.names = [u_set.names, u_doe.names];
    u_set_i.values = cell(1, nu+nu_doe);
    if nu > 0
        u_set_i.values(1:nu) = u_set.values;
    end
    for k = 1 : nu_doe
        u_set_i.values{nu+k} = doe_vct{np_doe+k}(i);
        u0(:, 1, k, 1) = doe_vct{np_doe+k}(i);
    end
    
    %simulate
    [fmu, ~, y_i, ~] = carrierSimulateFMU(fmuPath, tspan, parameters_i, u_set_i, y_set, fmuSolver, fmuRelTol, ...
                                        fmuAbsTol, fmuLogLevel);
    y0(:, 1, i, 1) = y_i(end, :);
    
    %linearize and reduce
    [sys_model, ~] = carrierLinearizeFMU(u_set.names', y_set.names', fmu);
    sysr = balred(sys_model, order);
    sysr_order = size(sysr.A,1);
    if sysr_order < order
        error_msg = sprintf("Linearized system order is %d, which is less than the specified reduced order %d " + ...
                            "for the following case:\n", sysr_order, order);
        for k = 1 : np_doe
            error_msg = error_msg + sprintf("\n\t%-30s: %.5g", parameters_i.names{k}, parameters_i.values{k});
        end
        for k = 1 : nu_doe
            error_msg = error_msg + sprintf("\n\t%-30s: %.5g", u_set_i.names{k}, u_set_i.values{k});
        end
        error(error_msg)
    end
    A(:,:,i) = sysr.A;
    B(:,:,i) = sysr.B;
    C(:,:,i) = sysr.C;
    D(:,:,i) = sysr.D;
end
sys = ss(A, B, C, D);

%reshape offsets
offset_grid = num2cell(cellfun('ndims', [p_doe.values, u_doe.values]));
u0 = reshape(u0, nu, 1, offset_grid{:});
y0 = reshape(y0, ny, 1, offset_grid{:});

%set sampling grid
sampling_grid = struct();
for k = 1 : np_doe
    sampling_grid.(p_doe.names{k}) = doe_vct{k};
end
for k = 1 : nu_doe
    sampling_grid.(u_doe.names{k}) = doe_vct{np_doe+k};
end
sys.SamplingGrid = sampling_grid;
