options("repos"="http://cran.rstudio.com") # set the cran mirror

packages <- c("devtools",
              "ggplot2",
              "tidyr",
              "dplyr",
              "stringr",
              "rstudio",
              "knitr",
              "rmarkdown",
              "XML",
              "rJava",
              "mallet",
              "igraph",
              "SnowballC",
              "NLP",
              "openNLP")
packages <- setdiff(packages, installed.packages()[, "Package"])
if (length(packages) != 0){
  (install.packages(packages, dep=c("Depends", "Imports")))
}
devtools::install_github("agoldst/litdata")
update.packages(ask=FALSE)
