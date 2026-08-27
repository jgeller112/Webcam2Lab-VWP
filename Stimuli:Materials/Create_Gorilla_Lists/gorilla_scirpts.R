library(tidyverse)

# -------- helpers --------
.make_blank_row_like <- function(df, display_value = NA_character_) {
  row <- as.data.frame(as.list(rep(NA, ncol(df))), stringsAsFactors = FALSE)
  names(row) <- names(df)
  if ("display" %in% names(row)) row$display <- display_value
  if ("randomise_trials" %in% names(row)) row$randomise_trials <- NA_character_
  if ("randomise_blocks" %in% names(row)) row$randomise_blocks <- NA_character_
  row
}

.pos_after_leq <- function(x, cutoff) {
  idx <- which(x <= cutoff)
  if (length(idx) == 0) NA_integer_ else max(idx)
}

.build_prac_rows <- function(template_cols) {
  prac <- tibble(
    targetword = c("bite.jpg", "milk.jpg", "cool.jpg", "willow.jpg"),
    soundfile = c("bite.mp3", "milk.mp3", "cool.mp3", "willow.mp3"),
    trialtype = c("TRUU", "TCRU", "TUUU", "TRUU"),
    tlpic = c("bite.jpg", "milk.jpg", "pug.jpg", "sunrise.jpg"),
    trpic = c("knife.jpg", "port.jpg", "mug.jpg", "pillar.jpg"),
    blpic = c("jar.jpg", "porch.jpg", "mud.jpg", "pillow.jpg"),
    brpic = c("night.jpg", "torch.jpg", "cool.jpg", "willow.jpg"),
    tlobj = c("bite", "milk", "pug", "sunrise"),
    trobj = c("knife", "port", "mug", "pillar"),
    blobj = c("jar", "porch", "mud", "pillow"),
    brobj = c("night", "torch", "cool", "willow"),
    tlcode = c("T", "T", "U3", "R"),
    trcode = c("U2", "R", "U", "U"),
    blcode = c("U", "U", "U2", "U2"),
    brcode = c("R", "C", "T", "T"),
    season = c("1", "2", "1", "1"),
    display = "prac",
    randomise_trials = "", # only row 1 remains "", others changed below
    randomise_blocks = "", # mirrors trials pre-Main
    trial = NA_character_
  )
  miss <- setdiff(template_cols, names(prac))
  for (nm in miss) prac[[nm]] <- NA_character_
  prac <- prac[, template_cols]
  as.data.frame(prac, stringsAsFactors = FALSE)
}

