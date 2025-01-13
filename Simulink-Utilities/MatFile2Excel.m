function MatFile2Excel(filename)
% MATFILE2EXCEL extracts signals from MAT (for Viper)
%
%simout is the simulation output from the .mat file
%filename shall have the .mat at the end
%filename = 'ADO_046A_115F_SDT_protection.mat';
load_system('ART_Capacity_Control') 
dataIn = load(filename);
%try
    %simout = dataIn.simout;
%    DEF = dataIn.DEF;
%catch
%    simout.logsout = dataIn;
%    save([filename,'.mat'],'simout');
    DEF = [];
%end
logsoutfile = dataIn.logsout; %extracting logsout from the simout
%logsoutfile = simout.logsout.simout.logsout;

%%
%Writing the data into a matrix
i = 0;
i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.OAT.Time; Names{i} = 'Time';
L=length(Matrix(:,i));

i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.OAT.data(1:L); Names{i} = 'OAT';
i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.OARH.data(1:L); Names{i} = 'OARH';

i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.RAT.data(1:L); Names{i} = 'RAT';
i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.SAT.data(1:L); Names{i} = 'SAT';
i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.CCT.data(1:L); Names{i} = 'CCT';
i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.RARH.data(1:L); Names{i} = 'RARH';

i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.SDT_A.data(1:L); Names{i} = 'SDT_A';
i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.SDT_B.data(1:L); Names{i} = 'SDT_B';
i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.SST_A.data(1:L); Names{i} = 'SST_A';
i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.SST_B.data(1:L); Names{i} = 'SST_B';

i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.SSH_A1.data(1:L); Names{i} = 'SSH_A1';
i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.SSH_A2.data(1:L); Names{i} = 'SSH_A2';
i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.SSH_B1.data(1:L); Names{i} = 'SSH_B1';
i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.SSH_B2.data(1:L); Names{i} = 'SSH_B2';

i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.SACFM.data(1:L); Names{i} = 'SACFM';
i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.OACFM.data(1:L); Names{i} = 'OACFM';
i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.EACFM.data(1:L); Names{i} = 'EACFM';

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.Sys.Telem.MixAirTempEstim.mixAirTempEstim.data(1:L); Names{i} = 'mixAirTempEstim';


%% ODF
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(1).CondFanVarCtrl.Telem.ctrlLogic.V1.satDischTempOptStpt.data(1:L); Names{i} = 'CondFan1_satDischTempOptStpt';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(2).CondFanVarCtrl.Telem.ctrlLogic.V1.satDischTempOptStpt.data(1:L); Names{i} = 'CondFan2_satDischTempOptStpt';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(2).CondFanVarCtrl.Telem.ctrlLogic.V1.satDischTempLowLimit.data(1:L); Names{i} = 'CondFan1_satDischTempLowLimit';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(2).CondFanVarCtrl.Telem.ctrlLogic.V1.satDischTempLowLimit.data(1:L); Names{i} = 'CondFan2_satDischTempLowLimit';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(2).CondFanVarCtrl.Telem.ctrlLogic.V1.satDischTempHighLimit.data(1:L); Names{i} = 'CondFan1_satDischTempHighLimit';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(2).CondFanVarCtrl.Telem.ctrlLogic.V1.satDischTempHighLimit.data(1:L); Names{i} = 'CondFan2_satDischTempHighLimit';

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(1).CondFanVarCtrl.Ctrl.cmd.data(1:L); Names{i} = 'CondFan1_cmd';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(2).CondFanVarCtrl.Ctrl.cmd.data(1:L); Names{i} = 'CondFan2_cmd';

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(1).CondFanVarCtrl.Ctrl.currObjtve.data(1:L); Names{i} = 'CondFan1_currObjtve';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(2).CondFanVarCtrl.Ctrl.currObjtve.data(1:L); Names{i} = 'CondFan2_currObjtve';

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(1).CondFanVarCtrl.Ctrl.mode.data(1:L); Names{i} = 'CondFan1_mode';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(2).CondFanVarCtrl.Ctrl.mode.data(1:L); Names{i} = 'CondFan2_mode';

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(1).CondFanVarCtrl.CompoData.Info.state.data(1:L); Names{i} = 'CondFan1_state';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(2).CondFanVarCtrl.CompoData.Info.state.data(1:L); Names{i} = 'CondFan2_state';

