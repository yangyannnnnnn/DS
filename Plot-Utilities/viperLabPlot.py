#!/usr/bin/env python
"""\
Script creates an plotly-based HTML plot from DCAT data taken published from lab tests.

Example usage: viperLabPlot.py "2024-0094-146-TR-21 CONTROLS CLOSED LOOP.xlsx"
	Accepts XLSX and XLSM file formats
"""

import sys
import datetime as dt
import plotly
import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import plotly.express as px

def load_dcat(df_path):
	df = pd.ExcelFile(df_path)
	if "DCAT_Data" in df.sheet_names:
		df = pd.read_excel(df_path, sheet_name='DCAT_Data')
	elif "DCAT Data" in df.sheet_names:
		df = pd.read_excel(df_path, sheet_name='DCAT Data')

	if (sum(df['RAT'].values=="Blk5 Nak") / df['RAT'].size) > 0.8:
		df = pd.ExcelFile(df_path)
		if "DCAT Data (2)" in df.sheet_names:
			df = pd.read_excel(df_path, sheet_name='DCAT Data (2)')
		else:
			raise Exception("Could not locate a DCAT Data sheet with enough valid data")
	
	df.drop(index=0, inplace=True)
	df['DateTime'] = pd.to_datetime(df["Request Date"] + " " + df["Request Time"])
	df['Seconds'] = pd.to_timedelta( df['DateTime'] - df.at[1, 'DateTime'] ).dt.total_seconds()
	return df



def plot_fullsystem(df, savename, var_list, var_titles, vars_hidden, vars_dashedline):
	row_num = len(var_list)
	col_num = len(var_list[0])
	fig = make_subplots(rows=row_num, cols=col_num, shared_xaxes='all', vertical_spacing=0.04, subplot_titles=var_titles)

	for row_idx, row_list in enumerate(var_list):
		for col_idx, col_list in enumerate(row_list):
			for yVar in col_list:
				if yVar in df.columns:
					trace_visibility = True
					if yVar in vars_dashedline:
						lineStyle = dict(dash='dash')
					else:
						lineStyle = dict()
					if yVar in vars_hidden:
						trace_visibility = "legendonly"
					xVar = "Seconds"
					xVar = "Request Time"
					fig.add_trace(go.Scatter(x=df[xVar], y=df[yVar], name=yVar, visible=trace_visibility, line=lineStyle), row=row_idx+1, col=col_idx+1)
				else:
					print("Data file missing column: '" + yVar + "'")
	print(row_idx)
	print(col_idx)
	fig.update_layout(height=1000, width=1800)
	fig.update_layout(modebar_add=["v1hovermode", "hoverclosest", "hovercompare", "togglehover", "togglespikelines", "drawline", "drawopenpath", "drawclosedpath", "drawcircle", "drawrect", "eraseshape"])
	fig.update_layout(title_text=savename)
	fig.write_html(savename+'.html')



def plot_compressorEnvelope(df, savename, var_SST, var_SDT, env_x, env_y):
	fig = px.scatter(df, x='SSTA', y='SDTA', color='Seconds')
	fig.update_layout(coloraxis_colorbar_orientation="h")
	fig.add_trace(go.Scatter(
		x = env_x,
		y = env_y,
		mode='lines',
		name='unknown envlpe',
		line_color="#7375D8"
	))
	fig.update_layout(
		title='Compressor Envelope',
		xaxis_title='SST',
		yaxis_title='SDT'
	)
	fig.update_layout(height=800, width=1200)
	fig.update_layout(title_text=savename+ " - Compressor Envelope")
	fig.write_html(savename+'_envelope.html')


def main():
	var_list = [
		[['OAT', "SDTA", "SSTA", "SDTB", "SSTB", "SDTTARG", "HSHTMPDB", "HSHTEMP"],['IDFCMD', 'ODF1CMD','ODF2CMD', 'IDFSPD', 'ODF1SPD','ODF2SPD'], ['IDFSTE','ODF1STE','ODF2STE'], ['IDFMDE','ODF1MDE','ODF2STE']],
		[['CCT', 'RAT','ACTV_SP','DXLAT','SGTA1','SGTA2','SGTB1','SGTB2'], ['CMPA1CMD', 'CMPA2CMD', 'CMPB1CMD', 'CMPB2CMD', 'CMPFBKA1', 'CMPFBKA2', 'CMPFBKB1','CMPFBKB2', 'CAPAPCT', 'CAPACT', 'COMPA1RT', 'COMPA2RT', 'COMPB1RT', 'COMPB2RT'], ['CMPA1STE', 'CMPA2STE', 'CMPB1STE', 'CMPB2STE'],['CMPA1MDE', 'CMPA2MDE', 'CMPB1MDE', 'CMPB2MDE']],
		[['SSHA1', 'SSHA2', 'SSHB1', 'SSHB2'], ['EXVA1CMD', 'EXVA2CMD','EXVB1CMD','EXVB2CMD', 'EXV_A1', 'EXV_A2','EXV_B1','EXV_B2'], ['EXVA1STE','EXVA2STE','EXVB1STE','EXVB2STE'],['EXVA1MDE','EXVA2MDE','EXVB1MDE','EXVB2MDE']],
		[['HMS', 'DAMPCMD', 'DAMPPOS'], ['SPA', 'SPB', 'DPA', 'DPB'], ['OP_STATE', 'DMD_DET'], ['CIRCASTE', 'CIRCBSTE']],
		# [['COMPA1RT', 'COMPA2RT', 'COMPB1RT', 'COMPB2RT'], [], [], []]
	]
	var_titles = [
		'OAT/SDT/SST', 'IDF/ODF Spd', 'IDF/ODF State', 'IDF/ODF Mode',
		'CCT/DXLAT/SAT/RAT', 'Comp Spd', 'Comp State', 'Comp Mode',
		'SSH', 'EXV Opening', 'EXV State', 'EXV Mode',
		'HMS/OAD', 'Press', 'OP_STATE/DMD_DET', 'CIRCSTE',
		# 'Compr RunTime', '', '', ''
	]
	vars_dashedline = ['CAPAPCT', 'CAPACT']
	vars_hidden = ['CAPAPCT','CAPACT','CMPFBKA1','CMPFBKA2','CMPFBKB1','CMPFBKB2','COMPA1RT','COMPA2RT','COMPB1RT','COMPB2RT','ODF1SPD','ODF2SPD','SGTA1','SGTA2','SGTB1','SGTB2', 'HSHTMPDB', 'HSHTEMP']

	# df_path = "2024-0094-088-TR-21 CONTROLS OPEN LOOP.xlsx"
	df_path = sys.argv[1]
		

	savename = df_path[:-5]
	df = load_dcat(df_path)
	plot_fullsystem(df, savename, var_list, var_titles, vars_hidden, vars_dashedline)

	env_x = [-10, 0, 20, 40, 55, 80, 80, 55, 25, 10, 0, -10, -10]
	env_y = [100, 110, 130, 150, 150, 140, 115, 80, 50, 50, 50, 50, 100]
	plot_compressorEnvelope(df, savename, 'SSTA', 'SDTA', env_x, env_y)


if __name__ == "__main__":
     main()