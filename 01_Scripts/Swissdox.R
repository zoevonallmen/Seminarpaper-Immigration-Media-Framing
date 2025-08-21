# Submitting a query -----------------------------------------------------------

library(httr)

api_key <- readLines("Access Tokens/Swissdox-Key.txt")
api_secret <- readLines("Access Tokens/Swissdox-Secret.txt") 


headers <- add_headers(
  "X-API-Key" = api_key,
  "X-API-Secret" = api_secret
)

API_URL_QUERY <- "https://swissdox.linguistik.uzh.ch/api/query"

yaml_query <- "
query:
  sources:
    - BLI
    - SRF
    - NZZ
    - TA
    - ZWA
    - LUZ
    - AZ
    - BZ
    - BU
    - THT
    - SGT
  dates:
    - from: 2013-10-09
      to: 2014-02-09
  languages:
    - de
  content:
    AND:
      - OR:
              - einwander*
              - zuwander*
              - asyl*
              - flüchtling*
              - Personenfreizügigkeit
              - überfremdung
              - migrationspolitik
              - migrationsabkommen
              - abschiebung
              - integrationspolitik
result:
  format: TSV
  maxResults: 500000
  columns:
    - id
    - pubtime
    - medium_code
    - medium_name
    - rubric
    - regional
    - doctype
    - doctype_description
    - language
    - char_count
    - dateline
    - head
    - subhead
    - content_id
    - content
version: 1.2
"

response <- POST(
  url = API_URL_QUERY,
  headers,
  body = list(
    query = yaml_query,
    name = "Immigration", 
    comment = "Query comment",
    expirationDate = "2025-12-28"
  ),
  encode = "form"
)

print(content(response, "parsed"))

#Checking the status of submitted queries--------------------------------------
library(httr)
library(jsonlite)

API_URL_STATUS <- "https://swissdox.linguistik.uzh.ch/api/status"

status_response <- GET(
  url = API_URL_STATUS,
  headers
)

status_content <- content(status_response, "text", encoding = "UTF-8")
status_json <- fromJSON(status_content)
print(status_json)
