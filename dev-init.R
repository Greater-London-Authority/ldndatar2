install.packages("pak")
install.packages("pkgdepends")

pak::lockfile_create(c("usethis", "here", "testthat", "checkmate", "devtools"), upgrade = FALSE, dependencies = NA, lockfile = "pkg.lock")
pak::lockfile_install(lockfile = "pkg.lock")
