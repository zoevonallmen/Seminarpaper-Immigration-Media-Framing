# Submitting a query -----------------------------------------------------------

library(httr)

api_key <- readLines("Access Tokens/Swissdox-Key.txt")
api_secret <- readLines("Access Tokens/Swissdox-Secret.txt") 


headers <- add_headers(
  "X-API-Key" = api_key,
  "X-API-Secret" = api_secret
)

API_URL_QUERY <- "https://swissdox.linguistik.uzh.ch/api/query"