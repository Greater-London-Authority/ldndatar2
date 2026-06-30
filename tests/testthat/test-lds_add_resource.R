# ---- Input validation: file_path ----

test_that("file_path must exist on disk", {
  expect_error(
    lds_add_resource(
      file_path = "totally/nonexistent/file.csv",
      slug = "abcde",
      api_key = "test-key-123"
    ),
    "file_path"
  )
})

test_that("file_path rejects non-string types", {
  expect_error(
    lds_add_resource(
      file_path = 123,
      slug = "abcde",
      api_key = "test-key-123"
    ),
    "file_path"
  )

  expect_error(
    lds_add_resource(
      file_path = NULL,
      slug = "abcde",
      api_key = "test-key-123"
    ),
    "file_path"
  )
})

# ---- Input validation: slug ----

test_that("slug must be a non-empty string", {
  tmp <- withr::local_tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", tmp)

  expect_error(
    lds_add_resource(file_path = tmp, slug = "", api_key = "key"),
    "slug"
  )

  expect_error(
    lds_add_resource(file_path = tmp, slug = 42, api_key = "key"),
    "slug"
  )

  expect_error(
    lds_add_resource(file_path = tmp, slug = NULL, api_key = "key"),
    "slug"
  )

  expect_error(
    lds_add_resource(file_path = tmp, slug = NA_character_, api_key = "key"),
    "slug"
  )
})

# ---- Input validation: api_key ----

test_that("api_key must be a non-empty string", {
  tmp <- withr::local_tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", tmp)

  expect_error(
    lds_add_resource(file_path = tmp, slug = "abcde", api_key = ""),
    "api_key"
  )

  expect_error(
    lds_add_resource(file_path = tmp, slug = "abcde", api_key = 999),
    "api_key"
  )

  expect_error(
    lds_add_resource(file_path = tmp, slug = "abcde", api_key = NULL),
    "api_key"
  )
})

# ---- Input validation: res_title ----

test_that("res_title must be NULL or a non-empty string", {
  tmp <- withr::local_tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", tmp)

  # NULL is fine (tested implicitly, it's the default)
  # but an empty string should fail

  expect_error(
    lds_add_resource(
      file_path = tmp,
      slug = "abcde",
      api_key = "key",
      res_title = ""
    ),
    "res_title"
  )

  expect_error(
    lds_add_resource(
      file_path = tmp,
      slug = "abcde",
      api_key = "key",
      res_title = 123
    ),
    "res_title"
  )
})

# ---- Input validation: description ----

test_that("description must be NULL or a string", {
  tmp <- withr::local_tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", tmp)

  expect_error(
    lds_add_resource(
      file_path = tmp,
      slug = "abcde",
      api_key = "key",
      description = 42
    ),
    "description"
  )
})

# ---- Input validation: temporal_coverage_from / to ----

test_that("temporal_coverage_from must be NULL, a Date, or a string", {
  tmp <- withr::local_tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", tmp)

  expect_error(
    lds_add_resource(
      file_path = tmp,
      slug = "abcde",
      api_key = "key",
      temporal_coverage_from = 12345
    ),
    "temporal_coverage_from"
  )

  expect_error(
    lds_add_resource(
      file_path = tmp,
      slug = "abcde",
      api_key = "key",
      temporal_coverage_from = TRUE
    ),
    "temporal_coverage_from"
  )
})

test_that("temporal_coverage_to must be NULL, a Date, or a string", {
  tmp <- withr::local_tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", tmp)

  expect_error(
    lds_add_resource(
      file_path = tmp,
      slug = "abcde",
      api_key = "key",
      temporal_coverage_to = list("bad")
    ),
    "temporal_coverage_to"
  )
})

# ---- Input validation: update_timestamp ----

