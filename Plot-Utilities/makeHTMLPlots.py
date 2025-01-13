#!/usr/bin/env python
"""\
This script converts all tabular data files (XLSX) into HTML-based plot graphics

Usage: makeHTMLPlots.py BATCHFOLDER
    where BATCHFOLDER is the batch test result folder that contains
    a folder called 'Results' where .MAT and .XLSX data files are saved.
"""
import os
import sys
import plotly
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd

def plot_batch(batch_folder, var_list, var_titles):
    folder = os.path.join(batch_folder, "Results")
    assert os.path.isdir(folder), "No folder called 'Results' found batch folder"
    plot_folder = os.path.join(batch_folder, "Plots")
    count = 0
    for root, dirs, files in os.walk(folder):
        for name in files:
            if name.endswith((".xlsx")):
                df_path = os.path.join(root,name)
                if not 'Time' in pd.read_excel(df_path, nrows=1):
                    print("[ ]\tInvalid file:\t" + df_path)
                else:
                    count += 1
                    html_path = os.path.normpath(df_path[:-5]+'.html')
                    html_path = html_path.replace(folder, plot_folder)
                    if not os.path.isdir(os.path.dirname(html_path)):
                        os.makedirs(os.path.dirname(html_path))
                    print("[" + str(count) + "]\tData file: \t" + os.path.relpath(df_path, batch_folder))
                    try:
                        plot_single(df_path, html_path, var_list, var_titles, os.path.relpath(df_path, batch_folder))
                        print("\tWritten to:\t" + os.path.relpath(html_path, batch_folder))
                    except:
                        print(" <!>\tUnable to create plot from file: " + df_path)

def plot_single(df_path, html_path, var_list, var_titles, main_title):
    df = pd.read_excel(df_path, sheet_name='Sheet1')
    dfInfo = pd.read_excel(df_path, sheet_name='Sheet2')

    row_num = len(var_list)
    col_num = len(var_list[0])
    fig = make_subplots(rows=row_num, cols=col_num, shared_xaxes='all', vertical_spacing=0.04, subplot_titles=var_titles)
    for row_idx, row_list in enumerate(var_list):
        for col_idx, col_list in enumerate(row_list):
            for var in col_list:
                yData = df[var]
                yName = var
                trace_visibility = True

                # Scale data for visibility & change label name
                if var in ("CondFan1_cmd", "CondFan2_cmd"):
                        if all(yData<=1) and not all(yData==0):
                            yData = 100*yData
                            yName = yName + "_100x"

                # Traces that are hidden initially
                if var in ("capacityRequest_pct", "capacityActual_pct", "capacityActual_tons", "OARH", "RARH", "splyFan_airFlowrate", "actualFluidTempSetptReset"):
                    trace_visibility = "legendonly"
                if (("contcrReqPctArray") in var):
                     trace_visibility = "legendonly"
                if var.startswith(("ERV_", "ExhFan_", "RetFan_")) or var.endswith(("_airFlowrate")):
                    trace_visibility = "legendonly"

                # Shorten the displayed var name for some signals
                yName = yName.replace("contcrReqPctArray", "ctr")
                
                trace = go.Scatter(x=df["Time"], y=yData, name=yName, visible=trace_visibility)
                fig.add_trace(trace, row=row_idx+1, col=col_idx+1)

    main_subtitle=""
    if 'git_commit' in dfInfo.columns:
        main_subtitle = "Commit: " + dfInfo['git_commit'][0]
    if 'git_branch' in dfInfo.columns:
        main_subtitle = "Branch: " + dfInfo['git_branch'][0] + ", " + main_subtitle
    if 'git_date' in dfInfo.columns:
        main_subtitle = main_subtitle + ", Commit date: " + str(dfInfo['git_date'][0])

    fig.update_layout(height=1000, width=1800, margin_t=150)
    fig.update_layout(title_text=main_title + '<br><span style="font-size: 12px;">' + main_subtitle + '</span>')
    fig.update_layout(modebar_add=["v1hovermode", "hoverclosest", "hovercompare", "togglehover", "togglespikelines", "drawline", "drawopenpath", "drawclosedpath", "drawcircle", "drawrect", "eraseshape"])
    fig.write_html(html_path)

                
