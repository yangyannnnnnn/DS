warning off
clc
clear all

%Save directory for returning when done
startDir=pwd;

try
    % Get project
    p = slproject.getCurrentProject;
    projectRoot = p.RootFolder;
   
    % JSON Files Location relative to project root
    %source = [projectRoot '\MatlabFiles\DataFiles\JSON\'];
    source1 = [projectRoot '\MatlabFiles\DataFiles\JSON\'];
    % Get JSON files
    cd(projectRoot)
    
    %src=[string(source), string(source1)];
    
    idx=1;
    %for k=1:2
        files=ls(source1);
        %files=ls(char(src(k)));
        for i=1:size(files,1)
            if any(strfind(strrep(files(i,:),' ',''),'.json'))
                jsonFiles{idx}=strrep(files(i,:),' ','');
                idx=idx+1;
            end
        end
    %end
    clear files
    
    % Check JSONS
    idx=1;
    errorText={};
    for i=1:length(jsonFiles)
        try
            fprintf('\nChecking parameters for JSON [%s]\n\n',jsonFiles{i})
            updateParams('checkJsonModel','PARAMETERS',jsonFiles{i},'AppCapCtrl_Config_t')
        catch
            errorText{idx}=sprintf('<<~>> Error with JSON file [%s]\n',jsonFiles{i});
            idx=idx+1;
        end
    end
    
    if ~isempty(errorText)
        error('%s', errorText{:})
    end
    
    fprintf('\nDone!\n')
    cd(startDir)
    
catch MExc
    cd(startDir)
    error(MExc.message)    
end

