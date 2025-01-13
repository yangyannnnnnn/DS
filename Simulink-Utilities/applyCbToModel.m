function applyCbToModel (callbackFcn,callbackText,rewriteTrue,models)

%%
warning off
if nargin<4
    [files PathName] = uigetfile('*.slx','MultiSelect', 'on');    
else
    if iscell(models)
        [PathName files ~]=cellfun(@(x) fileparts([x '.slx']),models,'UniformOutput',false);
    else
        [PathName files ~] = fileparts(models);
    end
end

try
    cd(PathName)
end

if iscell(files)
    dim1=length(files);
else
    dim1=1;
end

if iscell(callbackFcn)
    dim2=length(callbackFcn);
else
    dim2=1;
end

for i=1:dim1
    if iscell(files)
        mySys = files{i};
    else
        mySys = files;
    end
    
    fprintf('Parsing model [%s]...\n',mySys)
    
    
    for j=1:dim2
        sys_h = load_system(mySys);
        
        
        if iscell(callbackFcn)
            cbFn  = callbackFcn{j};
            cbTxt = callbackText{j};
        else
            cbFn  = callbackFcn;
            cbTxt = callbackText;
        end
        
        mh = get_param(sys_h,'handle');
        existing = get(mh,cbFn);
        if ~any(strfind(cbTxt,';'))
            cbTxt=[cbTxt,';'];
        end
        if ~any(strfind(existing,cbTxt))
            if rewriteTrue
                set_param(mh,cbFn,[cbTxt]);
            else
                set_param(mh,cbFn,[get(mh,cbFn),cbTxt]);
            end
            fprintf('\t>>> Callback [''%s''] added to [%s] on model [%s].\n',cbTxt,cbFn,mySys)
        else
            fprintf('\t<!> Callback [''%s''] already exists for [%s] on model [%s], skipping...\n',cbTxt,cbFn,mySys)
        end
        
        try
            if bdIsDirty(bdroot)
                save_system(mySys)
            else
                close_system(bdroot)
            end
        catch MException
            fprintf('\tError saving system:\n')
            rethrow(MException)
        end
        
        
    end
end
fprintf('Done!\n')
warning on

