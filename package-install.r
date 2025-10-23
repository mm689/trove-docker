#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

package.list <- "package-list.r"
if ("--lambda" %in% args) {
  package.list <- "package-list.lambda.r"
}
source(package.list)

cat("\nAttempting to load all R packages...\n")

missing.packages <- list.of.packages[! vapply(
  list.of.packages,
  require,
  quietly = TRUE,
  character.only = TRUE,
  FUN.VALUE = logical(1)
)]

if (length(missing.packages) == 0) {
  cat("All packages loaded successfully.\n")

} else if ("--validate" %in% args) {
  cat("The following packages failed to load:\n")
  print(missing.packages)
  quit(status = 1)

} else {
  cat("At least one package failed to load. Installing missing packages:\n")
  print(missing.packages)
  install.packages(missing.packages, repos = "https://cloud.r-project.org/")

  cat("\nStatus: all packages installed. Loading them for verification...\n")
  for (package in list.of.packages) {
    library(package, character.only = TRUE)
  }
}
