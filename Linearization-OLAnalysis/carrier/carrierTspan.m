function tspan = carrierTspan()
%CARRIETTSPAN Creates a struct with default options for tspan for use with carrierSimulateFMU
% The FMU will be simulated until it reaches steady state. The FMU is simulated repeatedly, incrementally advancing the
% time. Between each simulation all state variables are compared to the their respective values in the previous time
% step. If the relative change in each state variable is below tolerance, steady state has been reached. Start time is
% 0.
%
% Properties:
% 
%     tf              - Final time for simulation. If steady state is not reached before time tf, simulation is aborted.
%                       Default is 1e5.
% 
%     step_length     - Incremental time step between each check of relative changes in state variables. Default is 200.
% 
%     hysteresis_time - Steady state detection will not start until this much time has passed. Note that this option has
%                       no effect if it's less than step_length, which it is by default. Default is 30.
% 
%     ss_tol          - Steady state has been reached if the relative change in each state is less than ss_tol. Default
%                       is 1e-5.
% 
%     ss_eps          - Relative change is computed as (x_new-x_old)/abs(x_old + ss_eps). Default is 1e-8.
    tspan = struct();
    tspan.tf = 5e3;
    tspan.step_length = 200;
    tspan.hysteresis_time = 30;
    tspan.ss_tol = 5e-3;
    tspan.ss_eps = 1e-4;
end

