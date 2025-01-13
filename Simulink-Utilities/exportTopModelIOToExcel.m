function fullfile = exportTopModelIOToExcel(model,openDocWhenDone)
%exportTopModelIOToExcel(model,openDocWhenDone)
%
%Creates Excel Documentation of Bus Structures for IO on the Model. Model
%is expected to be the "Top" model used for codegen
%
%INPUTS/ARGUMENTS
% 1. model - String input of the Simulink model name. It is
%       expected that the model has 3 IO with Busses: Inputs, Configs, and
%       Outputs
% 2. openDocWhenDone  - (optional)Boolean input,open Excel doc when complete. [Default - FALSE]
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

%%Generate Excel File
filename = [p.Name '_' model '_IO_MAP.xlsx'];
fullfile=[tempdir filename];

%Write to Excel Doc
fprintf('\n<<!>> Writing Data to Excel\n')
try
    xlswrite(fullfile,data{1},'INPUTS')
    xlswrite(fullfile,data{2},'CONFIG')
    xlswrite(fullfile,data{3},'OUT')
catch
    error('Issue writing to Excel. Ensure the file [%s] is not currently open',filename)
end
fprintf('<<!>> Done Writing to [%s]\n',filename)

%Delete default sheets
sheetName = 'Sheet'; % EN: Sheet, DE: Tabelle, etc. (Lang. dependent)
% Open Excel file.
objExcel = actxserver('Excel.Application');
objExcel.Workbooks.Open(fullfile); % Full path is necessary!
% Delete sheets.
try
      % Throws an error if the sheets do not exist.
      objExcel.ActiveWorkbook.Worksheets.Item([sheetName '1']).Delete;
      objExcel.ActiveWorkbook.Worksheets.Item([sheetName '2']).Delete;
      objExcel.ActiveWorkbook.Worksheets.Item([sheetName '3']).Delete;
catch
      % Do nothing.
end
% Save, close and clean up.
objExcel.ActiveWorkbook.Save;
objExcel.ActiveWorkbook.Close;
objExcel.Quit;
objExcel.delete;

%Open Excel Doc
if openDocWhenDone
    winopen(fullfile)
else
    fprintf('\n<<!>> Excel file written to:  <a href="matlab: winopen(''%s'')">%s</a>\n',fullfile,filename)
end

fprintf('\n<<!>> Done!\n',busTypes{i})

end