#Load data ---------------------------------------------------------------------
library(readr)
data <- read.delim("Data/Immigration_Articles.tsv", sep = "\t", encoding = "UTF-8")

nrow(data)
head(data)

#data cleaning-----------------------------------------------------------------
library(dplyr)
library(stringr)

for (i in 1:5) {
  cat(paste0("---- ARTICLE ", i, " ----\n"))
  cat(data$content[i], "\n\n")
}

articles_clean <- data |> 
  mutate(content = str_remove_all(content, "<[^>]+>")) |>  
  mutate(content = str_remove(content, "\\(SDA\\).*")) |>   
  mutate(content = str_remove(content, "Publiziert.*")) |>   
  mutate(content = str_remove(content, "Aktualisiert.*")) |>   
  mutate(content = str_remove(content, "^Von [A-ZÄÖÜa-zäöüß\\s]+")) |> 
  mutate(content = str_squish(content)) 


for (i in 1:5) {
  cat(paste0("---- ARTICLE ", i, " ----\n"))
  cat(articles_clean$content[i], "\n\n")
}


write_csv(articles_clean, "Data/Final_Articles.csv")