process_file <- function(file_path, save_path) {
  # Read original list; keep everything as character
  dat <- read.table(file_path, sep = "\t", header = TRUE, stringsAsFactors = FALSE) %>%
    mutate(across(everything(), as.character))

  # Ensure required columns
  if (!"display" %in% names(dat)) dat$display <- "ET"
  if (!"randomise_trials" %in% names(dat)) dat$randomise_trials <- "2"
  if (!"randomise_blocks" %in% names(dat)) dat$randomise_blocks <- "2"
  if (!"trial" %in% names(dat)) dat$trial <- NA_character_

  # ---- Top screens (include 'prac' as a header only) ----
  # ---- Top screens (headers; include 'prac' once) ----
  names(dat) <- sub("^\\$", "", sub("^X\\.", "", names(dat)))
  top_names <- names(dat)
  top_displays <- c("Introduction", "instr", "Experimental", "CalibrationVideo", "calibration", "prac")
  n_top <- length(top_displays)

  top <- as.data.frame(matrix(NA_character_, nrow = n_top, ncol = ncol(dat)), stringsAsFactors = FALSE)
  names(top) <- top_names
  top$display <- top_displays
  top$randomise_trials <- ""
  top$randomise_blocks <- ""
  if (!"trial" %in% names(top)) top$trial <- ""
  top$trial <- "" # no trials on headers


  # ---- Practice trials (4 rows) AFTER 'prac' header, BEFORE 'Main' ----
  # Use your existing .build_prac_rows() then coerce to ET practice (no trial numbers)
  prac_trials <- .build_prac_rows(top_names)
  prac_trials$display <- "ET"
  prac_trials$randomise_trials <- "1"
  prac_trials$randomise_blocks <- "1"
  prac_trials$trial <- "" # make sure practice trials don't carry trial numbers
  if ("subject" %in% names(prac_trials)) prac_trials$subject <- ""
  if ("season" %in% names(prac_trials)) prac_trials$season <- ""

  # ---- 'Main' header (no trial) ----
  main_row <- .make_blank_row_like(top, "Main")
  main_row$trial <- ""
  main_row$randomise_trials <- ""
  main_row$randomise_blocks <- ""

  # ---- Combine: TOP -> spacer -> PRACTICE TRIALS -> Main -> ORIGINAL ET ----
  final <- bind_rows(top, prac_trials, main_row, dat)

  # Defensive: ensure no non-ET rows carry trial numbers
  final$trial[final$display != "ET"] <- ""


  # >>> HARD RESET: no trial numbers tied to practice <<<
  # - clears trial for all non-ET rows
  # - clears trial for ET rows that belong to practice (randomise_trials == "1")
  is_prac <- final$display == "prac" | (final$display == "ET" & final$randomise_trials == "1")
  final$trial[final$display != "ET" | is_prac] <- ""

  # (optional) also clear other identifiers for practice rows
  if ("subject" %in% names(final)) final$subject[is_prac] <- ""
  if ("season" %in% names(final)) final$season[is_prac] <- ""
  # ---- DEFENSIVE: clear trial numbers for ALL non-ET rows ----
  final$trial[final$display != "ET"] <- ""

  # After Main (and any other non-ET), randomise_blocks can remain NA as needed
  final$randomise_blocks[final$display != "ET"] <- NA_character_

  # ---- Insert "calibration" every 30 trials (never after the last trial) ----
  trial_num <- suppressWarnings(as.numeric(final$trial))
  max_t <- suppressWarnings(max(trial_num, na.rm = TRUE))
  if (is.finite(max_t) && max_t > 0) {
    cutpoints <- seq(30, floor(max_t / 30) * 30, by = 30)
    cutpoints <- cutpoints[cutpoints < max_t] # don't insert after last trial

    insert_positions <- vapply(cutpoints, function(cp) .pos_after_leq(trial_num, cp), integer(1L))
    valid_positions <- sort(unique(insert_positions[!is.na(insert_positions)]), decreasing = TRUE)

    for (pos in valid_positions) {
      calib_row <- .make_blank_row_like(final, "calibration")
      # ensure calibration never has a trial number
      calib_row$trial <- ""
      final <- bind_rows(
        final[1:pos, ],
        calib_row,
        final[(pos + 1):nrow(final), ]
      )
      trial_num <- suppressWarnings(as.numeric(final$trial))
    }
  }

  # ---- Add terminal "End" (no trial) ----
  end_row <- .make_blank_row_like(final, "End")
  end_row$trial <- ""
  final <- bind_rows(final, end_row)

  # ---- Sanity checks ----
  tn <- suppressWarnings(as.numeric(final$trial))
  if (any(duplicated(tn[!is.na(tn)]))) {
    stop("Duplicate numeric trial numbers detected – check the input list.")
  }

  # Save
  write.csv(final, file = save_path, row.names = FALSE, na = "")
}

# ---- Example ----
input_directory <- here::here("gorilla_lists")
output_directory <- here::here("gorilla")


input_directory <- here::here("gorilla_lists")
output_directory <- here::here("gorilla")

dir.create(output_directory, showWarnings = FALSE, recursive = TRUE)

dat_files <- list.files(
  input_directory,
  pattern = "\\.dat$",
  full.names = TRUE
)

purrr::walk(dat_files, function(fp) {
  out_name <- paste0(tools::file_path_sans_ext(basename(fp)), ".csv")
  out_path <- file.path(output_directory, out_name)
  process_file(fp, out_path)
})
