import pandas as pd

df = pd.read_excel('database.xls')
print(df)

def get_columns(cols, first, last):
	return cols[cols.index(first):cols.index(last)+1]

bdi_columns = [col for col in df.columns if col[0:3] == 'bdi']
bsi_columns = [col for col in df.columns if col[0:3] == 'bsi']
srq_columns = [col for col in df.columns if col[0:3] == 'srq']

cols = list(df.columns)
transit = get_columns(cols, 'cinto', 'agress')
tent = get_columns(cols, 'tent1', 'tent6')
amat = get_columns(cols, 'amat1', 'amat6')
substance = get_columns(cols, 'qlusoua', 'qlusoui')

print(bdi_columns)
print(bsi_columns)
print(srq_columns)

drop_all = [bdi_columns, bsi_columns, srq_columns, transit, tent, amat, substance]
for drop in drop_all:
	df = df.drop(drop, axis=1)
print(df)

df.to_excel('database_subset.xls', index=False)
