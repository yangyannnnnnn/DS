#!/usr/bin/env python
# coding: utf-8

# In[1]:


import plotly
import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import os
# !pip install openpyxl
#!pip install xlrd


# In[2]:


# Modify excel path and sheet name to match your own test file. 
folder_path = r"C:\Users\yany4\Downloads"
df_path = r"case2_var_high_comp_spd.xlsx"
folder_sub = "Plots"
df = pd.read_excel(os.path.join(folder_path,df_path), sheet_name='Sheet1') # Modify sheet name as needed
df.drop(index=0, inplace=True)
if not os.path.exists(os.path.join(folder_path,folder_sub)):
    os.makedirs(os.path.join(folder_path,folder_sub))


# In[3]:


# # Update the plot table here to match your test file.
# ============ MAT data reading from MIL Test for Cascade Project ==============
var_list = [
             [['OAT'],['High_Loop_Mass_Flow'], ['ODU_Air_Flow','IDU_Air_Flow'], ['Solenoid1','Solenoid2','Solenoid3','Solenoid4']],
             [['High_Loop_SH', 'High_Loop_SH_Setpoint'], ['High_Loop_EXV'], ['High_Loop_DP','High_Loop_SP'],['High_Loop_Compr']],
             [['ODU_SH'], ['ODU_EXV'], ['ODU_DP','ODU_SP'],['ODU_Compr']],
             [['Aux_SH'], [], ['Aux_DP','Aux_SP'], ['Aux_Compr','Aux_ODF']]
 ]
var_titles =  ['OAT', 'Mass Flow', 'Air Flow', 'Sole Valves',
           'High Loop SH', 'HP EXV', 'HP Press', 'HP Compr',
            'ODU SH', 'ODU EXV', 'ODU Press', 'Odu Compr',
            'Aux SH', 'Aux EXV', 'Aux Press', 'Aux Compr/ODF'
           ]


# In[4]:


row_num = len(var_list)
col_num = len(var_list[0])
fig = make_subplots(rows=row_num, cols=col_num, shared_xaxes='all', vertical_spacing=0.04, subplot_titles=var_titles)

for row_idx, row_list in enumerate(var_list):
    for col_idx, col_list in enumerate(row_list):
        for var in col_list:
            fig.add_trace(go.Scatter(x=df["Time"], y=df[var], name=var), row=row_idx+1, col=col_idx+1) # Modify column name as needed
fig.update_layout(height=800, width=1800)
fig.write_html(os.path.join(folder_path,folder_sub,df_path[:-5]+'.html'))
fig.update_layout(title_text=df_path)
fig.show()


# In[ ]:





# In[ ]:




