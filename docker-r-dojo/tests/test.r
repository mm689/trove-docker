#!/usr/bin/env Rscript

library(ggplot2)

cat("Library loaded successfully.\n")

failWithTrace <- function(trace) {
  stop(trace)
}

cat("Capabilities of this build of R:\n")
tryCatch(capabilities(), warning = failWithTrace)

test_data <- data.frame(x = c(3, 5), y = c(8, 2))

jpeg("./test-output.jpg")
plot(test_data$x, test_data$y)
tryCatch(dev.off(), warning = failWithTrace)

png("./test-output.png")
plot(test_data$x, test_data$y)
tryCatch(dev.off(), warning = failWithTrace)

pdf("./test-output.pdf")
plot(test_data$x, test_data$y)
tryCatch(dev.off(), warning = failWithTrace)

cat("Image files generated successfully.\n")