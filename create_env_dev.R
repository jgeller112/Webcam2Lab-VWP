#need this to set path to nix for some reason
# Sys.setenv(PATH = paste("/nix/var/nix/profiles/default/bin", Sys.getenv("PATH"), sep=":"))

required_packages = c(
  "tidyverse",
  "mgcv",
  "tidygam",
  "quarto",
  "tinytable",
  "marginaleffects",
  "easystats",
  "scales",
  "tidybayes",
  "webshot2",
  "here",
  "itsadug",
  "ggokabeito",
  "patchwork",
  "cowplot",
  "collapse",
  "transformr",
  "ggrain",
  "glmmTMB"
)

library(rix)

rix(
  date = "2025-12-02",
  r_pkgs = required_packages,
  system_pkgs = c(
    "quarto",
    "git",
    "pandoc",
    "typst",
    "stanc",
    "tbb",
    "gettext",
    "libintl"
  ),
  git_pkgs = list(
    list(
      package_name = "onsets",
      repo_url = "https://gitlab.com/jlverissimo/onsets",
      commit = "184858760cd63fb039c74492ad8f85bb0465e80a"
    )
  ),
  tex_pkgs = c(
    "amsmath",
    "ninecolors",
    "apa7",
    "scalerel",
    "threeparttable",
    "threeparttablex",
    "endfloat",
    "environ",
    "multirow",
    "tcolorbox",
    "pdfcol",
    "tikzfill",
    "fontawesome5",
    "framed",
    "newtx",
    "fontaxes",
    "xstring",
    "wrapfig",
    "tabularray",
    "siunitx",
    "fvextra",
    "geometry",
    "setspace",
    "fancyvrb",
    "anyfontsize"
  ),
  ide = "positron",
  project_path = ".",
  overwrite = TRUE
)
