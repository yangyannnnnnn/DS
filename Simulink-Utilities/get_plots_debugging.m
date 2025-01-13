% This script is used to plot sig_var_list in data inspector for latest
% run.

Simulink.sdi.view

sig_var_list = getSigVarList();

run_id = Simulink.sdi.getAllRunIDs;
cur_run = Simulink.sdi.getRun(run_id(end));

% create signal name and ID map. 
sig_count = double(cur_run.SignalCount());
name_list = cell(sig_count,1);
sigIDs = cell(sig_count,1);

fprintf('Populating signal list from SDI session id %d containing %d signals...\n% 12s\n', cur_run.id, sig_count, '0% complete')
update_every = round(sig_count/100);
for i = 1: sig_count
    if mod(i, update_every)==0
        fprintf([repmat('\b', 1, 13), '% 12s\n'], [num2str(round(i/sig_count*100)) '% complete'])
    end
    temp = getSignalByIndex(cur_run,i);
    name_list(i) = {temp.Name};
    sigIDs(i) = {temp.ID};
end
signal_map = containers.Map(name_list,sigIDs);

% plot signals 
Simulink.sdi.setSubPlotLayout(4,3);
for i = 1: size(sig_var_list, 1)
    for j = 1: size(sig_var_list, 2)
        sig_vars = sig_var_list{i, j};
        for k = 1:length(sig_vars)
            try
            if(signal_map.isKey(sig_vars{k}))
               sig_id = signal_map(sig_vars{k});
            sig_obj = Simulink.sdi.getSignal(sig_id);
            plotOnSubPlot(sig_obj,i,j,true);
             else 
                     warning('The %s variable is not available in this log file',sig_vars{k});
                end
            catch ME
                if strcmp(ME.identifier,'MATLAB:Containers:Map:NoKey')
                    error('The %s variable is not available in this log file',sig_vars{k});
                end 
            end
        end
    end
end

