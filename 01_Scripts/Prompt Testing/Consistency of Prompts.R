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
