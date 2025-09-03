# Libraries -------------------------------------------------------------------

library(tidyverse)
library(httr)
library(jsonlite)
library(readr)
library(stringr)
library(purrr)

# Define -----------------------------------------------------------------------

ARTICLES_CSV <- "../Seminarpaper-Immigration-Media-Framing/Data/Final_Articles.csv"
PROMPT_FILE  <- "../Seminarpaper-Immigration-Media-Framing/00_Theory_Testing/Prompts/Prompt C - Combined"
OUT_CSV      <- "../Seminarpaper-Immigration-Media-Framing/Data/Final_Dataset.csv"

MODEL        <- "gpt-4o"
TEMPERATURE  <- 0
API_KEY      <- readLines("../Seminarpaper-Immigration-Media-Framing/Access Tokens/GPT-Key") |> trimws() 

MAX_RETRIES        <- 5
BASE_SLEEP_SECONDS <- 2
PAUSE_BETWEEN_REQS <- 0.5

# Load Prompt -----------------------------------------------------------------

analysis_prompt <- read_file(PROMPT_FILE) |> str_replace_all("\r\n", "\n")

# Load Data --------------------------------------------------------------------

raw_data <- read_csv(ARTICLES_CSV, show_col_types = FALSE)

articles <- raw_data |>
  mutate(
    article_nr = row_number(),
    content = as.character(content)
  )

# Help Functions ---------------------------------------------------------------

# Exponential backoff for retries
exp_backoff <- function(retry) Sys.sleep(BASE_SLEEP_SECONDS ^ retry)

# Removes any ```json ... ``` code fences
strip_code_fences <- function(x) {
  if (is.na(x) || !nzchar(x)) return(NA_character_)
  x |>
    str_replace_all("^```(json|JSON)?\\s*", "") |>
    str_replace_all("\\s*```\\s*$", "") |>
    str_trim()
}

# Parsing JSON securely (with error handling)
parse_json_safely <- function(txt) {
  txt2 <- strip_code_fences(txt)
  if (is.na(txt2) || !nzchar(txt2)) return(NULL)
  tryCatch(jsonlite::fromJSON(txt2, simplifyVector = TRUE), error = function(e) NULL)
}

# Build chat messages (enforces ENGLISH field names in JSON)
build_messages <- function(instruction_prompt, article_text) {
  list(
    list(role = "system", content = instruction_prompt),
    list(
      role = "user",
      content = paste0(
        "Analysiere folgenden Zeitungsartikel.\n\n---\n", article_text, "\n---\n\n",
        "Antworte AUSSCHLIESSLICH mit gültigem JSON.\n",
        "Verwende GENAU diese Feldnamen (in Englisch, nicht übersetzen!):\n",
        "- relevant  (0 oder 1)\n",
        "- frames_present\n",
        "- dominant_frame\n",
        "- responsibility_frame (mit Feld: accused_actors)\n",
        "- moral_frame (mit Feld: position)\n",
        "- conflict_frame (mit Feld: parties)\n",
        "Setze responsibility_frame/moral_frame/conflict_frame auf null, ",
        "falls der jeweilige Frame (6–8) nicht vorkommt."
      )
    )
  )
}

# Once to the API with retries
call_openai_once <- function(messages) {
  retries <- 0
  repeat {
    resp <- tryCatch({
      httr::POST(
        url = "https://api.openai.com/v1/chat/completions",
        httr::content_type_json(),
        httr::add_headers(Authorization = paste("Bearer", API_KEY)),
        body = list(
          model = MODEL,
          temperature = TEMPERATURE,
          messages = messages,
          response_format = list(type = "json_object")  # erzwingt JSON
        ),
        encode = "json"
      )
    }, error = function(e) {
      message("HTTP error: ", conditionMessage(e))
      NULL
    })
    
    if (!is.null(resp) && httr::status_code(resp) %in% 200:299) return(resp)
    
    retries <- retries + 1
    if (retries >= MAX_RETRIES) return(NULL)
    message("Retry #", retries, " ...")
    exp_backoff(retries)
  }
}

# Secure list extraction with default
pluck_or <- function(x, name, default = NA) {
  if (is.null(x)) return(default)
  if (!name %in% names(x)) return(default)
  x[[name]] %||% default
}

# Normalizes German → English keys (top-level & nested)
normalize_keys <- function(lst) {
  if (is.null(lst)) return(NULL)
  
  # Top-Level rename
  names(lst) <- names(lst) |>
    str_replace("^relevant$", "relevant") |>
    str_replace("^Vorhandene\\s*Frames$", "frames_present") |>
    str_replace("^Dominanter\\s*Frame$", "dominant_frame") |>
    str_replace("^Verantwortungs-Frame$", "responsibility_frame") |>
    str_replace("^Moral-Frame$", "moral_frame") |>
    str_replace("^Konflikt-Frame$", "conflict_frame")
  
  # responsibility_frame
  if (!is.null(lst$responsibility_frame) && is.list(lst$responsibility_frame)) {
    names(lst$responsibility_frame) <- names(lst$responsibility_frame) |>
      str_replace("Beschuldigte\\s*Akteure", "accused_actors") |>
      str_replace("^Akteure$", "accused_actors")
  }
  
  # moral_frame
  if (!is.null(lst$moral_frame) && is.list(lst$moral_frame)) {
    names(lst$moral_frame) <- names(lst$moral_frame) |>
      str_replace("^Position$", "position")
  }
  
  # conflict_frame
  if (!is.null(lst$conflict_frame) && is.list(lst$conflict_frame)) {
    names(lst$conflict_frame) <- names(lst$conflict_frame) |>
      str_replace("Konfliktparteien", "parties") |>
      str_replace("^Parteien$", "parties")
  }
  
  lst
}

