options("repos"="http://cran.rstudio.com") # set the cran mirror

packages <- c("devtools",
              "ggplot2",
#             "reshape2",
#             "RcppEigen",
              "stringr",
#             "gridExtra",
#             "RCurl",
#             "RJSONIO",
#             "RJDBC",
#             "lme4",
#             "latticeExtra",
#             "RMySQL",
#             "XLConnect",
#             "Cairo",
             "rstudio",
             "knitr",
             "rmarkdown")
packages <- setdiff(packages, installed.packages()[, "Package"])
if (length(packages) != 0){
  (install.packages(packages, dep=c("Depends", "Imports")))
}

# Packages from github are installed unconditionally
ghpackages <- c("rstudio/htmltools",
                "trestletech/shinyTable",
                "rstudio/shiny")
# devtools::install_github(ghpackages)

update.packages(ask=FALSE)
