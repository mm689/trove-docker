
# This file is automatically updated through the trove-docker-update pipeline
#  through `make dependencies-get-updates`.
# It reflects the packages used by the trove repo, and is used to pre-install
#  these in the trove-r-base Docker image which can then be used in development
#  and deployment of that repository.

list.of.packages <- c('jsonlite', 'methods', 'ggplot2', 'gtools', 'stringr',
  'NLP', 'RColorBrewer', 'tm', 'wordcloud', 'stringdist', 'plotrix',
  'tidytext', 'tidyverse', 'ggpubr', 'data.table', 'testthat', 'mockery',
  'plumber', 'httr', 'svglite', 'doParallel', 'foreach', 'stringi', 'hms',
  'RMariaDB', 'DBI', 'aws.signature', 'styler', 'lintr', 'pkgload')
