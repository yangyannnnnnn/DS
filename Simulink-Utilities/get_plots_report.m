function get_plots_report(ResultFolderPath,ResultFileName)

result = load([ResultFolderPath '\' ResultFileName '.mat']);
uiopen('..\..\APP_main.prj',1);
%Signal list to plot%
sig_var_list = getSigVarList();


Simulink.sdi.clear;
Simulink.sdi.view

[runID,runIndex,sigIDs] = Simulink.sdi.createRun([ResultFileName '.mat'], 'vars', result.simout); 

run_id = runID(1);
cur_run = Simulink.sdi.getRun(run_id);

% create signal name and ID map. 
name_list = {};
for i = 1: length(sigIDs)
    name_list(i) = {cur_run.getSignal(sigIDs(i)).Name};
end
signal_map = containers.Map(name_list,sigIDs);
%fig = figure;
%subplot(4,3,1);
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
       %     plot(sig_obj.Name);
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
pause(10);
%fig = Simulink.sdi.snapshot;
%saveas(fig,[ResultFolderPath '/' ResultFileName '.jpg']);
%saveas(fig,[ResultFolderPath '/' ResultFileName '.fig']);
Simulink.sdi.saveView([ResultFolderPath '/' ResultFileName '.mldatx'])

end
