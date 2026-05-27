# ---- Input validation: type ----

test_that("type must be one of the allowed choices", {
  expect_error(
    lds_metadata(type = "organisations"),
    "type"
  )

  expect_error(
    lds_metadata(type = "orgs"),
    "type"
  )

  expect_error(
    lds_metadata(type = "tables"),
    "type"
  )
})

test_that("type rejects non-string inputs", {
  expect_error(
    lds_metadata(type = 123),
    "type"
  )

  expect_error(
    lds_metadata(type = TRUE),
    "type"
  )

  expect_error(
    lds_metadata(type = NULL),
    "type"
  )

  expect_error(
    lds_metadata(type = NA_character_),
    "type"
  )
})

test_that("type rejects vectors with more than one element", {
  expect_error(
    lds_metadata(type = c("resources", "datasets")),
    "type"
  )
})

test_that("type rejects empty string", {
  expect_error(
    lds_metadata(type = ""),
    "type"
  )
})

# ---- Valid inputs pass validation ----

test_that("type 'resources' is accepted and returns a tibble", {
  skip_if_offline("data.london.gov.uk")

  result <- lds_metadata(type = "resources")

  expect_s3_class(result, "tbl_df")
  expect_gt(nrow(result), 0)
})

test_that("type 'datasets' is accepted and returns a tibble", {
  skip_if_offline("data.london.gov.uk")

  result <- lds_metadata(type = "datasets")

  expect_s3_class(result, "tbl_df")
  expect_gt(nrow(result), 0)
})

test_that("default type is 'resources'", {
  skip_if_offline("data.london.gov.uk")

  result_default <- lds_metadata()
  result_explicit <- lds_metadata(type = "resources")

  expect_equal(names(result_default), names(result_explicit))
  expect_equal(nrow(result_default), nrow(result_explicit))
})

# ---- Column expectations ----

test_that("resources metadata contains expected columns", {
  skip_if_offline("data.london.gov.uk")

  result <- lds_metadata(type = "resources")

  # Column names should be snake_case (via janitor::clean_names)
  col_names <- names(result)
  expect_true(all(col_names == tolower(col_names)))
  expect_true(all(!grepl("\\s", col_names)))
})

test_that("datasets metadata contains expected columns", {
  skip_if_offline("data.london.gov.uk")

  result <- lds_metadata(type = "datasets")

  col_names <- names(result)
  expect_true(all(col_names == tolower(col_names)))
  expect_true(all(!grepl("\\s", col_names)))
})
