function applyModelSaveSlddCb(models)

fprintf('\n>>>>>> ADDING-MODEL-SLDD_SAVE-CALLBACK <<<<<<\n\n')

try    
    if nargin<1
        applyCbToModel({'PreSaveFcn'},{'modelSaveSlddCb()'},0);
    else
        applyCbToModel({'PreSaveFcn'},{'modelSaveSlddCb()'},0,models);
    end
    
   
    warning on
catch e
    msgText = getReport(e);
    fprintf(1,'<<!e!>>There was an error! The message was:\n\n%s\n',msgText);
    fprintf('\nDone!\n')
end

