# Note: The functions shap.score.rank, shap_long_hd and plot.shap.summary were
# originally published at https://liuyanguu.github.io/post/2018/10/14/shap-visualization-for-xgboost/
# All the credits to the author.


## functions for plot
# return matrix of shap score and mean ranked score list
shap.score.rank <- function(xgb_model = xgb_mod, shap_approx = TRUE,
                            X_train = mydata$train_mm){
  require(xgboost)
  require(data.table)
  shap_contrib <- predict(xgb_model, X_train,
                          predcontrib = TRUE, approxcontrib = shap_approx)
  shap_contrib <- as.data.table(shap_contrib)
  shap_contrib[,BIAS:=NULL]
  cat('make SHAP score by decreasing order\n\n')
  mean_shap_score <- colMeans(abs(shap_contrib))[order(colMeans(abs(shap_contrib)), decreasing = T)]
  return(list(shap_score = shap_contrib,
              mean_shap_score = (mean_shap_score)))
}

# a function to standardize feature values into same range
std1 <- function(x){
  return ((x - min(x, na.rm = T))/(max(x, na.rm = T) - min(x, na.rm = T)))
}


# prep shap data
shap.prep <- function(shap  = shap_result, X_train = mydata$train_mm, top_n){
  require(ggforce)
  # descending order
  if (missing(top_n)) top_n <- dim(X_train)[2] # by default, use all features
  if (!top_n%in%c(1:dim(X_train)[2])) stop('supply correct top_n')
  require(data.table)
  shap_score_sub <- as.data.table(shap$shap_score)
  shap_score_sub <- shap_score_sub[, names(shap$mean_shap_score)[1:top_n], with = F]
  shap_score_long <- melt.data.table(shap_score_sub, measure.vars = colnames(shap_score_sub))

  # feature values: the values in the original dataset
  fv_sub <- as.data.table(X_train)[, names(shap$mean_shap_score)[1:top_n], with = F]
  # standardize feature values
  fv_sub_long <- melt.data.table(fv_sub, measure.vars = colnames(fv_sub))
  fv_sub_long[, stdfvalue := std1(value), by = "variable"]
  # SHAP value: value
  # raw feature value: rfvalue;
  # standarized: stdfvalue
  names(fv_sub_long) <- c("variable", "rfvalue", "stdfvalue" )
  shap_long2 <- cbind(shap_score_long, fv_sub_long[,c('rfvalue','stdfvalue')])
  shap_long2[, mean_value := mean(abs(value)), by = variable]
  setkey(shap_long2, variable)
  return(shap_long2)
}

plot.shap.summary <- function(data_long){
  x_bound <- max(abs(data_long$value))
  require('ggforce') # for `geom_sina`
  plot1 <- ggplot(data = data_long)+
    coord_flip() +
    # sina plot:
    geom_sina(aes(x = variable, y = value, color = stdfvalue)) +
    # print the mean absolute value:
    geom_text(data = unique(data_long[, c("variable", "mean_value")]),
              aes(x = variable, y=-Inf, label = sprintf("%.3f", mean_value)),
              size = 0, alpha = 0.7,
              hjust = -0.2,
              fontface = "bold") + # bold
    # # add a "SHAP" bar notation
    # annotate("text", x = -Inf, y = -Inf, vjust = -0.2, hjust = 0, size = 3,
    #          label = expression(group("|", bar(SHAP), "|"))) +
    scale_color_gradient(low="#FFCC33", high="#6600CC",
                         breaks=c(0,1), labels=c("Low","High")) +
    theme_bw() +
    theme(axis.line.y = element_blank(), axis.ticks.y = element_blank(), # remove axis line
          legend.position="bottom") +
    geom_hline(yintercept = 0) + # the vertical line
    scale_y_continuous(limits = c(-x_bound, x_bound)) +
    # reverse the order of features
    scale_x_discrete(limits = rev(levels(data_long$variable)), labels=c(
        'gersaude' = 'Overall Health',
        'abep5.L' = 'Socioeconomic Status',
        'somasrq' = 'Common Mental Disorders',
        'dor' = 'Bodily Pain',
        'capfunc' = 'Physical Functioning',
        'estano1' = 'Currently Studying',
        'sexo2' = 'Sex (Female)',
        'vitalid' = 'Vitality',
        'idade' = 'Age',
        'saument' = 'Mental Health',
        'somabdi' = "Beck's Depression Inventory",
        'aspfis' = 'Role-Physical',
        'anxietydisorders1' = 'Anxiety Disorders',
        'totbsi' = 'Brief Symptom Inventory',
        'edmat1' = 'Major Depression',
        'escolaridade.L' = 'Education Level',
        'smae1' = 'Mother Suicide'
      )
    ) +
    labs(y = "SHAP value (impact on model output)", x = "", color = "Feature value")
  return(plot1)
}






