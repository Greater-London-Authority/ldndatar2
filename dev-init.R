install.packages("pak")
install.packages("pkgdepends")

pak::lockfile_create(c("usethis", "here", "testthat", "checkmate", "devtools"), upgrade = FALSE, dependencies = NA, lockfile = "pkg.lock")
pak::lockfile_install(lockfile = "pkg.lock")

usethis::use_vignette(name = "get_london_datastore_api_jey")
usethis::use_data_raw()
usethis::use_r("data")
