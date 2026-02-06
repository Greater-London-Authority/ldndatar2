# ---- Input validation: slug ----

test_that("slug must be a string", {
  expect_error(
    lds_download_metadata(slug = 123),
    "slug"
  )

  expect_error(
    lds_download_metadata(slug = NULL),
    "slug"
  )

  expect_error(
    lds_download_metadata(slug = c("a", "b")),
    "slug"
  )

  expect_error(
    lds_download_metadata(slug = TRUE),
    "slug"
  )
})

test_that("slug rejects NA", {
  expect_error(
    lds_download_metadata(slug = NA_character_),
    "slug"
  )
})

# ---- Input validation: api_key ----

test_that("api_key must be NULL or a string", {
  expect_error(
    lds_download_metadata(slug = "test-dataset", api_key = 123),
    "api_key"
  )

  expect_error(
    lds_download_metadata(slug = "test-dataset", api_key = TRUE),
    "api_key"
  )

  expect_error(
    lds_download_metadata(slug = "test-dataset", api_key = c("a", "b")),
    "api_key"
  )
})

test_that("api_key accepts NULL (the default)", {
  # Should pass validation and only fail at the HTTP stage
  expect_error(
    lds_download_metadata(slug = "nonexistent-slug-xyz-999", api_key = NULL),
    class = "httr2_http"
  )
})

# ---- Input validation: inc_tables ----

test_that("inc_tables must be logical", {
  expect_error(
    lds_download_metadata(slug = "test-dataset", inc_tables = "yes"),
    "inc_tables"
  )

  expect_error(
    lds_download_metadata(slug = "test-dataset", inc_tables = 1),
    "inc_tables"
  )

  expect_error(
    lds_download_metadata(slug = "test-dataset", inc_tables = NULL),
    "inc_tables"
  )
})

# ---- Valid inputs pass validation ----

test_that("valid inputs pass validation and reach the HTTP layer", {
  # With a fake slug we expect an HTTP error, not a validation error
  expect_error(
    lds_download_metadata(slug = "nonexistent-slug-xyz-999"),
    class = "httr2_http"
  )
})

test_that("valid inputs with api_key pass validation and reach the HTTP layer", {
  expect_error(
    lds_download_metadata(
      slug = "nonexistent-slug-xyz-999",
      api_key = "fake-key-abc"
    ),
    class = "httr2_http"
  )
})