var_importance <- function(shap_result, top_n=10)
{
  var_importance=tibble(var=names(shap_result$mean_shap_score), importance=shap_result$mean_shap_score)

  var_importance=var_importance[1:top_n,]

  ggplot(var_importance, aes(x=reorder(var,importance), y=importance)) +
    geom_bar(stat = "identity") +
    coord_flip() +
    theme_light() +
    theme(axis.title.y=element_blank())
}

label.feature <- function(x){
  # a saved list of some feature names that I am using
  #labs <- SHAPforxgboost::labels_within_package
  labs = list(
    'gersaude' = 'Overall Health',
    'abep5.L' = 'Socioeconomic Status',
    'somasrq' = 'Common Mental Disorders',
    'dor' = 'Bodily Pain',
    'capfunc' = 'Physical Functioning',
    'estano1' = 'Currently Studying',
    'sexo2' = 'Sex (Female)',
    'vitalid' = 'Vitality',
    'idade' = 'Age',
    'saument' = 'Mental Health'
  )
  # but if you supply your own `new_labels`, it will print your feature names
  # must provide a list.
  #if (!is.null(new_labels)) {
  #  if(!is.list(new_labels)) {
  #    message("new_labels should be a list, for example,`list(var0 = 'VariableA')`.\n")
  #    }  else {
  #    message("Plot will use user-defined labels.\n")
  #    labs = new_labels
  #    }
  #}
  out <- rep(NA, length(x))
  for (i in 1:length(x)){
    if (is.null(labs[[ x[i] ]])){
      out[i] <- x[i]
    }else{
      out[i] <- labs[[ x[i] ]]

    }
  }
  return(out)
}

plot.label <- function(plot1, show_feature){
  if (show_feature == 'dayint'){
    plot1 <- plot1 +
      scale_x_date(date_breaks = "3 years", date_labels = "%Y")
  } else if (show_feature == 'AOT_Uncertainty' | show_feature == 'DevM_P1km'){
    plot1 <- plot1 +
      scale_x_continuous(labels = function(x)paste0(x*100, "%"))
  } else if (show_feature == 'RelAZ'){
    plot1 <- plot1 +
      scale_x_continuous(breaks = c((0:4)*45), limits = c(0,180))
  }
  plot1
}


library(ggplot2)
plot.shap.dependence <- function(
  data_long,
  x,
  y = NULL,
  color_feature = NULL,
  data_int = NULL,  # if supply, will plot SHAP
  dilute = FALSE,
  smooth = TRUE,
  size0 = NULL,
  add_hist = FALSE,
  add_stat_cor = FALSE
  ){
  if (is.null(y)) y <- x
  data0 <- data_long[data_long$variable == y,c("variable", "value")] # the shap value to plot for dependence plot
  data0$x_feature <- data_long[data_long$variable == x, "rfvalue"]
  if (!is.null(color_feature)) data0$color_value <- data_long[data_long$variable == color_feature, "rfvalue"]
  if (!is.null(data_int)) data0$int_value <- data_int[, x, y]

  nrow_X <- nrow(data0)
  if (is.null(dilute)) dilute = FALSE
  if (dilute!=0){
    dilute <- ceiling(min(nrow(data0)/10, abs(as.numeric(dilute))))
    # not allowed to dilute to fewer than 10 obs/feature
    set.seed(1234)
    data0 <- data0[sample(nrow(data0), min(nrow(data0)/dilute, nrow(data0)/2))] # dilute
  }

  # for dayint, reformat date
  if (x == 'dayint'){
    data0[, x_feature:= as.Date(data0[,x_feature], format = "%Y-%m-%d",
                                origin = "1970-01-01")]
  }
  if (is.null(size0)) size0 <- if(nrow(data0)<1000L) 1 else 0.4
  plot1 <- ggplot(data = data0,
                  aes(x = x_feature,
                      y = if (is.null(data_int)) value else int_value,
                      color = if (!is.null(color_feature)) color_value else NULL))+
    geom_point(size = size0, alpha = if(nrow(data0)<1000L) 1 else 0.6)+
    labs(y = if (is.null(data_int)) paste0("SHAP value for ", label.feature(y)) else
      paste0("SHAP interaction values for\n", label.feature(x), " and ", label.feature(y)) ,
         x = label.feature(x),
         color = if (!is.null(color_feature))
           paste0(label.feature(color_feature), "\n","(Feature value)") else NULL) +
    scale_color_gradient(low="#FFCC33", high="#6600CC",
                         guide = guide_colorbar(barwidth = 10, barheight = 0.3)) +
    theme_bw() +
    theme(legend.position="bottom",
          legend.title=element_text(size=10),
          legend.text=element_text(size=8))
    # a loess smoothing line:
  if(smooth){
    plot1 <- plot1 + geom_smooth(method = 'loess', color = 'red', size = 0.4, se = F)
  }
  plot1 <- plot.label(plot1, show_feature = x)
  # add correlation
  if(add_stat_cor){
    plot1 <- plot1 + ggpubr::stat_cor(method = "pearson")
  }

  # add histogram
  if(add_hist){
    plot1 <- ggExtra::ggMarginal(plot1, type = "histogram", bins = 50, size = 10, color="white")
  }

  plot1
}
