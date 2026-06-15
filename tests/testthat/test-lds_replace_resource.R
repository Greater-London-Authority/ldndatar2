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
  testthat::expect_error(
    lds_replace_resource(
      file_path = tmp,
      slug = "abcde",
      resource_name = 123,
      resource_id = "res-001",
      api_key = "key-123"
    )
  )

  # resource_id must be a string
  testthat::expect_error(
    lds_replace_resource(
      file_path = tmp,
      slug = "abcde",
      resource_name = "my-resource.csv",
      resource_id = 999,
      api_key = "key-123"
    )
  )

  # api key should be string
  testthat::expect_error(
    lds_replace_resource(
      file_path = tmp,
      slug = "abcde",
      resource_name = "my-resource.csv",
      resource_id = "res-001",
      api_key = 123
    )
  )
})

testthat::test_that("lds_replace_resource stops when resource not found", {
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
    testthat::expect_error(
      lds_replace_resource(
        file_path = tmp,
        slug = "abcde",
        resource_name = "different-name.csv",
        resource_id = "res-001",
        api_key = "key-123"
      ),
      "Resource not found, check inputs."
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
    testthat::expect_error(
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

httptest2::with_mock_api({
  tmp <- "text-fixture/another_file.txt"
  tmp_error <- "text-fixture/text.txt"

  mock_metadata <- function(...) {
    data.frame(
      dataset_id = "vd4q4",
      id = "7yw",
      title = "another_file.txt",
      stringsAsFactors = FALSE
    )
  }

  testthat::test_that("lds_replace_resource calls POST method", {
    httptest2::expect_POST(
      testthat::with_mocked_bindings(
        readline = function(...) "1",
        lds_metadata = mock_metadata,
        lds_replace_resource(
          file_path = tmp,
          slug = "vd4q4",
          resource_name = "another_file.txt",
          resource_id = "7yw",
          api_key = "api_key"
        )
      ),
      "https://data.london.gov.uk/api/dataset/vd4q4/resources/7yw"
    )
  })
  testthat::test_that("lds_replace_resource returns invisibly on success", {
    testthat::expect_error(
      testthat::with_mocked_bindings(
        readline = function(...) "1",
        lds_metadata = function(...) {
          data.frame(
            dataset_id = "vd4q4",
            id = "7yw",
            title = "another_file.txt",
            stringsAsFactors = FALSE
          )
        },
        lds_replace_resource(
          file_path = tmp_error,
          slug = "vd4q4",
          resource_name = "another_file.txt",
          resource_id = "7yw",
          api_key = "api_key"
        )
      ),
      "File names don't match, use `lds_add_resource` or check file name."
    )
  })
})

# httptest2::capture_requests({
#   lds_replace_resource(
#     file_path = "test_file.txt",
#     slug = "vd4q4",
#     resource_name = "test_file.txt",
#     resource_id = "7yw",
#     api_key = api_key
#   )
# })
