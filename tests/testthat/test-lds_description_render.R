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

  rmd <- make_test_rmd()

  html <- lds_description_render(input = rmd, include_title = TRUE)

  expect_false(grepl("<title>", html))
  expect_true(grepl("<h1", html))
  expect_true(grepl("<h2", html))
  expect_true(grepl("Some body text", html))
})

test_that("other html files in the session tempdir are not picked up", {
  skip_if_not(rmarkdown::pandoc_available(), "pandoc not available")

  stale <- file.path(tempdir(), "stale.html")
  writeLines("<p>Stale file</p>", stale)
  withr::defer(unlink(stale))

  rmd <- make_test_rmd()

  html <- lds_description_render(input = rmd)

  expect_length(html, 1)
  expect_true(grepl("Some body text", html))
  expect_false(grepl("Stale file", html))
})

test_that("non-ASCII text survives as UTF-8", {
  skip_if_not(rmarkdown::pandoc_available(), "pandoc not available")

  rmd <- withr::local_tempfile(fileext = ".Rmd")
  writeLines(enc2utf8("Costs \u00a3100 per caf\u00e9."), rmd, useBytes = TRUE)

  html <- lds_description_render(input = rmd)

  expect_true(grepl(enc2utf8("\u00a3100 per caf\u00e9"), html, fixed = TRUE))
})

test_that("include_title must be a single TRUE or FALSE", {
  rmd <- withr::local_tempfile(fileext = ".Rmd")
  writeLines("Some body text.", rmd)

  expect_error(
    lds_description_render(input = rmd, include_title = "yes"),
    "include_title"
  )
})
