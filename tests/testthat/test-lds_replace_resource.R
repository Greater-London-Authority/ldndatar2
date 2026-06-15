testthat::test_that("lds_replace_resource validates inputs", {
  # file_path must exist
  testthat::expect_error(
    lds_replace_resource(
      file_path = "nonexistent_file.csv",
      slug = "abcde",
      resource_name = "my-resource.csv",
      resource_id = "res-001",
      api_key = "key-123"
    )
  )

  tmp <- withr::local_tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", tmp)

  # slug must be >= 5 chars
  testthat::expect_error(
    lds_replace_resource(
      file_path = tmp,
      slug = "ab",
      resource_name = "my-resource.csv",
      resource_id = "res-001",
      api_key = "key-123"
    )
  )

  # resource_name must be a string
  expect_error(
    lds_replace_resource(
      file_path = tmp,
      slug = "abcde",
      resource_name = 123,
      resource_id = "res-001",
      api_key = "key-123"
    )
  )
})

test_that("lds_replace_resource stops when resource not found", {
  tmp <- withr::local_tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", tmp)

  testthat::with_mocked_bindings(
    lds_metadata = function(type) {
      data.frame(
        dataset_id = "abcde",
        id = "res-001",
        title = "my-resource.csv",
        stringsAsFactors = FALSE
      )
    },
    {
      testthat::expect_error(
        lds_replace_resource(
          file_path = tmp,
          slug = "abcde",
          resource_name = "missing-resource.csv",
          resource_id = "res-001",
          api_key = "key-123"
        ),
        "Resource not found."
      )
    }
  )
})

testthat::test_that("lds_replace_resource stops when file names don't match", {
  tmp <- withr::local_tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", tmp)

  httptest2::with_mock_api({
    expect_error(
      lds_replace_resource(
        file_path = tmp,
        slug = "abcde",
        resource_name = "different-name.csv",
        resource_id = "res-001",
        api_key = "key-123"
      ),
      regexp = "Resource not found, check inputs."
    )
  })
})

testthat::test_that("lds_replace_resource aborts when user answers 2", {
  tmp <- file.path(tempdir(), "my-resource.csv")
  writeLines("a,b\n1,2", tmp)

  testthat::with_mocked_bindings(
    lds_metadata = function(type) {
      data.frame(
        dataset_id = "abcde",
        id = "res-001",
        title = "my-resource.csv",
        stringsAsFactors = FALSE
      )
    },
    readline = function(...) "2",
    {
      testthat::expect_error(
        lds_replace_resource(
          file_path = tmp,
          slug = "abcde",
          resource_name = "my-resource.csv",
          resource_id = "res-001",
          api_key = "key-123"
        ),
        "Operation aborted."
      )
    }
  )
})

testthat::test_that("lds_replace_resource stops on invalid confirmation input", {
  tmp <- withr::local_tempfile(
    tmpdir = tempdir(),
    pattern = "my-resource",
    fileext = ".csv"
  )
  writeLines("a,b\n1,2", tmp)

  httptest2::with_mock_api({
    expect_error(
      testthat::with_mocked_bindings(
        lds_metadata = function(type) {
          data.frame(
            dataset_id = "abcde",
            id = "res-001",
            title = basename(tmp),
            stringsAsFactors = FALSE
          )
        },
        readline = function(...) "9",

        {
          lds_replace_resource(
            file_path = tmp,
            slug = "abcde",
            resource_name = basename(tmp),
            resource_id = "res-001",
            api_key = "key-123"
          )
        }
      ),
      regexp = "Invalid option."
    )
  })
})
