options("repos"="http://cran.rstudio.com") # set the cran mirror

packages = c("devtools","ggplot2","plyr","reshape2","RcppEigen", "stringr","gridExtra",
             "RCurl","RJSONIO","RJDBC","knitr","lme4","latticeExtra","RMySQL",
             "XLConnect","Cairo")
packages = setdiff(packages, installed.packages()[,"Package"])
if (length(packages) != 0){
  (install.packages(packages, dep=c("Depends", "Imports")))
}

# Packages from github are installed unconditionally
ghpackages = c("trestletech/shinyTable","rstudio/rmarkdown","rstudio/shiny")
devtools::install_github(ghpackages)
#ghFrame = do.call(rbind, strsplit(ghpackages,"/"))

#reqPackages = setdiff(ghFrame[,2], installed.packages()[,"Package"])
#ghPack = ghFrame[ghFrame[,2]==reqPackages,,drop=FALSE]
#
#if (nrow(ghPack) != 0){
#  (devtools::install_github(apply(ghPack,1,paste,collapse="/")))
#}             
update.packages(ask=FALSE)
