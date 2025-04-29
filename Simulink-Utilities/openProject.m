%OPENPROJECT Script to run during project startup)

clc;
clearvars -except product;
clear mex;
clear functions;
bdclose all;
disp('Opening Cascade Project');

%% Check software version
properVerison_ = 'R2024a';
matlabVersion_ = matlabRelease.Release;
if isempty(matlabVersion_) || ~strcmp(matlabVersion_,properVerison_)
    errordlg('Matlab version is not compatible with project. Please open with v2024a.')
end

%rootPath_ = fileparts(mfilename('fullpath'));
project_=simulinkproject;
rootPath_=fullfile(project_.RootFolder);

%% Setup temperary folder for generated files
Simulink.fileGenControl('set',...
    'CacheFolder', fullfile(rootPath_,'work'),...
    'CodeGenFolder', fullfile(rootPath_, 'work'),...
    'createDir', true)

%% Finish
cd(rootPath_)
disp('Project initialized.')

% Clear all local variables (ending with '_' symbol
clear -regexp '^[a-zA-Z][\w]*_$'