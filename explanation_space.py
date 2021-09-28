import pandas as pd
from sklearn.manifold import TSNE
from sklearn.decomposition import PCA
import seaborn as sns
sns.set_style("white")
import matplotlib.pyplot as plt

df = pd.read_csv("shap_matrix_test_248.csv")
df = df.drop("Unnamed: 0", axis=1)
outcome = df.outcome
predicted = df.predicted
print(predicted)
df = df.drop(["predicted", "outcome"], axis=1)
print(df)

outcome_bin = outcome.replace({"Yes": 1, "No": 0})
predicted_bin = (predicted > 0.5).astype(int)


# embedded = PCA(n_components=10).fit_transform(df)
# print(embedded.shape)
embedded = TSNE(n_components=2, perplexity=30, random_state=30).fit_transform(df)
plt.subplot(221)
sns.scatterplot(embedded[:,0], embedded[:,1], hue=predicted, legend=False, palette='viridis')
plt.subplot(222)
sns.scatterplot(embedded[:,0], embedded[:,1], hue=outcome_bin==predicted_bin, legend='full', palette='coolwarm')
plt.subplot(223)
sns.scatterplot(embedded[:,0], embedded[:,1], hue=predicted_bin, legend=False, palette='viridis')
plt.subplot(224)
sns.scatterplot(embedded[:,0], embedded[:,1], hue=outcome, legend='full', palette='coolwarm')
# plt.legend('off')
# plt.colorbar()
plt.show()

#keep_variables = ["gersaude", "abep5.L", "somasrq", "dor", "capfunc", "estano1", "sexo2", "vitalid", "idade", "saument"]
