function updateParamstoHarness(jsonfile, modelName)
if nargin<1
    jsonfile = 'MCS_V30T_FS_Parameters.json';
end
if nargin<2
    modelName = 'APP_Test_Harness_src_NUMERICAL';
end

configType = 'AppCapCtrl_Config_t';  % bus object to populate with parameters in JSON file
varName = 'PARAMETERS'; % variable name to assign in model workspace, that is used by constant block in model


warning off
load_system(modelName);

%Get SLDD
dict_name = get_param(modelName,'DataDictionary');
hDict = Simulink.data.dictionary.open([dict_name]);
dataSectObj = getSection(hDict,'Design Data');

pStruct = [];
dim = [1,1];
scope = Simulink.data.DataDictionary(dict_name);

busStruct = Simulink.Bus.createMATLABStruct(configType, pStruct, dim, scope);


%Parameter load
PARAMETERS = Simulink.Parameter;
% myStruct=loadjson('Parameters.json','SimplifyCell',1);
myStruct=loadjson(jsonfile,'SimplifyCell',1);
fprintf('<<!>> Loaded parameters from: %s\n',jsonfile);

StructToSort = myStruct;
StructToMatch = busStruct;

myStruct = orderAllFields(StructToSort,StructToMatch);

myStruct = structEnumConverter(myStruct,busStruct);

PARAMETERS.Value = myStruct;
PARAMETERS.CoderInfo.StorageClass = 'Auto';
PARAMETERS.Description = '';
PARAMETERS.DataType = configType;
PARAMETERS.Min = [];
PARAMETERS.Max = [];
PARAMETERS.DocUnits = '';

% Load parameter onto model
src_mws = get_param(modelName,'ModelWorkspace');
clear(src_mws,varName);
assignin(src_mws,varName,PARAMETERS);
% try
%     save_system(modelName);
% end
fprintf('<<!>> Parameter [%s] assigned on model [%s]\n','PARAMETER',modelName);
%clear PARAMETERS

% run the following command if updating in real time
run=strcmp(get_param(modelName,'SimulationStatus'),'running');
if run
    fprintf('<<!>> Pausing model [%s] to apply parameters...\n',modelName);
    set_param(modelName, 'SimulationCommand', 'pause')
end
paused=strcmp(get_param(modelName,'SimulationStatus'),'paused');
if run|paused
    fprintf('<<!>> Performing update on model [%s]...\n',modelName);
    set_param(modelName, 'SimulationCommand', 'update');
%     if paused
%         set_param(modelName, 'SimulationCommand', 'continue');
%         fprintf('<<!>> Resuming simulation of model [%s] ...\n',modelName);
%     end
end

fprintf('<<!>> Done!\n');
warning on