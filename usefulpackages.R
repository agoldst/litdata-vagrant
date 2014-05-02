options("repos"="http://cran.rstudio.com") # set the cran mirror

packages = c("devtools","ggplot2","plyr","reshape2","stringr","gridExtra",
             "RCurl","RJSONIO","RJDBC","knitr","lme4","shiny","latticeExtra")
logfile = "/tmp/installedRpackages.log"
unlink(logfile)
sink(logfile)
packages = setdiff(packages, installed.packages()[,"Package"])
if (length(packages) != 0){
  (install.packages(packages, dep=c("Depends", "Imports")))
}

ghpackages = c("trestletech/shinyTable")
ghFrame = do.call(rbind, strsplit(ghpackages,"/"))

reqPackages = setdiff(ghFrame[,2], installed.packages()[,"Package"])
ghPack = ghFrame[ghFrame[,2]==reqPackages,,drop=FALSE]

if (nrow(ghPack) != 0){
  (devtools::install_github(apply(ghPack,1,paste,collapse="/")))
}             
(update.packages(ask=FALSE))
sink(logfile)