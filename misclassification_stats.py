import matplotlib.pyplot as plt
import seaborn as sns
import re
import csv
import pandas as pd
import numpy as np

filenames = ["data/predictions_" + str(x) + ".csv" for x in range(100, 301, 1)]

full_df = pd.read_excel("database_new6.xls", na_values=['#NULL!'])
wrong_full = []
occs_full = []
for fname in filenames:
    with open(fname) as fid:
        df = pd.read_csv(fname)
        df["outcome_b"] = df["outcome"].replace(["No", "Yes"], [0, 1])
        df["pred_b"] = (df["Yes"] > 0.5).astype(int)
        # predictions_orig.append(df)

        wrong_classified = df[df.outcome_b != df.pred_b]
        occs = df.rec

    # print(wrong_classified.shape)
    # print(df.shape)
    rec = wrong_classified.rec.tolist()

    wrong_full += rec
    occs_full += occs.tolist()
    # print(wrong_classified)

unique, counts = np.unique(wrong_full, return_counts=True)
wrong_full = dict(zip(unique, counts))


unique, counts = np.unique(occs_full, return_counts=True)
occs_full = dict(zip(unique, counts))

for key in wrong_full.keys():
    wrong_full[key] = (wrong_full[key]/occs_full[key], occs_full[key], wrong_full[key], full_df[full_df.rec == key].RS_incidencia.item())

w_sorted = sorted(wrong_full.items(), key=lambda x: (x[1][0], x[1][1]), reverse=True)
ids = []
# for v in w_sorted[0:50]:
probs = []
for v in w_sorted:
    if v[1][0] > 0.7:
        probs.append(v[1][0])
        ids.append(v[0])
        # print(v)
print('Wrong pred probs: ', min(probs), max(probs))

print()
ids_small = []
# for v in w_sorted[-100:]:
probs = []
for v in w_sorted:
    if v[1][0] < 0.3:
        probs.append(v[1][0])
        ids_small.append(v[0])
        # print(v)

print('Correct pred probs: ', min(probs), max(probs))

error_df = full_df[full_df.rec.isin(ids)]
correct_df = full_df[full_df.rec.isin(ids_small)]
print('Error df: ', error_df.shape)
print('Correct df: ', correct_df.shape)
print(error_df)
print(correct_df.rec)

import scipy.stats as stats
sig_cols = []
for column in error_df.columns:
    # print(column)
    # print(np.mean(metrics_vs[0][metric]))
    # print(np.mean(metrics_vs[1][metric]))
    print(column)
    v = stats.ttest_ind(error_df[column].dropna(), correct_df[column].dropna())[1]
    if v < 0.05:
        # print("{:.3f}".format(v))
        sig_cols.append(column)

print(error_df)
error_df_neg = error_df[error_df.RS_incidencia == 0][sig_cols].mean()
error_df_pos = error_df[error_df.RS_incidencia == 1][sig_cols].mean()
print('Wrong Negative: ', error_df[error_df.RS_incidencia == 0].shape)
print('Wrong Positive: ', error_df[error_df.RS_incidencia == 1].shape)
error_df = error_df[sig_cols].mean()

correct_df_neg = correct_df[correct_df.RS_incidencia == 0][sig_cols].mean()
correct_df_pos = correct_df[correct_df.RS_incidencia == 1][sig_cols].mean()
print('Correct Negative: ', correct_df[correct_df.RS_incidencia == 0].shape)
print('Correct Positive: ', correct_df[correct_df.RS_incidencia == 1].shape)
correct_df = correct_df[sig_cols].mean()


# error_df['new'] = correct_df
plot_df = pd.DataFrame([error_df_neg, error_df_pos, correct_df_neg, correct_df_pos]).T
plot_df.columns = ['Wrong - Neg', 'Wrong - Pos', 'Correct - Neg', 'Correct - Pos']
plot_df_1 = plot_df[plot_df['Wrong - Neg'] < 2]
print(plot_df_1)
plot_df_1.plot(kind='bar')
# correct_df.plot(kind='bar')
plt.show()

plot_df_2 = plot_df[plot_df['Wrong - Neg'] > 10]
print(plot_df_2)
plot_df_2.plot(kind='bar')
# correct_df.plot(kind='bar')
plt.show()


# print(len(w_sorted))
# print(full_df[full_df.rec.isin(ids)])
# print(full_df)
# print(w_sorted)
