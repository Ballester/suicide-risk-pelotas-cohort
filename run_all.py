import os

# for i in range(100, 301, 1):
for i in range(105, 301, 1):
	print('Running seed: ', i)
	os.system("Rscript analysis.R " + str(i))
#
# for i in range(100, 301, 1):
# 	print('Running seed: ', i)
# 	os.system("Rscript analysis_glm.R " + str(i))
