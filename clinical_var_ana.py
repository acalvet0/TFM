#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 29 12:34:27 2024

@author: acalvet

Script to analyse clinical data variables
"""
import pandas as pd
from os.path import join
import matplotlib.pyplot as plt
from IPython.display import display
import numpy as np
import statsmodels.api as sm 

dir_treb = '/Users/acalvet/Documents/MVPA_FISAX'
name_excel = 'EMA_data_Marina_18.12.23_variables_new.xlsx'
data = pd.read_excel(join(dir_treb, name_excel), index_col=1)
data = data.drop(['Columna1'], axis=1)

# Variable description
summary = data.describe()
display(summary)

#%% STAI
n_bins = 30
fig, axs = plt.subplots(2, 1, figsize=(10, 10))  # Creates a 2x2 grid of subplots with a size of 10x10 inches
axs[0].hist(data.STAI_T_A, bins = n_bins, color='#86bf91')
axs[0].set_xlabel('STAI pre')
axs[0].set_ylabel('Count')
axs[0].set_xlim(left=-0.5, right=45)
axs[0].set_ylim(bottom=0, top=20)

axs[1].hist(data.STAI_T_B, bins = n_bins, color='#86bf91')
axs[1].set_xlabel('STAI post')
axs[1].set_ylabel('Count')
axs[1].set_xlim(left=-0.5, right=45)
axs[1].set_ylim(bottom=0, top=20)

# STAI BY SEX
n_bins = 30
fig, axs = plt.subplots(2, 1, figsize=(10, 7))  # Creates a 2x2 grid of subplots with a size of 10x10 inches

axs[0].hist([data[data.Sex == 'Man'].STAI_T_A, data[data.Sex == 'Woman'].STAI_T_A], bins = n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
axs[0].legend()
axs[0].set_xlabel('STAI pre')
axs[0].set_ylabel('Count')
axs[0].set_xlim(left=-0.5, right=45)
axs[0].set_ylim(bottom=0, top=12.5)

axs[1].hist([data[data.Sex == 'Man'].STAI_T_B, data[data.Sex == 'Woman'].STAI_T_B], bins = n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
axs[1].legend()
axs[1].set_xlabel('STAI post')
axs[1].set_ylabel('Count')
axs[1].set_xlim(left=-0.5, right=45)
axs[1].set_ylim(bottom=0, top=12.5)

# STAI Boxplot
plt.figure(figsize = (5,5))
data.boxplot(['STAI_T_A', 'STAI_T_B'], grid = False)
plt.title('STAI')

fig, axes = plt.subplots(1, 2, figsize=(10, 6))
data.boxplot(['STAI_T_A', 'STAI_T_B'], by = 'Sex', grid = False, ax=axes)

# STAI Scatter plot
data.plot.scatter(x='STAI_T_A', y='STAI_T_B', figsize=(6,6))
plt.xlim(-3, 45)
plt.ylim(-3, 45)

#%% SCSR (punishment)
n_bins = 30
fig, axs = plt.subplots(2, 1, figsize=(10, 10))  # Creates a 2x2 grid of subplots with a size of 10x10 inches
axs[0].hist(data.SCSR_P_A, bins = n_bins, color='#86bf91')
axs[0].set_xlabel('SCSR_P pre')
axs[0].set_ylabel('Count')
axs[0].set_xlim(left=-0.5, right=25)
axs[0].set_ylim(bottom=0, top=18)

axs[1].hist(data.SCSR_P_B, bins = n_bins, color='#86bf91')
axs[1].set_xlabel('SCSR_P post')
axs[1].set_ylabel('Count')
axs[1].set_xlim(left=-0.5, right=25)
axs[1].set_ylim(bottom=0, top=18)

# SCSR BY SEX
n_bins = 30
fig, axs = plt.subplots(2, 1, figsize=(10, 7))  # Creates a 2x2 grid of subplots with a size of 10x10 inches

axs[0].hist([data[data.Sex == 'Man'].SCSR_P_A, data[data.Sex == 'Woman'].SCSR_P_A], bins = n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
axs[0].legend()
axs[0].set_xlabel('SCSR_P pre')
axs[0].set_ylabel('Count')
axs[0].set_xlim(left=-0.5, right=25)
axs[0].set_ylim(bottom=0, top=10.5)

axs[1].hist([data[data.Sex == 'Man'].SCSR_P_B, data[data.Sex == 'Woman'].SCSR_P_B], bins = n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
axs[1].legend()
axs[1].set_xlabel('SCSR_P post')
axs[1].set_ylabel('Count')
axs[1].set_xlim(left=-0.5, right=25)
axs[1].set_ylim(bottom=0, top=10.5)

# SCSR Boxplot
plt.figure(figsize = (5,5))
data.boxplot(['SCSR_P_A', 'SCSR_P_B'], grid = False)
plt.title('SCSR_P')

fig, axes = plt.subplots(1, 2, figsize=(10, 6))
data.boxplot(['SCSR_P_A', 'SCSR_P_B'], by = 'Sex', grid = False, ax=axes)

# SCSR Scatter plot
data.plot.scatter(x='SCSR_P_A', y='SCSR_P_B', figsize=(6,6))
plt.xlim(-3, 25)
plt.ylim(-3, 25)

#%% SCSR (reinforcement)
n_bins = 30
fig, axs = plt.subplots(2, 1, figsize=(10, 10))  # Creates a 2x2 grid of subplots with a size of 10x10 inches
axs[0].hist(data.SCSR_R_A, bins = n_bins, color='#86bf91')
axs[0].set_xlabel('SCSR_R pre')
axs[0].set_ylabel('Count')
axs[0].set_xlim(left=-0.5, right=25)
axs[0].set_ylim(bottom=0, top=18)

axs[1].hist(data.SCSR_R_B, bins = n_bins, color='#86bf91')
axs[1].set_xlabel('SCSR_R post')
axs[1].set_ylabel('Count')
axs[1].set_xlim(left=-0.5, right=25)
axs[1].set_ylim(bottom=0, top=18)

# SCSR BY SEX
n_bins = 30
fig, axs = plt.subplots(2, 1, figsize=(10, 7))  # Creates a 2x2 grid of subplots with a size of 10x10 inches

axs[0].hist([data[data.Sex == 'Man'].SCSR_R_A, data[data.Sex == 'Woman'].SCSR_R_A], bins = n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
axs[0].legend()
axs[0].set_xlabel('SCSR_R pre')
axs[0].set_ylabel('Count')
axs[0].set_xlim(left=-0.5, right=25)
axs[0].set_ylim(bottom=0, top=10.5)

axs[1].hist([data[data.Sex == 'Man'].SCSR_R_B, data[data.Sex == 'Woman'].SCSR_R_B], bins = n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
axs[1].legend()
axs[1].set_xlabel('SCSR_R post')
axs[1].set_ylabel('Count')
axs[1].set_xlim(left=-0.5, right=25)
axs[1].set_ylim(bottom=0, top=10.5)

# SCSR Boxplot
plt.figure(figsize = (5,5))
data.boxplot(['SCSR_R_A', 'SCSR_R_B'], grid = False)
plt.title('SCSR_R')

fig, axes = plt.subplots(1, 2, figsize=(10, 6))
data.boxplot(['SCSR_R_A', 'SCSR_R_B'], by = 'Sex', grid = False, ax=axes)

# SCSR Scatter plot
data.plot.scatter(x='SCSR_R_A', y='SCSR_R_B', figsize=(6,6))
plt.xlim(-3, 25)
plt.ylim(-3, 25)

#%% IoUS
n_bins = 30
fig, axs = plt.subplots(2, 1, figsize=(10, 10))  # Creates a 2x2 grid of subplots with a size of 10x10 inches
axs[0].hist(data.IoUS_T_A, bins = n_bins, color='#86bf91')
axs[0].set_xlabel('IoUS pre')
axs[0].set_ylabel('Count')
axs[0].set_xlim(left=19.5, right=125)
axs[0].set_ylim(bottom=0, top=16.5)

axs[1].hist(data.IoUS_T_B, bins = n_bins, color='#86bf91')
axs[1].set_xlabel('IoUS post')
axs[1].set_ylabel('Count')
axs[1].set_xlim(left=19.5, right=125)
axs[1].set_ylim(bottom=0, top=16.5)

# IoUS BY SEX
n_bins = 30
fig, axs = plt.subplots(2, 1, figsize=(10, 7))  # Creates a 2x2 grid of subplots with a size of 10x10 inches

axs[0].hist([data[data.Sex == 'Man'].IoUS_T_A, data[data.Sex == 'Woman'].IoUS_T_A], bins = n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
axs[0].legend()
axs[0].set_xlabel('IoUS pre')
axs[0].set_ylabel('Count')
axs[0].set_xlim(left=19.5, right=125)
axs[0].set_ylim(bottom=0, top=10.5)

axs[1].hist([data[data.Sex == 'Man'].IoUS_T_B, data[data.Sex == 'Woman'].IoUS_T_B], bins = n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
axs[1].legend()
axs[1].set_xlabel('IoUS post')
axs[1].set_ylabel('Count')
axs[1].set_xlim(left=19.5, right=125)
axs[1].set_ylim(bottom=0, top=10.5)

# IoUS Boxplot
plt.figure(figsize = (5,5))
data.boxplot(['IoUS_T_A', 'IoUS_T_B'], grid = False)
plt.title('IoUS')

fig, axes = plt.subplots(1, 2, figsize=(10, 6))
data.boxplot(['IoUS_T_A', 'IoUS_T_B'], by = 'Sex', grid = False, ax=axes)

# IoUS Scatter plot
data.plot.scatter(x='IoUS_T_A', y='IoUS_T_B', figsize=(6,6))
plt.xlim(23, 126)
plt.ylim(23, 126)

#%% Histogram    

ax = data.hist(bins = 30, figsize = (35,20), layout=(3,5), color='#86bf91')

# AGE BY SEX
n_bins = data.Age.max() - data.Age.min()
plt.hist([data[data.Sex == 'Man'].Age, data[data.Sex == 'Woman'].Age], bins=n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
plt.legend()
plt.xlabel('Age')
plt.ylabel('Count')

# EMA BY SEX
n_bins = 30
fig, axs = plt.subplots(2, 1, figsize=(10, 7))  # Creates a 2x2 grid of subplots with a size of 10x10 inches

axs[0].hist([data[data.Sex == 'Man'].EMA_2weeks_first, data[data.Sex == 'Woman'].EMA_2weeks_first], bins = n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
axs[0].legend()
axs[0].set_xlabel('EMA first 2 weeks')
axs[0].set_ylabel('Count')
axs[0].set_xlim(left=-0.5, right=75)
axs[0].set_ylim(bottom=0, top=9.5)

axs[1].hist([data[data.Sex == 'Man'].EMA_2weeks_last, data[data.Sex == 'Woman'].EMA_2weeks_last], bins = n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
axs[1].legend()
axs[1].set_xlabel('EMA last 2 weeks')
axs[1].set_ylabel('Count')
axs[1].set_xlim(left=-0.5, right=75)
axs[1].set_ylim(bottom=0, top=9.5)


# DASS A BY SEX
n_bins = 14
fig, axs = plt.subplots(2, 1, figsize=(10, 7))  # Creates a 2x2 grid of subplots with a size of 10x10 inches

axs[0].hist([data[data.Sex == 'Man'].DASS_A_pre, data[data.Sex == 'Woman'].DASS_A_pre], bins = n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
axs[0].legend()
axs[0].set_xlabel('DASS Anxiety pre')
axs[0].set_ylabel('Count')
axs[0].set_xlim(left=-0.5, right=14)
axs[0].set_ylim(bottom=0, top=35)

axs[1].hist([data[data.Sex == 'Man'].DASS_A_post, data[data.Sex == 'Woman'].DASS_A_post], bins = n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
axs[1].legend()
axs[1].set_xlabel('DASS Anxiety post')
axs[1].set_ylabel('Count')
axs[1].set_xlim(left=-0.5, right=14)
axs[1].set_ylim(bottom=0, top=35)


# DASS D BY SEX
n_bins = 14
fig, axs = plt.subplots(2, 1, figsize=(12, 10))  # Creates a 2x2 grid of subplots with a size of 10x10 inches

axs[0].hist([data[data.Sex == 'Man'].DASS_D_pre, data[data.Sex == 'Woman'].DASS_D_pre], bins = n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
axs[0].legend()
axs[0].set_xlabel('DASS Depression pre')
axs[0].set_ylabel('Count')
axs[0].set_xlim(left=-0.5, right=17.5)
axs[0].set_ylim(bottom=0, top=37)

axs[1].hist([data[data.Sex == 'Man'].DASS_D_post, data[data.Sex == 'Woman'].DASS_D_post], bins = n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
axs[1].legend()
axs[1].set_xlabel('DASS Depression post')
axs[1].set_ylabel('Count')
axs[1].set_xlim(left=-0.5, right=17.5)
axs[1].set_ylim(bottom=0, top=37)


# DASS S BY SEX
n_bins = 14
fig, axs = plt.subplots(2, 1, figsize=(12, 10))  # Creates a 2x2 grid of subplots with a size of 10x10 inches

axs[0].hist([data[data.Sex == 'Man'].DASS_S_pre, data[data.Sex == 'Woman'].DASS_S_pre], bins = n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
axs[0].legend()
axs[0].set_xlabel('DASS Stress pre')
axs[0].set_ylabel('Count')
axs[0].set_xlim(left=-0.5, right=18.5)
axs[0].set_ylim(bottom=0, top=25)

axs[1].hist([data[data.Sex == 'Man'].DASS_S_post, data[data.Sex == 'Woman'].DASS_S_post], bins = n_bins, 
         color=['blue', 'green'], label=['Male', 'Female'], alpha=0.5)
axs[1].legend()
axs[1].set_xlabel('DASS Stress post')
axs[1].set_ylabel('Count')
axs[1].set_xlim(left=-0.5, right=18.5)
axs[1].set_ylim(bottom=0, top=25)

'''
for column in data:
    if data[column].dtype != 'O':
        plt.figure(figsize = (3,5))
        data.boxplot([column], grid = False)
'''

#%% Box plot

plt.figure(figsize = (5,5))
data.boxplot(['EMA_2weeks_first', 'EMA_2weeks_last'], grid = False)
plt.title('EMA')

plt.figure(figsize = (5,5))
data.boxplot(['DASS_S_pre', 'DASS_S_post'], grid = False)
plt.plot(np.arange(0.5,3.5), np.ones(3)*7.5, 'g', linewidth=0.75)
plt.plot(np.arange(0.5,3.5), np.ones(3)*9.5, 'y', linewidth=0.75)
plt.plot(np.arange(0.5,3.5), np.ones(3)*12.5, 'orange', linewidth=0.75)
plt.plot(np.arange(0.5,3.5), np.ones(3)*16.5, 'r', linewidth=0.75)
plt.title('DASS Stress')

plt.figure(figsize = (5,5))
data.boxplot(['DASS_A_pre', 'DASS_A_post'], grid = False)
plt.plot(np.arange(0.5,3.5), np.ones(3)*3.5, 'g', linewidth=0.75)
plt.plot(np.arange(0.5,3.5), np.ones(3)*4.5, 'y', linewidth=0.75)
plt.plot(np.arange(0.5,3.5), np.ones(3)*7.5, 'orange', linewidth=0.75)
plt.plot(np.arange(0.5,3.5), np.ones(3)*9.5, 'r', linewidth=0.75)
plt.title('DASS Anxiety')

plt.figure(figsize = (5,5))
data.boxplot(['DASS_D_pre', 'DASS_D_post'], grid = False)
plt.plot(np.arange(0.5,3.5), np.ones(3)*4.5, 'g', linewidth=0.75)
plt.plot(np.arange(0.5,3.5), np.ones(3)*6.5, 'y', linewidth=0.75)
plt.plot(np.arange(0.5,3.5), np.ones(3)*10.5, 'orange', linewidth=0.75)
plt.plot(np.arange(0.5,3.5), np.ones(3)*13.5, 'r', linewidth=0.75)
plt.title('DASS Depression')



fig, axes = plt.subplots(1, 2, figsize=(10, 6))
data.boxplot(['DASS_S_pre', 'DASS_S_post'], by = 'Sex', grid = False, ax=axes)
for ax in axes:
    ax.plot(np.arange(0.5,3.5), np.ones(3)*7.5, 'g', linewidth=0.75)
    ax.plot(np.arange(0.5,3.5), np.ones(3)*9.5, 'y', linewidth=0.75)
    ax.plot(np.arange(0.5,3.5), np.ones(3)*12.5, 'orange', linewidth=0.75)
    ax.plot(np.arange(0.5,3.5), np.ones(3)*16.5, 'r', linewidth=0.75)
    ax.set_ylim(bottom=-0.5, top=18)

fig, axes = plt.subplots(1, 2, figsize=(10, 6))
data.boxplot(['DASS_A_pre', 'DASS_A_post'], by = 'Sex', grid = False, ax=axes)
for ax in axes:
    ax.plot(np.arange(0.5,3.5), np.ones(3)*3.5, 'g', linewidth=0.75)
    ax.plot(np.arange(0.5,3.5), np.ones(3)*4.5, 'y', linewidth=0.75)
    ax.plot(np.arange(0.5,3.5), np.ones(3)*7.5, 'orange', linewidth=0.75)
    ax.plot(np.arange(0.5,3.5), np.ones(3)*9.5, 'r', linewidth=0.75)
    ax.set_ylim(bottom=-0.5, top=15)

fig, axes = plt.subplots(1, 2, figsize=(10, 6))
data.boxplot(['DASS_D_pre', 'DASS_D_post'], by = 'Sex', grid = False, ax=axes)
for ax in axes:
    ax.plot(np.arange(0.5,3.5), np.ones(3)*4.5, 'g', linewidth=0.75)
    ax.plot(np.arange(0.5,3.5), np.ones(3)*6.5, 'y', linewidth=0.75)
    ax.plot(np.arange(0.5,3.5), np.ones(3)*10.5, 'orange', linewidth=0.75)
    ax.plot(np.arange(0.5,3.5), np.ones(3)*13.5, 'r', linewidth=0.75)
    ax.set_ylim(bottom=-0.5, top=18.5)

#%% Scatter plot

def scatter_plt(data, item, scale, lim, alpha, tit):
    
    v_1 = np.ones(len(lim))
    data.dropna(subset=[item+'_pre', item+'_post']).plot.scatter(x = item + '_pre', y = item + '_post')
    plt.fill_between(lim, min(lim), v_1*scale[0], color='g', alpha=alpha)
    plt.fill_between(lim, v_1*scale[0], v_1*scale[1], color='y', alpha=alpha)
    plt.fill_between(lim, v_1*scale[1], v_1*scale[2], color='orange', alpha=alpha)
    plt.fill_between(lim, v_1*scale[2], v_1*scale[3], color='r', alpha=alpha)
    plt.fill_between(lim, v_1*scale[3], max(lim), color='darkred', alpha=alpha+0.1)
    plt.axvspan(min(lim), scale[0], color='g', alpha=alpha)
    plt.axvspan(scale[0], scale[1], color='y', alpha=alpha)
    plt.axvspan(scale[1], scale[2], color='orange', alpha=alpha)
    plt.axvspan(scale[2], scale[3], color='r', alpha=alpha)
    plt.axvspan(scale[3], max(lim), color='darkred', alpha=alpha+0.1)
    plt.plot(lim, v_1*scale[0], 'g')
    plt.plot(lim, v_1*scale[1], 'y')
    plt.plot(lim, v_1*scale[2], 'orange')
    plt.plot(lim, v_1*scale[3], 'r')
    plt.plot(v_1*scale[0], lim, 'g')
    plt.plot(v_1*scale[1], lim , 'y')
    plt.plot(v_1*scale[2], lim, 'orange')
    plt.plot(v_1*scale[3], lim, 'r')
    plt.title(tit)
    plt.xlim(min(lim), max(lim))
    plt.ylim(min(lim), max(lim))
        

data.plot.scatter(x='EMA_2weeks_first', y='EMA_2weeks_last')
plt.xlim(-3, 75)
plt.ylim(-3, 75)

scatter_plt(data, 'DASS_S', [7.5, 9.5, 12.5, 16.5], np.arange(-1,19), 0.1, 'DASS Stress')
scatter_plt(data, 'DASS_A', [3.5, 4.5, 7.5, 9.5], np.arange(-1,16), 0.1, 'DASS Anxiety')
scatter_plt(data, 'DASS_D', [4.5, 6.5, 10.5, 13.5], np.arange(-1,20), 0.1, 'DASS Depression')

#%% CDF

plt.plot(np.sort(data.EMA_2weeks_first.dropna()), 
         np.arange(summary.EMA_2weeks_first['count'])/float(summary.EMA_2weeks_first['count']), marker='o')
plt.xlabel('Value')
plt.ylabel('CDF')
plt.title('EMA first')
plt.xlim(left=-0.5, right=75)
plt.show()

plt.plot(np.sort(data.EMA_2weeks_last.dropna()), 
         np.arange(summary.EMA_2weeks_last['count'])/float(summary.EMA_2weeks_last['count']), marker='o')
plt.xlabel('Value')
plt.ylabel('CDF')
plt.title('EMA last')
plt.xlim(left=-0.5, right=75)
plt.show()

plt.plot(np.sort(data.DASS_A_pre.dropna()), 
         np.arange(summary.DASS_A_pre['count'])/float(summary.DASS_A_pre['count']), marker='o')
plt.xlabel('Value')
plt.ylabel('CDF')
plt.title('DASS Anxiety pre')
plt.xlim(left=-0.5, right=15)
plt.show()

plt.plot(np.sort(data.DASS_A_post.dropna()), 
         np.arange(summary.DASS_A_post['count'])/float(summary.DASS_A_post['count']), marker='o')
plt.xlabel('Value')
plt.ylabel('CDF')
plt.title('DASS Anxiety post')
plt.xlim(left=-0.5, right=15)
plt.show()

plt.plot(np.sort(data.DASS_D_pre.dropna()), 
         np.arange(summary.DASS_D_pre['count'])/float(summary.DASS_D_pre['count']), marker='o')
plt.xlabel('Value')
plt.ylabel('CDF')
plt.title('DASS Depression pre')
plt.xlim(left=-0.5, right=18.5)
plt.show()

plt.plot(np.sort(data.DASS_D_post.dropna()), 
         np.arange(summary.DASS_D_post['count'])/float(summary.DASS_D_post['count']), marker='o')
plt.xlabel('Value')
plt.ylabel('CDF')
plt.title('DASS Depression post')
plt.xlim(left=-0.5, right=18.5)
plt.show()

plt.plot(np.sort(data.DASS_S_pre.dropna()), 
         np.arange(summary.DASS_S_pre['count'])/float(summary.DASS_S_pre['count']), marker='o')
plt.xlabel('Value')
plt.ylabel('CDF')
plt.title('DASS Stress pre')
plt.xlim(left=-0.5, right=19.5)
plt.show()

plt.plot(np.sort(data.DASS_S_post.dropna()), 
         np.arange(summary.DASS_S_post['count'])/float(summary.DASS_S_post['count']), marker='o')
plt.xlabel('Value')
plt.ylabel('CDF')
plt.title('DASS Stress post')
plt.xlim(left=-0.5, right=19.5)
plt.show()

#%% Q-Q plot

sm.qqplot(data.EMA_2weeks_first.dropna(), line ='45')
plt.title('EMA first')
sm.qqplot(data.EMA_2weeks_last.dropna(), line ='45')
plt.title('EMA last')
sm.qqplot(data.DASS_A_pre.dropna(), line ='45')
plt.title('DASS Anxiety pre')
sm.qqplot(data.DASS_A_post.dropna(), line ='45')
plt.title('DASS Anxiety post')
sm.qqplot(data.DASS_D_pre.dropna(), line ='45')
plt.title('DASS Depression pre')
sm.qqplot(data.DASS_D_post.dropna(), line ='45')
plt.title('DASS Depression post')
sm.qqplot(data.DASS_S_pre.dropna(), line ='45')
plt.title('DASS Stress pre')
sm.qqplot(data.DASS_S_post.dropna(), line ='45') 
plt.title('DASS Stress post')
