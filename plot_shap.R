library(gdata)
source("/home/ballester/Projects/suicide-risk-pelotas-cohort/shap.R")
df_ = read.csv("/home/ballester/Projects/suicide-risk-pelotas-cohort/data/shap_100.csv")
for (i in 101:300) {
  name = paste("/home/ballester/Projects/suicide-risk-pelotas-cohort/data/shap_", i, ".csv", sep="")
  df = read.csv(name)
  df_ = rbind(df_, df)
}

#df2 = read.csv("/home/ballester/Projects/suicide-risk-pelotas-cohort/data/shap_149.csv")
#print(df)

keep = c("gersaude", "abep5.L", "somasrq", "dor", "capfunc", "estano1", "sexo2", "vitalid", "idade", "saument")
df_ = df_[df_$variable %in% keep,]
df_ = droplevels(df_)
df_final = df_[sample(nrow(df_), 10000),]
df_final$variable = factor(df_final$variable, levels=keep)
plot.shap.summary(data_long = df_final)

#df_ = read.csv("/home/ballester/Projects/suicide-risk-pelotas-cohort/data/shap_248.csv")
#source("/home/ballester/Projects/suicide-risk-pelotas-cohort/shap.R")
values = c('gersaude', 'abep5.L', 'somasrq', 'dor', 'capfunc', 'estano1', 'sexo2', 'vitalid',
           'idade', 'saument')
library(ggplot2)
for(i in 1:10) {
  #dev.off()
  #pdf(file=paste('/home/ballester/Projects/suicide-risk-pelotas-cohort/images/singles/',
  #          values[i], '.pdf', sep=''))
  #plot.shap.dependence(data_long = df_final, x = values[i])
  #dev.off()
  #png(file=paste('/home/ballester/Projects/suicide-risk-pelotas-cohort/images/singles/',
  #          values[i], '.png', sep=''))
  temp_plot = plot.shap.dependence(data_long = df_final, x = values[i])
  ggsave(temp_plot, file=paste('/home/ballester/Projects/suicide-risk-pelotas-cohort/images/singles/',
                               values[i], '.png', sep=''))
  ggsave(temp_plot, file=paste('/home/ballester/Projects/suicide-risk-pelotas-cohort/images/singles/',
                               values[i], '.pdf', sep=''))
  
  #dev.off()
  print(values[i])
  #Sys.sleep(1)
}

df_best = read.csv("/home/ballester/Projects/suicide-risk-pelotas-cohort/data/shap_148.csv")
temp_plot = plot.shap.summary(data_long = df_best)
ggsave(temp_plot, file='/home/ballester/Projects/suicide-risk-pelotas-cohort/images/shap_best.png')
ggsave(temp_plot, file='/home/ballester/Projects/suicide-risk-pelotas-cohort/images/shap_best.pdf')

df_mean = read.csv("/home/ballester/Projects/suicide-risk-pelotas-cohort/data/shap_248.csv")
temp_plot = plot.shap.summary(data_long = df_mean)
ggsave(temp_plot, file='/home/ballester/Projects/suicide-risk-pelotas-cohort/images/shap_mean.png')
ggsave(temp_plot, file='/home/ballester/Projects/suicide-risk-pelotas-cohort/images/shap_mean.pdf')

