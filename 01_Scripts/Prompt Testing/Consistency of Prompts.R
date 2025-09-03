# libraries -------------------------------------------------------------------
library(readr)
library(dplyr)
library(irr)

# Prompt A  -------------------------------------------------------------------
A1 <- read_csv("../Seminarpaper-Immigration-Media-Framing/Data/Prompt_A_Test_Results.csv") |> 
  select(article_nr, frames_present, dominant_frame) |> 
  rename(frames_A1 = frames_present,
         dom_A1 = dominant_frame)

A2 <- read_csv("../Seminarpaper-Immigration-Media-Framing/Data/Prompt_A_Test_Results_2.csv") |> 
  select(article_nr, frames_present, dominant_frame) |> 
  rename(frames_A2 = frames_present,
         dom_A2 = dominant_frame)


A_merged <- inner_join(A1, A2, by = "article_nr")


A_merged <- A_merged |> 
  mutate(frames_agree = frames_A1 == frames_A2,
         dom_agree    = dom_A1 == dom_A2)

# Percent agreement
frames_agree_pct <- mean(A_merged$frames_agree) * 100 #75%
dom_agree_pct    <- mean(A_merged$dom_agree) * 100    #95%


# Prompt B ---------------------------------------------------------------------

B1 <- read_csv("../Seminarpaper-Immigration-Media-Framing/Data/Prompt_B_Test_Results.csv") |> 
  select(article_nr, frames_present, dominant_frame) |> 
  rename(frames_B1 = frames_present,
         dom_B1 = dominant_frame)

B2 <- read_csv("../Seminarpaper-Immigration-Media-Framing/Data/Prompt_B_Test_Results_2.csv") |> 
  select(article_nr, frames_present, dominant_frame) |> 
  rename(frames_B2 = frames_present,
         dom_B2 = dominant_frame)


B_merged <- inner_join(B1, B2, by = "article_nr")


B_merged <- B_merged |> 
  mutate(frames_agree = frames_B1 == frames_B2,
         dom_agree    = dom_B1 == dom_B2)

# Percent agreement
frames_agree_pct <- mean(B_merged$frames_agree) * 100 #100%
dom_agree_pct    <- mean(B_merged$dom_agree) * 100    #95%


# Prompt C ---------------------------------------------------------------------

C1 <- read_csv("../Seminarpaper-Immigration-Media-Framing/Data/Prompt_C_Test_Results.csv") |> 
  select(article_nr, frames_present, dominant_frame) |> 
  rename(frames_C1 = frames_present,
         dom_C1 = dominant_frame)

C2 <- read_csv("../Seminarpaper-Immigration-Media-Framing/Data/Prompt_C_Test_Results_2.csv") |> 
  select(article_nr, frames_present, dominant_frame) |> 
  rename(frames_C2 = frames_present,
         dom_C2 = dominant_frame)


C_merged <- inner_join(C1, C2, by = "article_nr")


C_merged <- C_merged |> 
  mutate(frames_agree = frames_C1 == frames_C2,
         dom_agree    = dom_C1 == dom_C2)

# Percent agreement
frames_agree_pct <- mean(C_merged$frames_agree) * 100 #90%
dom_agree_pct    <- mean(C_merged$dom_agree) * 100    #95% 


# Final Prompt; 50 articles ---------------------------------------------------

F1 <- read_csv("../Seminarpaper-Immigration-Media-Framing/Data/Final_Prompt_Test_1_50.csv") |> 
  select(article_nr, frames_present, dominant_frame, relevant) |> 
  rename(frames_F1 = frames_present,
         dom_F1 = dominant_frame, 
         relevant_F1 = relevant)

F2 <- read_csv("../Seminarpaper-Immigration-Media-Framing/Data/Final_Prompt_Test_2_50.csv") |> 
  select(article_nr, frames_present, dominant_frame, relevant) |> 
  rename(frames_F2 = frames_present,
         dom_F2 = dominant_frame, 
         relevant_F2 = relevant)


F_merged <- inner_join(F1, F2, by = "article_nr")


F_merged <- F_merged |> 
  mutate(frames_agree = frames_F1 == frames_F2,
         dom_agree    = dom_F1 == dom_F2, 
         relevant_agree = if ("relevant_F1" %in% names(F_merged)) relevant_F1 == relevant_F2 else NA)

# Percent agreement
frames_agree_pct <- mean(F_merged$frames_agree) * 100 #90%
dom_agree_pct    <- mean(F_merged$dom_agree) * 100    #95% 
relevant_agree_pct <- if ("relevant_F1" %in% names(F_merged)) mean(F_merged$relevant_agree) * 100 else NA #98%



# Cohen's kappa (dominant_frames) ----------------------------------------------
all_levels <- union(unique(F_merged$dom_F1), unique(F_merged$dom_F2))
F_merged <- F_merged |> 
  mutate(dom_F1 = factor(dom_F1, levels = all_levels),
         dom_F2 = factor(dom_F2, levels = all_levels))

kappa_res <- kappa2(F_merged[, c("dom_F1", "dom_F2")], weight = "unweighted")
#Cohen's kappa (dominant_frame): 0.98




# Jaccard-Index (frames_present)------------------------------------------------

str_to_set <- function(x) {
  if (is.na(x) | x == "") return(character(0))
  str_split(x, pattern = ",\\s*")[[1]]
}

jaccard <- function(x, y) {
  inter <- length(intersect(x, y))
  union <- length(union(x, y))
  if (union == 0) return(NA)
  inter / union
}


F_merged <- F_merged |> 
  rowwise() |> 
  mutate(
    jaccard = jaccard(set_F1, set_F2),
  ) |> 
  ungroup()

mean_jaccard <- mean(F_merged$jaccard, na.rm = TRUE)
#Average Jaccard (frames_present): 0.84


# Cohen's Kappa for 'relevant' ------------------------------------------------

if ("relevant_F1" %in% names(F_merged)) {
  all_levels_rel <- union(unique(F_merged$relevant_F1), unique(F_merged$relevant_F2))
  F_merged <- F_merged |>
    mutate(relevant_F1 = factor(relevant_F1, levels = all_levels_rel),
           relevant_F2 = factor(relevant_F2, levels = all_levels_rel))
  kappa_rel <- kappa2(F_merged[, c("relevant_F1","relevant_F2")], weight = "unweighted")
}

#Cohen's Kappa for 2 Raters (Weights: unweighted) 
#Subjects = 50 
#Raters = 2 
#Kappa = 0.935 
#z = 6.63 
#p-value = 3.45e-11

