install.packages("pak")
install.packages("pkgdepends")

pak::lockfile_create(
  c(
    "usethis",
    "here",
    "testthat",
    "checkmate",
    "dplyr",
    "devtools",
    "glue",
    "janitor",
    "lubridate",
    "markdown",
    "rlang",
    "rmarkdown",
    "stringr"
  ),
  upgrade = FALSE,
  dependencies = NA,
  lockfile = "pkg.lock"
)
pak::lockfile_install(lockfile = "pkg.lock")

# TODO: comment it out later
usethis::use_vignette(name = "get_london_datastore_api_jey")
usethis::use_data_raw()
usethis::use_r("data")
usethis::use_r("lds_metadata")

devtools::load_all() # loads all the functions in the package

usethis::use_package("checkmate") # adds package to the DESCRIPTION file
usethis::use_package("glue")
usethis::use_air()