def main():
    var_list = [
                [['OAT', "SDT_A", "SDT_B",'CondFan1_satDischTempOptStpt','CondFan2_satDischTempOptStpt', 'SST_A', 'SST_B', 'OARH'],
                ['CondFan1_cmd', 'CondFan2_cmd', 'splyFan_cmd', 'splyFan_airFlowrate', 'CondFan1_contcrReqPctArray1','CondFan1_contcrReqPctArray2','CondFan1_contcrReqPctArray3','CondFan1_contcrReqPctArray4','CondFan1_contcrReqPctArray5','CondFan1_contcrReqPctArray6','CondFan2_contcrReqPctArray1','CondFan2_contcrReqPctArray2','CondFan2_contcrReqPctArray3','CondFan2_contcrReqPctArray4','CondFan2_contcrReqPctArray5','CondFan2_contcrReqPctArray6'],
                ['CondFan1_state','CondFan2_state', 'splyFan_state'],
                ['CondFan1_mode', 'CondFan2_mode', 'splyFan_mode']],
                [['RAT', 'SAT','CCT','CompA1_fluidTempStpt', 'ReheatValve_splyAirTempStpt', 'RARH'], 
                ['CompA1_cmd', 'CompA2_cmd', 'CompB1_cmd','CompB2_cmd', 'capacityRequest_pct', 'capacityActual_pct', 'capacityActual_tons'], 
                ['CompA1_state', 'CompA2_state', 'CompB1_state','CompB2_state'],
                ['CompA1_mode', 'CompA2_mode', 'CompB1_mode','CompB2_mode']],
                [['SSH_A1', 'SSH_A2', 'SSH_B1', 'SSH_B2', 'actualFluidTempSetptReset'],
                ['EXVA1_cmd','EXVA2_cmd','EXVB1_cmd','EXVB2_cmd'],
                ['EXVA1_state','EXVA2_state','EXVB1_state','EXVB2_state'],
                ['EXVA1_mode','EXVA2_mode','EXVB1_mode','EXVB2_mode']],
                [['ThreeWayValve_cmd', 'ReheatValve_cmd','Heater_cmd', 'Econ_cmd', 'ERV_cmd', 'ExhFan_cmd', 'RetFan_cmd', 'ExhFan_airFlowrate', 'RetFan_airFlowrate'], 
                ['ThreeWayValve_mode', 'ReheatValve_mode','Heater_mode', 'Econ_mode', 'ERV_mode', 'ExhFan_mode', 'RetFan_mode'], 
                ['demdDetMode', 'dehumReq', 'intCoolReq','freeCoolReq', 'heatTemperedCool', 'operState', 'ERV_state', 'ExhFan_state', 'RetFan_state', 'Econ_state', 'ervEnergyRecActivate', 'ervBypassDamperActivate', 'ervBypassDamperOn', 'ervFrostPrevActivate', 'ervDefrostActive'],
                ['RefCir1_state', 'RefCir2_state']]
    ]
    var_titles =  ['OAT/SDT/SST', 'IDF/ODF Spd', 'IDF/ODF State', 'IDF/ODF Mode',
            'CCT/DXLAT/SAT/RAT', 'Comp Spd', 'Comp State', 'Comp Mode',
            'SSH', 'EXV Opening', 'EXV State', 'EXV Mode',
            'HMS/HMV/Econ/Heater', 'HMS/HMV/Econ/Heater mode', 'Req', 'CIRCASTE'
            ]
    if len(sys.argv)-1>0:
        batch_folder = sys.argv[1]
    else:
        batch_folder = os.getcwd()
    batch_folder = os.path.normpath(batch_folder)
    print("Creating HTML plots from results in directory: " + batch_folder)
    plot_batch(batch_folder, var_list, var_titles)
     
if __name__ == "__main__":
     main()