# ---- Input validation: type ----

test_that("type must be one of the allowed choices", {
  expect_error(
    lds_meta_data(type = "organisations"),
    "type"
  )

  expect_error(
    lds_meta_data(type = "orgs"),
    "type"
  )

  expect_error(
    lds_meta_data(type = "tables"),
    "type"
  )
})

test_that("type rejects non-string inputs", {
  expect_error(
    lds_meta_data(type = 123),
    "type"
  )

  expect_error(
    lds_meta_data(type = TRUE),
    "type"
  )

  expect_error(
    lds_meta_data(type = NULL),
    "type"
  )

  expect_error(
    lds_meta_data(type = NA_character_),
    "type"
  )
})

test_that("type rejects vectors with more than one element", {
  expect_error(
    lds_meta_data(type = c("resources", "datasets")),
    "type"
  )
})

test_that("type rejects empty string", {
  expect_error(
    lds_meta_data(type = ""),
    "type"
  )
})

# ---- Valid inputs pass validation ----

test_that("type 'resources' is accepted and returns a tibble", {
  skip_if_offline("data.london.gov.uk")

  result <- lds_meta_data(type = "resources")

  expect_s3_class(result, "tbl_df")
  expect_gt(nrow(result), 0)
})

test_that("type 'datasets' is accepted and returns a tibble", {
  skip_if_offline("data.london.gov.uk")

  result <- lds_meta_data(type = "datasets")

  expect_s3_class(result, "tbl_df")
  expect_gt(nrow(result), 0)
})

test_that("default type is 'resources'", {
  skip_if_offline("data.london.gov.uk")

  result_default <- lds_meta_data()
  result_explicit <- lds_meta_data(type = "resources")

  expect_equal(names(result_default), names(result_explicit))
  expect_equal(nrow(result_default), nrow(result_explicit))
})

# ---- Column expectations ----

test_that("resources metadata contains expected columns", {
  skip_if_offline("data.london.gov.uk")

  result <- lds_meta_data(type = "resources")

  # Column names should be snake_case (via janitor::clean_names)
  col_names <- names(result)
  expect_true(all(col_names == tolower(col_names)))
  expect_true(all(!grepl("\\s", col_names)))
})

test_that("datasets metadata contains expected columns", {
  skip_if_offline("data.london.gov.uk")

  result <- lds_meta_data(type = "datasets")

  col_names <- names(result)
  expect_true(all(col_names == tolower(col_names)))
  expect_true(all(!grepl("\\s", col_names)))
})