i=i+1;Matrix(:,i) = squeeze(logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(1).IndvContcr.contcrReqPctArray.data(1,1,1:L)); Names{i} = 'CondFan1_contcrReqPctArray1';
i=i+1;Matrix(:,i) = squeeze(logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(1).IndvContcr.contcrReqPctArray.data(1,2,1:L)); Names{i} = 'CondFan1_contcrReqPctArray2';
i=i+1;Matrix(:,i) = squeeze(logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(1).IndvContcr.contcrReqPctArray.data(1,3,1:L)); Names{i} = 'CondFan1_contcrReqPctArray3';
i=i+1;Matrix(:,i) = squeeze(logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(1).IndvContcr.contcrReqPctArray.data(1,4,1:L)); Names{i} = 'CondFan1_contcrReqPctArray4';
i=i+1;Matrix(:,i) = squeeze(logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(1).IndvContcr.contcrReqPctArray.data(1,5,1:L)); Names{i} = 'CondFan1_contcrReqPctArray5';
i=i+1;Matrix(:,i) = squeeze(logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(1).IndvContcr.contcrReqPctArray.data(1,6,1:L)); Names{i} = 'CondFan1_contcrReqPctArray6';
i=i+1;Matrix(:,i) = squeeze(logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(2).IndvContcr.contcrReqPctArray.data(1,1,1:L)); Names{i} = 'CondFan2_contcrReqPctArray1';
i=i+1;Matrix(:,i) = squeeze(logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(2).IndvContcr.contcrReqPctArray.data(1,2,1:L)); Names{i} = 'CondFan2_contcrReqPctArray2';
i=i+1;Matrix(:,i) = squeeze(logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(2).IndvContcr.contcrReqPctArray.data(1,3,1:L)); Names{i} = 'CondFan2_contcrReqPctArray3';
i=i+1;Matrix(:,i) = squeeze(logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(2).IndvContcr.contcrReqPctArray.data(1,4,1:L)); Names{i} = 'CondFan2_contcrReqPctArray4';
i=i+1;Matrix(:,i) = squeeze(logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(2).IndvContcr.contcrReqPctArray.data(1,5,1:L)); Names{i} = 'CondFan2_contcrReqPctArray5';
i=i+1;Matrix(:,i) = squeeze(logsoutfile.getElement('CTRL_OUT').Values.AmbXferFluidCir.CondFan(2).IndvContcr.contcrReqPctArray.data(1,6,1:L)); Names{i} = 'CondFan2_contcrReqPctArray6';

%% MechHeatXferCir

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.Data.capacityRequest_pct.data(1:L); Names{i} = 'capacityRequest_pct';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.Data.capacityActual_pct.data(1:L); Names{i} = 'capacityActual_pct';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.Data.capacityActual_tons.data(1:L); Names{i} = 'capacityActual_tons';

% RefCir
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Data.state.data(1:L); Names{i} = 'RefCir1_state'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Data.state.data(1:L); Names{i} = 'RefCir2_state';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Compn.OilRcvr.Data.oilRecvryActive.data(1:L); Names{i} = 'oilRecvryActive1';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Compn.OilRcvr.Data.oilRecvryActive.data(1:L); Names{i} = 'oilRecvryActive2';

% EXV
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Meter.MainExvCtrl(1).Ctrl.currObjtve.data(1:L); Names{i} = 'EXVA1_currObjtve';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Meter.MainExvCtrl(2).Ctrl.currObjtve.data(1:L); Names{i} = 'EXVA2_currObjtve';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Meter.MainExvCtrl(1).Ctrl.currObjtve.data(1:L); Names{i} = 'EXVB1_currObjtve';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Meter.MainExvCtrl(2).Ctrl.currObjtve.data(1:L); Names{i} = 'EXVB2_currObjtve';

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Meter.MainExvCtrl(1).Ctrl.cmd.data(1:L); Names{i} = 'EXVA1_cmd';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Meter.MainExvCtrl(2).Ctrl.cmd.data(1:L); Names{i} = 'EXVA2_cmd';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Meter.MainExvCtrl(1).Ctrl.cmd.data(1:L); Names{i} = 'EXVB1_cmd';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Meter.MainExvCtrl(2).Ctrl.cmd.data(1:L); Names{i} = 'EXVB2_cmd';

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Meter.MainExvCtrl(1).Ctrl.mode.data(1:L); Names{i} = 'EXVA1_mode';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Meter.MainExvCtrl(2).Ctrl.mode.data(1:L); Names{i} = 'EXVA2_mode';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Meter.MainExvCtrl(1).Ctrl.mode.data(1:L); Names{i} = 'EXVB1_mode';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Meter.MainExvCtrl(2).Ctrl.mode.data(1:L); Names{i} = 'EXVB2_mode';

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Meter.MainExvCtrl(1).CompoData.Info.state.data(1:L); Names{i} = 'EXVA1_state';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Meter.MainExvCtrl(2).CompoData.Info.state.data(1:L); Names{i} = 'EXVA2_state';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Meter.MainExvCtrl(1).CompoData.Info.state.data(1:L); Names{i} = 'EXVB1_state';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Meter.MainExvCtrl(2).CompoData.Info.state.data(1:L); Names{i} = 'EXVB2_state';

