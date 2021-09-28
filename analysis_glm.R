library(caret)
library(gdata)

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  print(args)
  stop("wrong execution: Rscript analysis.R <SEED>")
} 
SEED = args[1]
#SEED = 248
#df = get(load('/home/spc/Projects/DrugUse/lnud3.calib.RData'))
#df = get(load('/home/ballester/suicide_pelotas/lnud3.calib.RData'))
#matrix = df$variables
#matrix = read.xls('/home/spc/Projects/suicide_pelotas/database.xls', na.strings="#NULL!")
#matrix = read.xls('/home/spc/Projects/suicide_pelotas/database_subset.xls', na.strings="#NULL!")
matrix = read.xls('/home/spc/Projects/suicide_pelotas/database_new6.xls', na.strings="#NULL!")
original_matrix = matrix
matrix$rec = NULL
matrix$RS_tipo_t2 = NULL
matrix$miniC01_t2 = NULL
matrix$miniC02_t2 = NULL
matrix$miniC03_t2 = NULL
matrix$miniC04_t2 = NULL
matrix$miniC05_t2 = NULL
matrix$miniC06_t2 = NULL
matrix$CTQ_total_t2 = NULL


matrix$Conversao_tabacoOMS = NULL
matrix$Conversao_AlcoolOMS = NULL
matrix$Conversao_ilicitas_OMS = NULL

matrix$TabacoOMS_dic_t2 = NULL
matrix$AlcoolOMS_dic_t2 = NULL
matrix$Ilicitas_OMS_t2 = NULL


# Remove variables with single factor
#matrix$tent2 = NULL
#matrix$amat2 = NULL
# Remove variables that repeat others
#matrix$ilicitas2 = NULL

#colMeans(is.na(matrix))*100
#matrix = matrix[, -which(colMeans(is.na(matrix)) > 0.05)]

as.integer.aux <- function(x) {as.integer(as.character(x))}
matrix[sapply(matrix, is.integer)] <- lapply(matrix[sapply(matrix, is.integer)], 
                                       as.factor)
str(matrix, list.len=ncol(matrix))
matrix$idade = as.integer.aux(matrix$idade)
matrix$somabdi = as.integer.aux(matrix$somabdi)
matrix$somasrq = as.integer.aux(matrix$somasrq)
matrix$capfunc = as.integer.aux(matrix$capfunc)
matrix$aspfis = as.integer.aux(matrix$aspfis)
matrix$gersaude = as.integer.aux(matrix$gersaude)
matrix$vitalid = as.integer.aux(matrix$vitalid)
matrix$saument = as.integer.aux(matrix$saument)
matrix$totbsi = as.integer.aux(matrix$totbsi)
matrix$abep5 = ordered(matrix$abep5, levels=c(1,2,3,4,5))
matrix$hypo_mania = ordered(matrix$hypo_mania, levels=c(0,1,2))
matrix$escolaridade = ordered(matrix$escolaridade, levels=c(0,1,2))
matrix$faces = ordered(matrix$faces, levels=c(1,2,3,4,5,6,7))

### Transito ###
matrix$dirigibb = NULL
matrix$acidente_rec = ordered(matrix$acidente_rec, levels=c(0,1,2))

str(matrix, list.len=ncol(matrix))

matrix = matrix[complete.cases(matrix),]
original_matrix = original_matrix[complete.cases(original_matrix),]

# Creating a new variable for the probability with respect
# to the population of each sample
#matrix$weight = df$prob
prop.table(table(matrix$RS_incidencia))
#matrix = matrix[, -which(colMeans(is.na(matrix)) > 0)]

matrix$RS_incidencia = factor(matrix$RS_incidencia, labels=c('Yes', 'No'), levels=c(1, 0))
#matrix$RS_incidencia = factor(matrix$RS_incidencia, labels=c('No', 'Yes'))
prop.table(table(matrix$RS_incidencia))

set.seed(as.integer(SEED))
partitions <- createDataPartition(matrix$RS_incidencia, p=0.75, list=FALSE)
train_matrix <- matrix[partitions,]
test_matrix <- matrix[-partitions,]
original_matrix_train <- original_matrix[partitions,]
original_matrix_test <- original_matrix[-partitions,]

#train_matrix = train_matrix[c(1:1000, 10000:12200), 1:15]
#train_matrix = train_matrix[,30:100]
prop.table(table(train_matrix$RS_incidencia))

prop.table(table(train_matrix$RS_incidencia))
prop.table(table(test_matrix$RS_incidencia))

f_no = table(train_matrix$RS_incidencia)[2]
f_yes = table(train_matrix$RS_incidencia)[1]
w_no = (f_yes)/(f_no+f_yes)
w_yes = (f_no)/(f_no+f_yes)
weights <- ifelse(train_matrix$RS_incidencia == "No", w_no, w_yes)

train_control <- trainControl(method="repeatedcv", number=10, repeats=1, savePredictions=TRUE,
                              classProbs=TRUE, summaryFunction=twoClassSummary)

#weights = train_matrix$weight
#train_matrix$weight = NULL
#test_matrix$weight = NULL
#xgbGrid <- expand.grid(nrounds = c(50, 100, 200),  # this is n_estimators in the python code above
#                       max_depth = c(5, 10, 15, 20),
#                       colsample_bytree = seq(0.5, 0.9, length.out = 5),
#                       ## The values below are default values in the sklearn-api. 
#                       eta = 0.1,
#                       gamma=0,
#                       min_child_weight = 1,
#                       subsample = 1
#)
model <- train(RS_incidencia~., data=train_matrix,
                     trControl=train_control, method="glmnet", weights=weights)

