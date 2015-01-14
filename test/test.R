message("Testing virtual machine setup...")

library("rmarkdown")
render("/vagrant/test/test.Rmd")

stopifnot(file.exists("/vagrant/test/test.pdf"))

message("Looks okay.")
