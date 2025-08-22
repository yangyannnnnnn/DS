function [sys_model, usesDirectionalDerivatives] = carrierLinearizeFMU(u_usr, y_usr, fmu)
    %linearizeFMU Linearize fmu.
    %   [sys_model, usesDirectionalDerivatives] = linearizeFMU(u_usr, y_usr, fmu) Linearizes model around operating point after t0 seconds of simulation.
    %
    %   output 'sys_model' is a Matlab 'ss' object containing the A, B, C and D matrices
    %   of the linear system as well as the inputs, outputs and states.
    %  
    %   If u_usr and/or y_usr are set as empty string cell arrays they will automatically be found in
    %   the model. This requires them to be defined using input/output
    %   connectors on the top level of the model.
    %
    %   If the FMU provides directional derivatives the directional
    %   derivatives are used in the linearization. If the derivatives are
    %   not provided, a finite difference approximation is used.
    %  

    %determine if directional derivatives are available
    fmuCapabilities = fmu.getCapability();
    usesDirectionalDerivatives = fmuCapabilities.providesDirectionalDerivatives;

    if fmuCapabilities.providesDirectionalDerivatives
        disp("FMU contains directional derivatives which will be used in the linearization.")
    else
        disp("FMU does not provide directional derivatives. Finite difference approximation will be used.")
    end

    %get inputs
    if isvector(u_usr) && ~isempty(u_usr)
        disp("Inputs are set using function inputs defined in function call.")
        inputs = fmu.getScalarVariable(u_usr);
    else
        disp("No inputs defined in function call. Inputs will be automatically found in model.")
        inputs = fmu.getInputs();
    end
    inputs_vr = inputs.valueReference;
    nu = length(inputs);

    %get outputs
    if isvector(y_usr) && ~isempty(y_usr)
        disp("Outputs are set using function inputs defined in function call.")
        outputs = fmu.getScalarVariable(y_usr);
    else
        disp("No outputs defined in function call. Outputs will be automatically found in model.")
        outputs = fmu.getOutputs();
    end
    outputs_vr = outputs.valueReference;
    ny = length(outputs);

    %get states
    states = fmu.getStates();
    states_vr = states.valueReference;
    nx = length(states);

    %get derivatives
    derivatives = fmu.getDerivatives();
    derivatives_vr = derivatives.valueReference;

    %calculate A matrix
    A = nan(nx);
    for i = 1:nx
         A(:, i) = fmu.fmiGetDirectionalDerivative(states_vr(i), derivatives_vr, 1);
    end

    %calculate B matrix
    B = nan(nx, nu);
    for i = 1:nu
         B(:, i) = fmu.fmiGetDirectionalDerivative(inputs_vr(i), derivatives_vr, 1);
    end

    %calculate C matrix
    C = nan(ny, nx);
    for i = 1:nx
         C(:, i) = fmu.fmiGetDirectionalDerivative(states_vr(i), outputs_vr, 1);
    end

    %calculate D matrix
    D = nan(ny, nu);
    for i = 1:nu
         D(:, i) = fmu.fmiGetDirectionalDerivative(inputs_vr(i), outputs_vr, 1);
    end

    sys_model_ = {};
    sys_model_.u = cell(1,nu);
    sys_model_.y = cell(1,ny);
    sys_model_.x = cell(1,nx);

    for i = 1:nx
        sys_model_.x{i} = states(i).name;
    end

    for i = 1:nu
       sys_model_.u{i} = inputs(i).name;
    end

    for i = 1:ny
        sys_model_.y{i} = outputs(i).name;
    end

    sys_model_.A = A;
    sys_model_.B = B;
    sys_model_.C = C;
    sys_model_.D = D;

    %return ss object
    sys_model = ss(A, B, C, D, 'InputName',  sys_model_.u, 'OutputName', sys_model_.y, 'StateName', sys_model_.x);
end