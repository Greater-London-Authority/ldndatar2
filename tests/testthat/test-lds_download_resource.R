# ---- Input validation: slug ----
#
# Tests that exercise the HTTP layer are wrapped in
# `httptest2::without_internet()` so they don't make real API calls (which would
# burn through the rate limit). The assertion is the same in spirit: validation
# passed and the function reached the HTTP layer.

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
    lds_download_resource(slug = "abcde", res_title = 123),
    "res_title"
  )

  expect_error(
    lds_download_resource(slug = "abcde", res_title = TRUE),
    "res_title"
  )

  expect_error(
    lds_download_resource(slug = "abcde", res_title = c("a", "b")),
    "res_title"
  )
})

# ---- Input validation: res_id ----

test_that("res_id must be NULL or a string", {
  expect_error(
    lds_download_resource(slug = "abcde", res_id = 123),
    "res_id"
  )

  expect_error(
    lds_download_resource(slug = "abcde", res_id = TRUE),
    "res_id"
  )

  expect_error(
    lds_download_resource(slug = "abcde", res_id = c("a", "b")),
    "res_id"
  )
})

# ---- Input validation: api_key ----

test_that("api_key must be NULL or a string", {
  expect_error(
    lds_download_resource(slug = "abcde", api_key = 123),
    "api_key"
  )

  expect_error(
    lds_download_resource(slug = "abcde", api_key = TRUE),
    "api_key"
  )

  expect_error(
    lds_download_resource(slug = "abcde", api_key = c("a", "b")),
    "api_key"
  )
})

# ---- Valid inputs pass validation ----

test_that("valid inputs pass validation and reach the HTTP layer", {
  httptest2::without_internet({
    expect_error(
      lds_download_resource(slug = "abcde"),
      class = "httptest2_request"
    )
  })
})

# ---- Multiple bad arguments ----

test_that("earliest failing assertion is reported when multiple args are bad", {
  # slug is checked first, so it should be the reported failure
  expect_error(
    lds_download_resource(slug = 999, res_title = 111, api_key = TRUE),
    "slug"
  )
})

testthat::test_that("filters to correct resource by title", {
  mock_metadata <- data.frame(
    id = rep("idxxx", 3),
    slug = rep("slug", 3),
    sharing = c("public", "private", "public"),
    order = c(1, 2, 3),
    resource_title = c("report.pdf", "data.csv", "text.txt"),
    resource_id = c("r1", "r2", "r3"),
    url = c(
      "https://example.com/report.pdf",
      "https://example.com/data.csv",
      "https://example.com/text.txt"
    ),
    stringsAsFactors = FALSE
  )

  testthat::with_mocked_bindings(
    lds_download_metadata = function(...) mock_metadata,
    testthat::with_mocked_bindings(
      req_perform = function(...) invisible(NULL),
      .package = "httr2",
      result <- lds_download_resource(
        slug = "abcde",
        res_title = "report.pdf",
        dir = tempdir()
      )
    )
  )

  testthat::expect_equal(result, file.path(tempdir(), "report.pdf"))
})