i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.exvMain_A1.data(1:L); Names{i} = 'EXVA1_msm';
i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.exvMain_A2.data(1:L); Names{i} = 'EXVA2_msm';
i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.exvMain_B1.data(1:L); Names{i} = 'EXVB1_msm';
i=i+1;Matrix(:,i) = logsoutfile.getElement('PLANT_OUT').Values.exvMain_B2.data(1:L); Names{i} = 'EXVB2_msm';

% Comp
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Compn.Compr(1).ComprCtrl.Telem.Ctrl.V1.fluidTempStpt.data(1:L); Names{i} = 'CompA1_fluidTempStpt';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Compn.Compr(2).ComprCtrl.Telem.Ctrl.V1.fluidTempStpt.data(1:L); Names{i} = 'CompA2_fluidTempStpt';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Compn.Compr(1).ComprCtrl.Telem.Ctrl.V1.fluidTempStpt.data(1:L); Names{i} = 'CompB1_fluidTempStpt';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Compn.Compr(2).ComprCtrl.Telem.Ctrl.V1.fluidTempStpt.data(1:L); Names{i} = 'CompB2_fluidTempStpt';

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Compn.Compr(1).ComprCtrl.Ctrl.cmd.data(1:L); Names{i} = 'CompA1_cmd';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Compn.Compr(2).ComprCtrl.Ctrl.cmd.data(1:L); Names{i} = 'CompA2_cmd';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Compn.Compr(1).ComprCtrl.Ctrl.cmd.data(1:L); Names{i} = 'CompB1_cmd';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Compn.Compr(2).ComprCtrl.Ctrl.cmd.data(1:L); Names{i} = 'CompB2_cmd';

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Compn.Compr(1).ComprCtrl.Ctrl.mode.data(1:L); Names{i} = 'CompA1_mode';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Compn.Compr(2).ComprCtrl.Ctrl.mode.data(1:L); Names{i} = 'CompA2_mode';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Compn.Compr(1).ComprCtrl.Ctrl.mode.data(1:L); Names{i} = 'CompB1_mode';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Compn.Compr(2).ComprCtrl.Ctrl.mode.data(1:L); Names{i} = 'CompB2_mode';

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Compn.Compr(1).ComprCtrl.Ctrl.currObjtve.data(1:L); Names{i} = 'CompA1_currObjtve';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Compn.Compr(2).ComprCtrl.Ctrl.currObjtve.data(1:L); Names{i} = 'CompA2_currObjtve';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Compn.Compr(1).ComprCtrl.Ctrl.currObjtve.data(1:L); Names{i} = 'CompB1_currObjtve';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Compn.Compr(2).ComprCtrl.Ctrl.currObjtve.data(1:L); Names{i} = 'CompB2_currObjtve';

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Compn.Compr(1).ComprCtrl.CompoData.Info.state.data(1:L); Names{i} = 'CompA1_state';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(1).Compn.Compr(2).ComprCtrl.CompoData.Info.state.data(1:L); Names{i} = 'CompA2_state';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Compn.Compr(1).ComprCtrl.CompoData.Info.state.data(1:L); Names{i} = 'CompB1_state';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.MechHeatXfer.RefCir(2).Compn.Compr(2).ComprCtrl.CompoData.Info.state.data(1:L); Names{i} = 'CompB2_state';


%% ZoneXferFluidCir

% IDF 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.SplyFan.splyFan.Ctrl.cmd.data(1:L); Names{i} = 'splyFan_cmd';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.SplyFan.splyFan.Ctrl.mode.data(1:L); Names{i} = 'splyFan_mode';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.SplyFan.splyFan.CompoData.Info.state.data(1:L); Names{i} = 'splyFan_state';

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_IN').Values.ZoneXferFluidCir.SupFan.Msm.Gen.splyAirFlowRate.data(1:L); Names{i} = 'splyFan_airFlowrate';

% Dehum
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Dehum.ReheatValve.Telem.CtrlLogic.V1.splyAirTempStpt.data(1:L); Names{i} = 'ReheatValve_splyAirTempStpt'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Dehum.ReheatValve.Ctrl.cmd.data(1:L); Names{i} = 'ReheatValve_cmd'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Dehum.ReheatValve.Ctrl.mode.data(1:L); Names{i} = 'ReheatValve_mode'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Dehum.ThreeWayValve.Ctrl.cmd.data(1:L);  Names{i} = 'ThreeWayValve_cmd'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Dehum.ThreeWayValve.Ctrl.mode.data(1:L); Names{i} = 'ThreeWayValve_mode'; 

% Econ 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Vent.Econ.Ctrl.cmd.data(1:L); Names{i} = 'Econ_cmd'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Vent.Econ.Ctrl.mode.data(1:L); Names{i} = 'Econ_mode'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Vent.Econ.Ctrl.currObjtve.data(1:L); Names{i} = 'Econ_currObjtve'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Vent.Econ.CompoData.Info.state.data(1:L); Names{i} = 'Econ_state'; 

