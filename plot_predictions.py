import matplotlib.pyplot as plt
import seaborn as sns
import re
import csv
import pandas as pd
import numpy as np

# filenames = ["data/predictions_" + str(x) + ".csv" for x in range(100, 301, 1)]
filenames = ["data/predictions_" + str(x) + ".csv" for x in range(248, 249, 1)]

for fname in filenames:
    predictions_orig = []
    with open(fname) as fid:
        df = pd.read_csv(fname)
        df["outcome_b"] = df["outcome"].replace(["No", "Yes"], [0, 1])
        predictions_orig.append(df)

    break
print(df)
n_bars = 5
predictions = predictions_orig[0][["Yes", "outcome"]].to_numpy()
s_pred = sorted(predictions, key=lambda tup: tup[0])[::-1]
preds = [tup[0] for tup in s_pred]
labels = [tup[1] for tup in s_pred]
labels = np.array(labels)
len(labels)
preds_split = np.array_split(preds, n_bars)
labels_split = np.array_split(labels, n_bars)
# print(labels)
print(labels_split)
bars_yes = []
bars_no = []
for i, split in enumerate(labels_split):
    # bar_yes = len(split[split=="Yes"])/len(split)
    # bar_no = len(split[split=="No"])/len(split)
    bar_no = len(split[split=="No"])/len(labels[labels=="No"])
    bar_yes = len(split[split=="Yes"])/len(labels[labels=="Yes"])

    bars_yes.append(bar_yes)
    bars_no.append(bar_no)
print(sum(bars_yes))
print(sum(bars_no))
pallete = sns.color_palette("coolwarm", 7)
# plt.bar(np.arange(n_bars), [(a+b)*100 for a,b in zip(bars_yes, bars_no)], color=pallete[0], width=0.5)
bar = plt.bar(np.arange(n_bars), [a*100 for a in bars_yes], color=pallete[6], width=0.5)
# print(sum([a*100 for a in bars_yes][0:2]))
# plt.legend(["No", "Yes"], loc='upper center', ncol=2)
plt.xticks(np.arange(n_bars), np.arange(20)+1)
plt.ylabel("Individuals at suicide risk (%)")
plt.xlabel("Quintile of Predicted Risk")
plt.yticks(list(range(0, 120, 10)), list(range(0, 110, 10)))
plt.tight_layout()
# plt.grid('off')
ax = plt.axes()
for i, rect in enumerate(bar):
    height = rect.get_height()
    pred_split = preds_split[i]
    min_split = min(pred_split)
    max_split = max(pred_split)

    plt.text(rect.get_x() + rect.get_width()/2.0, height, '%.2f  ' % max_split, ha='right', va='bottom', fontsize=8)
    plt.text(rect.get_x() + rect.get_width()/2.0, height, '  %.2f' % min_split, ha='left', va='bottom', fontsize=8)


# ax.yaxis.grid()
# ax.xaxis.grid()
# plt.show()
plt.savefig('images/risk.png')
plt.clf()

from sklearn.metrics import roc_curve, auc
fpr, tpr, _ = roc_curve(predictions_orig[0]["outcome_b"], predictions_orig[0]["Yes"])
roc_auc = auc(fpr, tpr)

print(roc_auc)
plt.plot(fpr, tpr)
plt.plot([0, 1], [0, 1], 'k--')
plt.xlim([0.0, 1.0])
plt.ylim([0.0, 1.05])
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
# plt.title('Some extension of Receiver operating characteristic to multi-class')
plt.legend(loc="lower right")
# plt.show()
plt.savefig('images/roc.png')
plt.clf()
