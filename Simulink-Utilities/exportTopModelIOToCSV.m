function fullfile = exportTopModelIOToCSV(model,openDocWhenDone)
%exportTopModelIOToExcel(model,openDocWhenDone)
%
%Creates CSV Documentation of Bus Structures for IO on the Model. Model
%is expected to be the "Top" model used for codegen
%
%INPUTS/ARGUMENTS
% 1. model - String input of the Simulink model name. It is
%       expected that the model has 3 IO with Busses: Inputs, Configs, and
%       Outputs
% 2. openDocWhenDone  - (optional)Boolean input,open CSV doc when complete. [Default - FALSE]
%       If left empty, a link to the document will be printed to the Command Window


%Check for Arguments
if ~exist('openDocWhenDone')
    openDocWhenDone=false;
end

clc
%Get project name
p = slproject.getCurrentProject;
projectRoot = p.RootFolder;

%%Extract Bus Types from Top Model Ports
[busNames busTypes] = portBusTypeExtractor(model);

%%Extract Bus Data
fprintf('<<!>> Extracting Bus Data From Model\n')
for i=1:length(busNames)
    fprintf('\t>> Extracting [%s]\n',busTypes{i})
    data{i}      = busHierarchyInfoExport('Controls_Service',busTypes{i},busNames{i},true,false);
end
fprintf('<<!>> Extracting Done\n',busTypes{i})

%%Generate CSV File
filename{1} = [p.Name '_' model '_IO_MAP_INPUTS.csv'];
filename{2} = [p.Name '_' model '_IO_MAP_CONFIG.csv'];
filename{3} = [p.Name '_' model '_IO_MAP_OUT.csv'];
fullfile{1}=[tempdir filename{1}];
fullfile{2}=[tempdir filename{2}];
fullfile{3}=[tempdir filename{3}];

%Write to CSV Doc
fprintf('\n<<!>> Writing Data to CSV');
for i=1:3
    fprintf('\n\t>> Writing Data to [%s]',fullfile{i});
    stdVarNames = replace(data{i}(1,:),"/",'_');
    stdVarNames = replace(stdVarNames," ",'_');
    stdData = cell(size(data{i}(2:end,:),1) ,size(data{i}(2:end,:),2) );
    for j = 1:size(data{i}(2:end,:),2) 
        if iscellstr(data{i}(2,j))
            stdData(:,j) = replace(data{i}(2:end,j),newline,'');
        elseif isnumeric(data{i}{2,j})
            stdData(:,j) = cellfun(@num2str,data{i}(2:end,j),'un',0);
            stdData(:,j) = strcat({'['}, stdData(:,j), {']'} );
        else
            stdData(:,j) = data{i}(2:end,j);
        end
    end
    IOMapTable{i} = cell2table(stdData,'VariableNames', stdVarNames);
    try
        writetable(IOMapTable{i}, fullfile{i},'Delimiter','\t');  
        fprintf('\n\t>> Done Writing to [<a href="matlab: winopen(''%s'')">%s</a>]',fullfile{i},filename{i});
    catch
        error('Issue writing to CSV. Ensure the file [%s] is not currently open',filename{i})        
    end
end

%Open CSV Doc
if openDocWhenDone
    winopen(fullfile{:})
end

fprintf('\n<<!>> Done!\n\n',busTypes{i})

end