% Energy Recovery Wheel
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Vent.EnergyRecvryVent.Ctrl.ervWheelCmd.data(1:L); Names{i} = 'ERV_cmd';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Vent.EnergyRecvryVent.Ctrl.mode.data(1:L); Names{i} = 'ERV_mode';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Vent.EnergyRecvryVent.CompoData.Info.state.data(1:L); Names{i} = 'ERV_state';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Vent.EnergyRecvryVent.Ctrl.ervBypassDamperOn.data(1:L); Names{i} = 'ervBypassDamperOn';

% Return Fan
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.RetFan.RetFan.Ctrl.cmd.data(1:L); Names{i} = 'RetFan_cmd';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.RetFan.RetFan.Ctrl.mode.data(1:L); Names{i} = 'RetFan_mode';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.RetFan.RetFan.Ctrl.currObjtve.data(1:L); Names{i} = 'RetFan_currObjtve';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.RetFan.RetFan.CompoData.Info.state.data(1:L); Names{i} = 'RetFan_state';

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_IN').Values.ZoneXferFluidCir.RetFan.Msm.Gen.airFlowrate.data(1:L); Names{i} = 'RetFan_airFlowrate';

% Exhaust Fan
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.ExhFan.ExhFan.Ctrl.cmd.data(1:L); Names{i} = 'ExhFan_cmd';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.ExhFan.ExhFan.Ctrl.mode.data(1:L); Names{i} = 'ExhFan_mode';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.ExhFan.ExhFan.Ctrl.currObjtve.data(1:L); Names{i} = 'ExhFan_currObjtve'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.ExhFan.ExhFan.CompoData.Info.state.data(1:L); Names{i} = 'ExhFan_state';

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_IN').Values.ZoneXferFluidCir.ExhFan.Msm.Gen.airFlowrate.data(1:L); Names{i} = 'ExhFan_airFlowrate';

% Heating
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Heat.Heater.HeaterCtrl.Ctrl.cmd.data(1:L); Names{i} = 'Heater_cmd';   
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Heat.Heater.HeaterCtrl.Ctrl.mode.data(1:L); Names{i} = 'Heater_mode'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Heat.Heater.HeaterCtrl.Ctrl.currObjtve.data(1:L); Names{i} = 'Heater_currObjtve'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.ZoneXferFluidCir.Heat.Heater.HeaterCtrl.CompoData.Info.state.data(1:L); Names{i} = 'Heater_state'; 

%% System

% mode
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.Sys.DemDet.Data.demdDetMode.data(1:L);  Names{i} = 'demdDetMode'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.Sys.DemDet.Data.freeCoolReq.data(1:L); Names{i} = 'freeCoolReq'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.Sys.DemDet.Data.intCoolReq.data(1:L); Names{i} = 'intCoolReq'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.Sys.DemDet.Data.dehumReq.data(1:L); Names{i} = 'dehumReq';
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.Sys.DemDet.Data.heatTemperedCool.data(1:L); Names{i} = 'heatTemperedCool';

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.Sys.DemDet.Data.ervEnergyRecActivate.data(1:L); Names{i} = 'ervEnergyRecActivate'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.Sys.DemDet.Data.ervBypassDamperActivate.data(1:L); Names{i} = 'ervBypassDamperActivate'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.Sys.DemDet.Data.ervFrostPrevActivate.data(1:L); Names{i} = 'ervFrostPrevActivate'; 
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.Sys.DemDet.Data.ervDefrostActive.data(1:L); Names{i} = 'ervDefrostActive'; 

i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.Sys.Telem.actualFluidTempSetptReset.data(1:L); Names{i} = 'actualFluidTempSetptReset'; 

% oper state
i=i+1;Matrix(:,i) = logsoutfile.getElement('CTRL_OUT').Values.Sys.OpState.Data.operState.data(1:L); Names{i} = 'operState';


%%
T = array2table(Matrix,'VariableNames',Names); 
%Create a table with the Matrix data and associated signal names

%% Write to xlsx

Tempfilename = erase(filename,'.mat');
ExcelFileName = join([Tempfilename ,'.xlsx']);% Name of the excel file to write the data
writetable(T,ExcelFileName); %Writing the data to Excel file

if ~isempty(DEF)
    % Add DEF information to sheet #2
    DEF_t = struct2table(DEF);
    DEF_t(:, table2array(varfun(@isstruct, DEF_t))) = [];
    DEF_t = [DEF_t, struct2table(DEF.FMU)];
    DEF_t = [DEF_t, struct2table(DEF.Env)];
    writetable(DEF_t, ExcelFileName, 'Sheet', 2);
end

