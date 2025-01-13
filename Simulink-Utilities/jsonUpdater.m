clear


proj = simulinkproject;
json_folder = fullfile(proj.RootFolder, 'MatlabFiles\DataFiles\JSON'); % folder containing JSON files

cd(json_folder)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% change to filer the files you wish to modify
json_file_filter = 'MCS_*.json';

files = dir(fullfile(json_folder, json_file_filter));
files = {files.name}';

for n=1:length(files)
    
fname = files{n};
% fname_out = insertBefore(fname, '.json', '_1');
fname_out = fname;

disp("File " + n + " of " + length(files) + ": " + fname)
pause(0.01)

json = loadjson(fname);

%% MODIFY CONFIG POINTS IN JSON FILES HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% json.Cir{1}.Compr.ComprCtrl{1}.Algo.holdStartSpdTime = 60;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

savejson('', json, fname_out);
    
    
    
end

