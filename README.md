---
editor_options: 
  markdown: 
    wrap: 72
---

# Immigration Media Framing ins Swiss newspapers using LLMs

Masterseminarpaper, Module Quantitative Methods


# Pipeline

**Step 1: Define Frame Typology**

-   Use existing literature (optimize pilot project typology) to
    finalize set of frame categories.

-    For each frame: definitions, examples/keywords/reasoning patterns
    (and sample passages)

**Step 2: Collect and prepare articles**

-   Collect articles from Swissdox

-   Swiss newspapers active in 2014, strong market share (2017
    Medienräume)

-   Clean & process the text for GPT input

**Step 3: Prompt Development & Testing Optimize the prompt set up before
full processing. Expermiment with:**

-   Different prompt formats

-   Broad vs. detailed instructions

-   Different levels of frame explanations and examples

-   Article length

-   Test breaking long articles into sections and aggregating frame
    results

-   «Dominant frame» vs. strength scale

-   Assess all frame types per article

-   Use a scale to assess the strength of the scale (eg: 0 = not
    present, 1 = mentioned briefly, 2 = clearly present, 3 = dominant
    throughout article) To assess which prompt structure produces the
    most consistent and valid classifications. Formulate a final prompt
    with consistent and valid classifications.

**Step 4: Intercoder Reliability/Validation**

-   Randomly select a subset of articles (random sample)

-   Manually code the samples using the same final typology (and scale)

-   Let GPT code the same sample and compare the coding

-   If reliability i slow: adjust prompt phrasing/scoring and reassess

**Step 5 : GPT classification**

-   Process the full set of articles with the finalized prompt

**Step 6: Analysis:**

-   Analyze use of frames per newspaper

-   Optional: link frames to regional voting outcomes
