# ---- Input validation ----

test_that("slug must be a string", {
  expect_error(
    lds_patch_description(slug = 123, patch = "p", api_key = "k"),
    "slug"
  )

  expect_error(
    lds_patch_description(slug = NULL, patch = "p", api_key = "k"),
    "slug"
  )

  expect_error(
    lds_patch_description(slug = NA_character_, patch = "p", api_key = "k"),
    "slug"
  )
})

test_that("patch must be a string", {
  expect_error(
    lds_patch_description(slug = "abcde", patch = 123, api_key = "k"),
    "patch"
  )

  expect_error(
    lds_patch_description(slug = "abcde", patch = NULL, api_key = "k"),
    "patch"
  )
})

test_that("api_key must be a string", {
  expect_error(
    lds_patch_description(slug = "abcde", patch = "p", api_key = 123),
    "api_key"
  )

  expect_error(
    lds_patch_description(slug = "abcde", patch = "p", api_key = NULL),
    "api_key"
  )
})

# ---- Request shape ----
#
# We can only observe the first PATCH (description) before without_internet()
# raises. That's enough to pin the URL and body shape; the second PATCH
# (updatedAt) reuses the same code path.

httptest2::without_internet({
  test_that("sends a PATCH to the dataset endpoint with a json-patch body", {
    # expect_PATCH concatenates trailing args into a single substring matcher
    # against the request body, so the matcher is one contiguous slice.
    httptest2::expect_PATCH(
      lds_patch_description(
        slug = "abcde",
        patch = "<p>new description</p>",
        api_key = "api-key-123"
      ),
      "https://data.london.gov.uk/api/dataset/abcde",
      '[{"op":"replace","path":"/description","value":"<p>new description'
    )
  })
})