# Converts list/string robustly into character vector (e.g., actors/parties)
as_chr_vec <- function(x) {
  if (is.null(x)) return(NA_character_)
  if (length(x) == 1 && is.na(x)) return(NA_character_)
  if (is.character(x) && length(x) == 1) {
    parts <- str_split(x, "\\s*(;|,|\\s+vs\\.?\\s+|\\s+und\\s+|/|\\|)\\s*", simplify = FALSE)[[1]]
    parts <- parts[nzchar(parts)]
    if (length(parts) == 0) return(NA_character_) else return(parts)
  }
  as.character(unlist(x, use.names = FALSE))
}

# Coerce relevant to 0/1 integer
coerce_relevant01 <- function(x) {
  if (is.null(x) || length(x) == 0) return(NA_integer_)
  if (is.logical(x)) return(as.integer(x))
  if (is.numeric(x)) return(as.integer(ifelse(is.na(x), NA, ifelse(x != 0, 1, 0))))
  if (is.character(x)) {
    x <- tolower(trimws(x))
    if (x %in% c("1","true","ja","yes")) return(1L)
    if (x %in% c("0","false","nein","no")) return(0L)
  }
  suppressWarnings(as.integer(x))
}

# Mainloop: API Calls ---------------------------------------------------------
results_list <- vector("list", nrow(articles))

for (i in seq_len(nrow(articles))) {
  art_txt  <- articles$content[i]
  messages <- build_messages(analysis_prompt, art_txt)
  
  resp <- call_openai_once(messages)
  
  if (is.null(resp)) {
    results_list[[i]] <- list(
      raw_text = NA_character_,
      parsed   = NULL,
      ok       = FALSE,
      http_ok  = FALSE
    )
  } else {
    http_ok <- httr::status_code(resp) %in% 200:299
    parsed_resp <- try(httr::content(resp, as = "parsed", encoding = "UTF-8"), silent = TRUE)
    
    raw_text <- NA_character_
    if (!inherits(parsed_resp, "try-error")) {
      if (!is.null(parsed_resp$choices) && length(parsed_resp$choices) > 0) {
        raw_text <- parsed_resp$choices[[1]]$message$content %||% NA_character_
      }
    }
    
    pj <- parse_json_safely(raw_text)
    
    results_list[[i]] <- list(
      raw_text = raw_text,
      parsed   = pj,
      ok       = !is.null(pj),
      http_ok  = http_ok
    )
  }
  
  cat("Finished article", i, "/", nrow(articles), " | parsed:", results_list[[i]]$ok, "\n")
  Sys.sleep(PAUSE_BETWEEN_REQS)
}

# JSON to tidy -----------------------------------------------------------------

flat <- map_dfr(results_list, function(x) {
  if (!isTRUE(x$ok)) {
    tibble(
      relevant            = NA_integer_,
      frames_present      = NA_character_,
      dominant_frame      = NA_integer_,
      resp_accused_actors = NA_character_,
      moral_position      = NA_character_,
      conflict_parties    = NA_character_,
      raw_text            = x$raw_text
    )
  } else {
    lst <- normalize_keys(x$parsed)  # <- deutsch → english (Top + nested)
    
    relevant_val  <- coerce_relevant01(pluck_or(lst, "relevant", default = NA))
    frames_present <- pluck_or(lst, "frames_present", default = NA)
    dominant_frame <- pluck_or(lst, "dominant_frame", default = NA)
    
    resp_frame     <- pluck_or(lst, "responsibility_frame", default = NULL)
    moral_frame    <- pluck_or(lst, "moral_frame",          default = NULL)
    conflict_frame <- pluck_or(lst, "conflict_frame",       default = NULL)
    
    resp_accused   <- if (!is.null(resp_frame)) as_chr_vec(pluck_or(resp_frame, "accused_actors", default = NA)) else NA
    moral_pos      <- if (!is.null(moral_frame)) pluck_or(moral_frame, "position", default = NA) else NA
    conflict_party <- if (!is.null(conflict_frame)) as_chr_vec(pluck_or(conflict_frame, "parties", default = NA)) else NA
    
    tibble(
      relevant            = relevant_val,
      frames_present      = if (all(is.na(frames_present))) NA_character_ else paste(frames_present, collapse = ";"),
      dominant_frame      = suppressWarnings(as.integer(dominant_frame)),
      resp_accused_actors = if (all(is.na(resp_accused))) NA_character_ else paste(resp_accused, collapse = ";"),
      moral_position      = if (all(is.na(moral_pos))) NA_character_ else as.character(moral_pos),
      conflict_parties    = if (all(is.na(conflict_party))) NA_character_ else paste(conflict_party, collapse = ";"),
      raw_text            = x$raw_text
    )
  }
})

results <- articles |>
  select(id, article_nr, medium_code) |>
  bind_cols(flat)

# Save Results -----------------------------------------------------------------

write_csv(results, OUT_CSV)

