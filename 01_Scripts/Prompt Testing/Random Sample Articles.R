
# Load Data ---------------------------------------------------------------

library(readr)
articles <- read.csv("../Seminarpaper-Immigration-Media-Framing/Data/Final_Articles.csv")


# Random Smaple -----------------------------------------------------------

set.seed(2409)
sampled_articles <- articles[sample(nrow(articles), 20), ]


# Save as CSV -------------------------------------------------------------

write_csv(sampled_articles, "../Seminarpaper-Immigration-Media-Framing/Data/Test_Articles_20.csv")


# Sampling 50 Artilces ---------------------------------------------------------

articles <- read.csv("../Seminarpaper-Immigration-Media-Framing/Data/Final_Articles.csv")

set.seed(2409)
sampled_articles <- articles[sample(nrow(articles), 50), ]


write_csv(sampled_articles, "../Seminarpaper-Immigration-Media-Framing/Data/Test_Articles_50.csv")
