#!/usr/bin/env Rscript

source("package-list.r")

install.packages(list.of.packages, repos = "https://cloud.r-project.org/")

cat("\nStatus: all packages installed. Loading them for verification...\n")
for (p in list.of.packages) {
    library(p, character.only = TRUE)
}
