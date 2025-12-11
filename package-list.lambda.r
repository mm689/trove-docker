# Packages specifically necessary for an API run on AWS Lambda

list.of.packages <- c(
    "base64enc", # returning binary data from Lambda to API Gateway
    "aws.signature", # retrieving database connection params
    "DBI", # some query-related interpolation functions
    "jsonlite", # encoding and decoding JSON
    "ggplot2", # graphs
    "logger", # lambda logging
    "hms", # processing entry end times / metadata
    "httr", # lambda polling for work and returning responses
    "plotrix", # wordcloud legends
    "RMariaDB", # database access
    "stringr", # various text-processing helpers
    "svglite", # returning graphs as SVG
    "tibble", # for words processing
    "tidytext", # stopwords for word wordclouds
    "dplyr", # arrange, rename, etc.
    "wordcloud" # wordcloud generation
)
