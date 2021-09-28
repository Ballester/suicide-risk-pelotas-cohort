import matplotlib.pyplot as plt
import seaborn as sns
import re

# filenames = ["data/stats_" + str(x) + ".txt" for x in range(100, 301, 1)]
filenames_list = [
	["data/stats_" + str(x) + ".txt" for x in range(100, 301, 1)],
	["data_glm/stats_" + str(x) + ".txt" for x in range(100, 301, 1)]
]
metrics_vs = []
for filenames in filenames_list:

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
				if "===SHAP===" in lines[i]:
					# jump two
					i += 2
					while "===CONFUSION MATRIX===" not in lines[i+1]:
						try:
							shap = lines[i].split()
							shaps.append((shap[0], float(shap[1])))
						except:
							pass
						i += 1
				i += 1




		all_stats.append(stat)
		all_cors.append(cors)
		all_shaps.append(shaps)
		# print(stat)
		# print(cors)
		# print('shap: ', shaps)


	metrics = ['balanced_accuracy', 'sensitivity', 'specificity', 'ppv', 'npv', 'roc']
	metrics_v = {}
	for metric in metrics:
		metrics_v[metric] = []

	accuracies = []
	for stat in all_stats:
		accuracies.append(stat["balanced_accuracy"])
		for metric in metrics:
			metrics_v[metric].append(stat[metric])

	from collections import defaultdict
	cors_plot = defaultdict(list)
	for cors in all_cors:
		for j in range(0, 7):
			cors_plot[j].append(cors[j]["cor"])

	variables_shap = defaultdict(list)
	for shaps in all_shaps:
		for shap in shaps:
			variables_shap[shap[0]].append(shap[1])

	import numpy as np
	variables_mean = {}
	variables_std = {}
	for key in variables_shap.keys():
		variables_mean[key] = np.mean(variables_shap[key])
		variables_std[key] = np.std(variables_shap[key])

	sort_variables_mean = sorted(variables_mean.items(), key=lambda x: x[1], reverse=True)
	for k, v in sort_variables_mean:
		std = variables_std[k]
		ci_lower = round(v - 1.96*std, 3)
		ci_upper = round(v + 1.96*std, 3)
		print(k, round(v, 3), '[', ci_lower, ci_upper, ']')
	# print(sort_variables_mean)

	### PLOT CORRELATIONS ###
	for j in range(0, 6):
		plt.subplot(231 + j)
		sns.distplot(cors_plot[j])
		plt.xlabel("Corr t2 - MINI 0" + str(j+1))
	plt.tight_layout()
	plt.savefig("images/correlations.png")
	# plt.show()
	plt.clf()

	### PLOT ACCURACIES ###
	std_acc = np.std(accuracies)
	mean_acc = np.mean(accuracies)
	# print("Accuracy: ", mean_acc, '+-', std_acc, '[', mean_acc - 1.96*std_acc, mean_acc + 1.96*std_acc, ']')
	for metric in metrics:
		mean_metric = np.mean(metrics_v[metric])
		std_metric = np.std(metrics_v[metric])
		print(metric, "%.2f" % mean_metric, '(', "%.2f" % std_metric, ')', '[', "%.2f" % (mean_metric - 1.96*std_metric),
			"%.2f" % (mean_metric + 1.96*std_metric), ']', ' - minmax: ', "%.2f" % min(metrics_v[metric]), "%.2f" % max(metrics_v[metric]))
		print()
	print("Seed most similar to mean: ", filenames[np.argmin(abs(mean_acc - accuracies))])
	print("Seed best model: ", filenames[np.argmin(mean_acc - accuracies)])
	print()
	sns.distplot(accuracies)
	sns.despine()
	plt.xlabel("Balanced Accuracy")
	plt.tight_layout()
	# # plt.show()
	plt.savefig("images/balanced_accuracy.png")
	plt.clf()

	metrics_vs.append(metrics_v)

import scipy.stats as stats
for metric in metrics:
	print(metric)
	print(np.mean(metrics_vs[0][metric]))
	print(np.mean(metrics_vs[1][metric]))
	print("{:.2e}".format(stats.ttest_ind(metrics_vs[0][metric], metrics_vs[1][metric])[1]))
	# print(stats.ttest_ind(metrics_vs[1][metric], metrics_vs[0][metric]))