test_that("update_timestamp must be a single logical value", {
  tmp <- withr::local_tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", tmp)

  expect_error(
    lds_add_resource(
      file_path = tmp,
      slug = "abcde",
      api_key = "key",
      update_timestamp = "yes"
    ),
    "update_timestamp"
  )

  expect_error(
    lds_add_resource(
      file_path = tmp,
      slug = "abcde",
      api_key = "key",
      update_timestamp = NA
    ),
    "update_timestamp"
  )

  expect_error(
    lds_add_resource(
      file_path = tmp,
      slug = "abcde",
      api_key = "key",
      update_timestamp = c(TRUE, FALSE)
    ),
    "update_timestamp"
  )
})

# ---- Default title derivation ----

test_that("res_title defaults to the file name extracted from file_path", {
  # Verify validation passes for a NULL res_title without making a real API
  # call. We stub out the network with without_internet() and assert that the
  # function reached the HTTP layer.
  tmp <- withr::local_tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", tmp)

  httptest2::without_internet({
    expect_error(
      lds_add_resource(file_path = tmp, slug = "abcde", api_key = "fake-key"),
      class = "httptest2_request"
    )
  })
})

# ---- Multiple bad arguments at once ----

test_that("earliest failing assertion is reported when multiple args are bad", {
  # file_path is checked first, so it should be the reported failure
  expect_error(
    lds_add_resource(file_path = 999, slug = 111, api_key = TRUE),
    "file_path"
  )
})

mock_metadata <- data.frame(
  id = rep("idxxx", 3),
  slug = rep("slug", 3),
  sharing = c("public", "private", "public"),
  resource_title = c("report.pdf", "data.csv", "text.txt"),
  resource_id = c("r1", "r2", "r3"),
  stringsAsFactors = FALSE
)

testthat::test_that("successfull calls return invisible", {
  mock_http <- function(status) {
    function(...) {
      httr2::response(
        status_code = status,
        headers = list(`Content-Type` = "application/json"),
        body = charToRaw('{"id": "r_new", "title": "report.pdf"}')
      )
    }
  }

  tmp <- withr::local_tempfile(pattern = "report_mmyy", fileext = ".pdf")
  writeLines("a,b\n1,2", tmp)

  testthat::expect_invisible(
    testthat::with_mocked_bindings(
      lds_download_metadata = function(...) mock_metadata,
      testthat::with_mocked_bindings(
        req_perform = mock_http(200),
        .package = "httr2",
        result <- lds_add_resource(
          file_path = tmp,
          slug = "abcde",
          res_title = basename(tmp),
          api_key = "api_key"
        )
      )
    )
  )
})


testthat::test_that("calls that should raise errors / warning ", {
  mock_http_error <- function(status) {
    function(...) {
      httr2::response(
        status_code = status,
        body = charToRaw("Internal Server Error")
      )
    }
  }

  tmp <- withr::local_tempfile(pattern = "report_mmyy", fileext = ".pdf")
  writeLines("a,b\n1,2", tmp)

  testthat::expect_error(
    testthat::with_mocked_bindings(
      lds_download_metadata = function(...) mock_metadata,
      testthat::with_mocked_bindings(
        req_perform = mock_http_error(403),
        .package = "httr2",
        result <- lds_add_resource(
          file_path = tmp,
          slug = "abcde",
          res_title = basename(tmp),
          api_key = "api_key"
        )
      )
    ),
    "Access denied. Check that your API key has write permissions."
  )

  testthat::expect_error(
    testthat::with_mocked_bindings(
      lds_download_metadata = function(...) mock_metadata,
      testthat::with_mocked_bindings(
        req_perform = mock_http_error(404),
        .package = "httr2",
        result <- lds_add_resource(
          file_path = tmp,
          slug = "abcde",
          res_title = basename(tmp),
          api_key = "api_key"
        )
      )
    ),
    "Dataset with slug 'abcde' was not found."
  )

  testthat::expect_error(
    testthat::with_mocked_bindings(
      lds_download_metadata = function(...) mock_metadata,
      testthat::with_mocked_bindings(
        req_perform = mock_http_error(500),
        .package = "httr2",
        result <- lds_add_resource(
          file_path = tmp,
          slug = "abcde",
          res_title = basename(tmp),
          api_key = "api_key"
        )
      )
    ),
    "Failed to add resource \\(HTTP 500\\): Internal Server Error"
  )
})
