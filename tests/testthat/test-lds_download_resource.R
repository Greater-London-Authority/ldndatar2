# ---- Input validation: slug ----

test_that("slug must be a string", {
  expect_error(
    lds_download_resource(slug = 123),
    "slug"
  )

  expect_error(
    lds_download_resource(slug = NULL),
    "slug"
  )

  expect_error(
    lds_download_resource(slug = c("a", "b")),
    "slug"
  )

  expect_error(
    lds_download_resource(slug = TRUE),
    "slug"
  )
})

test_that("slug rejects NA", {
  expect_error(
    lds_download_resource(slug = NA_character_),
    "slug"
  )
})

# ---- Input validation: res_title ----

test_that("res_title must be NULL or a string", {
  expect_error(
    lds_download_resource(slug = "test-dataset", res_title = 123),
    "res_title"
  )

  expect_error(
    lds_download_resource(slug = "test-dataset", res_title = TRUE),
    "res_title"
  )

  expect_error(
    lds_download_resource(slug = "test-dataset", res_title = c("a", "b")),
    "res_title"
  )
})

test_that("res_title accepts NULL (the default)", {
  # Should pass validation and only fail at the HTTP stage
  expect_error(
    lds_download_resource(
      slug = "nonexistent-slug-xyz-999",
      res_title = NULL
    ),
    class = "httr2_http"
  )
})

# ---- Input validation: res_id ----

test_that("res_id must be NULL or a string", {
  expect_error(
    lds_download_resource(slug = "test-dataset", res_id = 123),
    "res_id"
  )

  expect_error(
    lds_download_resource(slug = "test-dataset", res_id = TRUE),
    "res_id"
  )

  expect_error(
    lds_download_resource(slug = "test-dataset", res_id = c("a", "b")),
    "res_id"
  )
})

test_that("res_id accepts NULL (the default)", {
  # Should pass validation and only fail at the HTTP stage
  expect_error(
    lds_download_resource(
      slug = "nonexistent-slug-xyz-999",
      res_id = NULL
    ),
    class = "httr2_http"
  )
})

# ---- Input validation: api_key ----

test_that("api_key must be NULL or a string", {
  expect_error(
    lds_download_resource(slug = "test-dataset", api_key = 123),
    "api_key"
  )

  expect_error(
    lds_download_resource(slug = "test-dataset", api_key = TRUE),
    "api_key"
  )

  expect_error(
    lds_download_resource(slug = "test-dataset", api_key = c("a", "b")),
    "api_key"
  )
})

test_that("api_key accepts NULL (the default)", {
  # Should pass validation and only fail at the HTTP stage
  expect_error(
    lds_download_resource(
      slug = "nonexistent-slug-xyz-999",
      api_key = NULL
    ),
    class = "httr2_http"
  )
})

# ---- Valid inputs pass validation ----

test_that("valid inputs pass validation and reach the HTTP layer", {
  # With a fake slug we expect an HTTP error, not a validation error
  expect_error(
    lds_download_resource(slug = "nonexistent-slug-xyz-999"),
    class = "httr2_http"
  )
})

test_that("valid inputs with all optional params pass validation", {
  expect_error(
    lds_download_resource(
      slug = "nonexistent-slug-xyz-999",
      res_title = "Some Resource",
      res_id = "abc-123",
      api_key = "fake-key"
    ),
    class = "httr2_http"
  )
})

# ---- Multiple bad arguments ----

test_that("earliest failing assertion is reported when multiple args are bad", {
  # slug is checked first, so it should be the reported failure
  expect_error(
    lds_download_resource(slug = 999, res_title = 111, api_key = TRUE),
    "slug"
  )
})
