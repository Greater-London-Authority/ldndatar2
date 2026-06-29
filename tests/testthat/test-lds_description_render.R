# ---- Input validation ----

test_that("input must exist on disk", {
  expect_error(
    lds_description_render(input = "totally/nonexistent.Rmd"),
    "input"
  )
})

test_that("input must have an allowed extension", {
  bad <- withr::local_tempfile(fileext = ".txt")
  writeLines("hello", bad)

  expect_error(
    lds_description_render(input = bad),
    "extension"
  )
})

# ---- Rendering output ----
#
# Render a tiny Rmd file with a YAML title (so rmarkdown emits a <title> tag)
# and headings, then check fix_html_title strips the right things.
# rmarkdown::render requires pandoc; skip cleanly if it's not available.
#
# NOTE: lds_description_render() uses the shared tempdir() and globs *.html
# from it, so consecutive calls in the same R session collide. We clear stale
# .html files before each render as a workaround. This is a latent bug in the
# function, output should be confined to a per-call subdirectory.

clean_html_tempdir <- function() {
  unlink(list.files(tempdir(), pattern = "\\.html$", full.names = TRUE))
}

make_test_rmd <- function() {
  path <- withr::local_tempfile(.local_envir = parent.frame(), fileext = ".Rmd")
  writeLines(
    c(
      "---",
      "title: \"Test Title\"",
      "output: html_document",
      "---",
      "",
      "# A heading",
      "",
      "## A subheading",
      "",
      "Some body text."
    ),
    path
  )
  path
}

test_that("include_title = FALSE strips <title>, <h1> and <h2>", {
  skip_if_not(rmarkdown::pandoc_available(), "pandoc not available")
  clean_html_tempdir()

  rmd <- make_test_rmd()

  html <- lds_description_render(input = rmd, include_title = FALSE)

  expect_type(html, "character")
  expect_false(grepl("<title>", html))
  expect_false(grepl("<h1", html))
  expect_false(grepl("<h2", html))
  expect_true(grepl("Some body text", html))
})

test_that("include_title = TRUE strips <title> but keeps <h1>/<h2>", {
  skip_if_not(rmarkdown::pandoc_available(), "pandoc not available")
  clean_html_tempdir()

  rmd <- make_test_rmd()

  html <- lds_description_render(input = rmd, include_title = TRUE)

  expect_false(grepl("<title>", html))
  expect_true(grepl("<h1", html))
  expect_true(grepl("<h2", html))
  expect_true(grepl("Some body text", html))
})
