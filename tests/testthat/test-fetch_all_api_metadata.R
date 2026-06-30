httptest2::without_internet({
  testthat::test_that("Calling GET method...", {
    httptest2::expect_GET(
      fetch_all_api_metadata(),
      "https://data.london.gov.uk/api/v3/datasets/export.json"
    )
  })
})

httptest2::with_mock_api({
  testthat::test_that("We get the json metadata...", {
    metadata <- fetch_all_api_metadata()[[1]]

    expect_identical(metadata$id, "2xxx0")
    expect_identical(metadata$team$id, "53oj7")
    expect_identical(metadata$title, "Mocking API call")
    expect_null(metadata$license)
    expect_null(metadata$orgs)
  })
})
