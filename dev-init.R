install.packages("pak")
install.packages("pkgdepends")

# Set up lock file
pak::lockfile_create(pkg = c("devtools", "usethis", "roxygen2", "testthat", "covr", "checkmate", "here"), lockfile = "pkg.lock", upgrade = FALSE, dependencies = NA)
pak::lockfile_install(lockfile = "pkg.lock", update = TRUE)
