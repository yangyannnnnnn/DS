function sys_model_reduced = carrierReduceSSModel(sys_model, lmtGramians)
    %carrierReduceSSModel Reduce state space model.
    %
    %   [sys_model_reduced, nbrStates] = carrierReduceSSModel(sys_model, lmtGramians)
    %
    %   Reduce the number of states in system model and return the recuced system model.
    %  
    %   sys_model -   'sys_model' is a Matlab 'ss' object containing the A, B, C and D matrices
    %                   of the linear system as well as the inputs, outputs and states.
    %                   Typically created using function carrierLinearizeFMU or ss.
    %
    %   lmtGramians-  Threshold of grammians to filter states (see help balreal for more information)

    %reduce number of states
    [sys_model,g] = balreal(sys_model);                    % Compute balanced realization
    elim = (g<lmtGramians);                          % Small entries of g are negligible states
    sys_model = modred(sys_model,elim);                    % Remove negligible states
    cc = size(elim, 1) - nnz(elim);
    disp('Reduced the order of continuous state-space model from ' + string(size(elim, 1)) + ' states to ' + string(cc) + ' states');

    sys_model_reduced = sys_model;
end
