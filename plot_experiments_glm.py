import matplotlib.pyplot as plt
import seaborn as sns
import re
import pandas as pd
import numpy as np

filenames = ["data_glm/importance_" + str(x) + ".csv" for x in range(100, 301, 1)]
# filenames = ["data/stats_200.txt"]

all_importance = []
dfs = []
for fname in filenames:
    df = pd.read_csv(fname).rename(columns={'Unnamed: 0': 'name', '1': 'value'}).set_index('name')
    dfs.append(df)

dfs = pd.concat(dfs, axis=1)
# print(dfs)
mean = dfs.mean(axis=1)
std = dfs.std(axis=1)
ci_lower = mean - 1.96*std
ci_upper = mean + 1.96*std

final_df = pd.concat([mean, std, ci_lower, ci_upper], axis=1)
# print(final_df.sort_values(by=0))
print(final_df)
final_df.to_csv('importance_glm.csv')

filenames = ["data_glm/stats_" + str(x) + ".txt" for x in range(100, 301, 1)]
# filenames = ["data/stats_200.txt"]

all_stats = []
all_cors = []
all_shaps = []
for fname in filenames:
	cors = []
	shaps = []
	with open(fname) as fid:
		lines = fid.readlines()
		i = 0
		while i < len(lines):
			# print(lines[i])
			if "t = " in lines[i]:
				cor_stat = lines[i].split(',')
				cor_stat = [re.split("[=<]", x)[1] for x in cor_stat]
				cor_stat = {
					"t": float(cor_stat[0]),
					"df": float(cor_stat[1]),
					"p-value": float(cor_stat[2]),
					"cor": float(lines[i+6])
				}
				cors.append(cor_stat)


			if "Accuracy" == lines[i].split(":")[0].strip():
				stat = {
					"accuracy": lines[i],
					"ci": lines[i+1],
					"nir": lines[i+2],
					"p-value (acc > nir)": lines[i+3],
					"kappa": lines[i+5],
					"mcnemar": lines[i+7],
					"sensitivity": lines[i+9],
					"specificity": lines[i+10],
					"ppv": lines[i+11],
					"npv": lines[i+12],
					"prevalence": lines[i+13],
					"detection": lines[i+14],
					"detection_prevalence": lines[i+15],
					"balanced_accuracy": lines[i+16]
				}
				for key in stat.keys():
					v = stat[key]
					v = v.split(":")[1]
					stat[key] = eval(v)

			if "Area under the curve" in lines[i]:
				stat["roc"] = float(lines[i].split(":")[1])
			i += 1


	all_stats.append(stat)
	all_cors.append(cors)
	all_shaps.append(shaps)

accuracies = []
for stat in all_stats:
	accuracies.append(stat["balanced_accuracy"])

# from collections import defaultdict
# cors_plot = defaultdict(list)
# for cors in all_cors:
# 	for j in range(0, 7):
# 		cors_plot[j].append(cors[j]["cor"])
#


### PLOT CORRELATIONS ###
# for j in range(0, 6):
# 	plt.subplot(231 + j)
# 	sns.distplot(cors_plot[j])
# 	plt.xlabel("Corr t2 - MINI 0" + str(j+1))
# plt.tight_layout()
# plt.savefig("images/correlations.png")
# # plt.show()
# plt.clf()

### PLOT ACCURACIES ###
std_acc = np.std(accuracies)
mean_acc = np.mean(accuracies)
print("Accuracy: ", mean_acc, '+-', std_acc, '[', mean_acc - 1.96*std_acc, mean_acc + 1.96*std_acc, ']')
print("Seed most similar to mean: ", filenames[np.argmin(abs(mean_acc - accuracies))])
print("Seed best model: ", filenames[np.argmin(mean_acc - accuracies)])
print()
sns.distplot(accuracies)
sns.despine()
plt.xlabel("Balanced Accuracy")
plt.tight_layout()
# # plt.show()
plt.savefig("images_glm/balanced_accuracy.png")
plt.clf()
