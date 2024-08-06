#!/usr/bin/env Rscript

library(ggplot2)

cat("Library loaded successfully.\n")

cat("Capabilities of this build of R:\n")
capabilities()

test_data <- data.frame(x = c(3, 5), y = c(8, 2))

jpeg("./test-output.jpg")
plot(test_data$x, test_data$y)
tryCatch(dev.off(), warning = function(warn) stop(warn))

png("./test-output.png")
plot(test_data$x, test_data$y)
tryCatch(dev.off(), warning = function(warn) stop(warn))

pdf("./test-output.pdf")
plot(test_data$x, test_data$y)
tryCatch(dev.off(), warning = function(warn) stop(warn))

cat("Image files generated successfully.\n")