prefix = paste("/home/spc/Projects/suicide_pelotas/data_glm/stats_", SEED, ".txt", sep="")
sink(prefix)
print("===CORRELATIONS===")

### Now let's look at the correlation of that with the t2 variables
### Maybe I should be doing this for the test set instead?
cor.test(predict(model, train_matrix, type="prob")[,1], original_matrix_train$miniC01_t2) # recodificar?
#cor.test(train_matrix$RS_incidencia, original_matrix_train$miniC01_t2) # recodificar? 
cor.test(predict(model, train_matrix, type="prob")[,1], original_matrix_train$miniC02_t2)
cor.test(predict(model, train_matrix, type="prob")[,1], original_matrix_train$miniC03_t2)
cor.test(predict(model, train_matrix, type="prob")[,1], original_matrix_train$miniC04_t2)
cor.test(predict(model, train_matrix, type="prob")[,1], original_matrix_train$miniC05_t2)
cor.test(predict(model, train_matrix, type="prob")[,1], original_matrix_train$miniC06_t2)

cor.test(original_matrix_train$RS_incidencia, original_matrix_train$miniC06_t2)

source("/home/spc/Projects/suicide_pelotas/shap.R")
library(tidyverse)
plot_shap = function(model, shap_matrix) {
  dummy = caret::dummyVars(RS_incidencia~., data=shap_matrix, fullRank=TRUE, sep=NULL)
  shap_as_matrix = xgboost::xgb.DMatrix(as.matrix(predict(dummy, newdata=shap_matrix)))
  # = predict(test_as_matrix, newdata = bike_2)
  shap_values = predict(model$finalModel, shap_as_matrix, predcontrib=TRUE, approxcontrib=FALSE)
  shap_result = shap.score.rank(xgb_model=model$finalModel, 
                                X_train=shap_as_matrix,
                                shap_approx = F
  )
  print(as.matrix(shap_result$mean_shap_score))
  #print(shap_values$shap_score)
  ## Prepare data for top N variables
  shap_long = shap.prep(shap = shap_result,
                        X_train = as.matrix(predict(dummy, newdata=shap_matrix)), top_n=10
  )

  print(shap_long)
  write.csv(shap_long, paste('/home/spc/Projects/suicide_pelotas/data/shap_', SEED, '.csv', sep=''))
  ## Plot shap overall metrics
  plot.shap.summary(data_long = shap_long)
  #xgb.plot.shap(data = as.matrix(predict(dummy, newdata=shap_matrix)), # input data
  #              model = model$finalModel, # xgboost model
  #              features = names(shap_result$mean_shap_score[1:10]), # only top 10 var
  #              n_col = 3, # layout option
  #              plot_loess = T # add red line to plot
  #)
}

#print("")
#print("===SHAP===")
#plot_shap(model, train_matrix)
#plot_shap(model, test_matrix)
print("")

print("===CONFUSION MATRIX===")
### Does it work or not? ###
predictions <- predict(model, test_matrix)
predictions_prob <- predict(model, test_matrix, type="prob")
print(confusionMatrix(predictions, test_matrix$RS_incidencia, positive="Yes"))
prepare_risk = predictions_prob
prepare_risk["outcome"] = test_matrix$RS_incidencia

write.csv(prepare_risk, file=paste("/home/spc/Projects/suicide_pelotas/data_glm/predictions_", SEED, ".csv", sep=""))

### Reproduce the results with the xgboost internal model to see if shap will reflect the same model ###
#dummy = caret::dummyVars(RS_incidencia~., data=test_matrix, fullRank=TRUE, sep=NULL)
#test_as_matrix = xgboost::xgb.DMatrix(as.matrix(predict(dummy, newdata=test_matrix)))
#predictions_proof = predict(model$finalModel, test_as_matrix) > 0.5
#predictions_proof <- ifelse(predictions_proof, "Yes", "No")
#predictions_proof = as.factor(predictions_proof)
#print(confusionMatrix(predictions_proof, test_matrix$RS_incidencia, positive="Yes"))

library(pROC)
roc_curve = roc(test_matrix$RS_incidencia, predictions_prob[, 1], levels=c("No","Yes"))
#prepare_risk = predictions_prob
#prepare_risk["outcome"] = test_matrix$b02e_depressao_Sim
print(roc_curve)
#plot(roc_curve)
sink()

#sensitivities = data.frame(roc_curve$sensitivities)
#specificities = data.frame(roc_curve$specificities)
#write.csv(sensitivities, file="/home/spc/Projects/suicide_pelotas/data/sensitivities.csv")
#write.csv(specificities, file="/home/spc/Projects/suicide_pelotas/data/specificities.csv")
#write.csv(prepare_risk, file="/home/spc/Projects/suicide_pelotas/data/predictions.csv")

#importance = varImp(model)
#importance = importance$importance
#model = model$finalModel
write.csv(as.data.frame(as.matrix(coef(model$finalModel, model$bestTune$lambda))), file=paste("/home/spc/Projects/suicide_pelotas/data_glm/importance_", SEED, ".csv" , sep=""))

