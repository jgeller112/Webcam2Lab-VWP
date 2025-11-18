gaze <- gaze %>%
  mutate(
    role = dplyr::case_when(
      code == "T" ~ "T",
      code == "C" ~ "C",
      code == "R" ~ "R",
      code %in% c("U", "U2") ~ "U",
      TRUE ~ NA_character_
    )
  )

pseudo_by_subject <- gaze %>%
  group_by(subject, word) %>%
  summarise(
    ever_R = any(role == "R"),
    ever_U = any(role == "U"),
    .groups = "drop"
  ) %>%
  mutate(pseudoU = ever_R & ever_U)

gaze_clean <- gaze %>%
  left_join(pseudo_by_subject, by = c("subject", "word")) %>%
  # Option 1 rule:
  filter(!(role == "U" & pseudoU))

cu_bins <- gaze_clean %>%
  filter(role %in% c("C", "U")) %>%
  mutate(y = if_else(role == "C", 1L, 0L))
