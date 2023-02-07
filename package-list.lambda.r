# Packages specifically necessary for an API run on AWS Lambda

list.of.packages <- c(
    "base64enc", # returning binary data from Lambda to API Gateway
    "DBI",       # some query-related interpolation functions
    "jsonlite",  # encoding and decoding JSON
    "ggplot2",   # graphs
    "logger",    # lambda logging
    "httr",      # lambda polling for work and returning responses
    "plotrix",   # wordcloud legends
    "RMariaDB",  # database access
    "stringr",   # various text-processing helpers
    "svglite",   # returning graphs as SVG
    "wordcloud"  # wordcloud generation
)
