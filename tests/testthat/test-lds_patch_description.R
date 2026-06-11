httptest2::without_internet({
  testthat::test_that("Calling PATCH method...", {
    httptest2::expect_PATCH(
      lds_patch_description("slug", "patch", "api_key")
    )
  })
})
