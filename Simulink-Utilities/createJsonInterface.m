function createJsonInterface(model, directory)
clc
if nargin<1
    error('<<!>> No Model defined, provide model name as string input')
elseif nargin<2
    directory=pwd;
end
%[myDir, ~, ~] = fileparts(which(mfilename('fullpath')));
if ~exist(directory, 'dir')
       mkdir(directory)
end
cd(directory)
[busNames busTypes] = portBusTypeExtractor(model);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load_system(model)
dict_name = get_param(model,'DataDictionary');
close_system(model)


for i=1:length(busTypes)
    jsonIface(busTypes{i},busNames{i},dict_name);
end

clear types names n myDir i hEntry hDict hDesignData dict_name

    function jsonIface(type,name,dict_name)
        
        scope = Simulink.data.DataDictionary(dict_name);
        pStruct=[];
        dim=[1,1];
        
        % Convert to struct (SLDD scope)
        busStruct = Simulink.Bus.createMATLABStruct(type, pStruct, dim, scope);
        
        %Create JSON file
        marker = strrep(char(datetime),' ','_');
        marker = strrep(marker,':','_');
        marker = ['moved_on_' strrep(marker,'-','_')];
        filename1=[name '.json'];
        filename2=[name '_typeMap.m'];
        if exist([pwd '\' filename1],'file') == 2
            filename1_new=[name '_' marker '.json'];
            mkdir('.previous');
            % stash old file and addend name
            movefile([pwd '\' filename1],[pwd '\.previous\' filename1_new],'f')
            fprintf('>> Created JSON file (existing detected, old file moved with timestamp added and placed in "previous" folder): %s\n',filename1)
            savejson('',busStruct,'FileName',filename1,'NestArray',1);
        else
            savejson('',busStruct,'FileName',filename1,'NestArray',1);
            fprintf('>> Created JSON file: %s\n',filename1)
        end
        
        if exist([pwd '\' filename2],'file') == 2
            filename2_new=[name '_' marker '_typeMap.m'];
            mkdir('.previous');
            % stash old file and addend name
            movefile([pwd '\' filename2],[pwd '\.previous\' filename2_new],'f')
            fprintf('>> Created JSON file (existing detected, old file moved with timestamp added and placed in "previous" folder): %s\n',filename2)
            matlab.io.saveVariablesToScript(filename2,'busStruct')
        else
            matlab.io.saveVariablesToScript(filename2,'busStruct')
            fprintf('>> Created type map file: %s\n',filename2)
        end
        
        
        
        
        
    end

end








