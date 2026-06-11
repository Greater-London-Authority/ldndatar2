testthat::test_that("Test html title fixer, add operation...", {
  input <- "<title>This is the title</title><h1>This is another title</h1><p>This is some text in a paragraph.</p><p>And this is another paraph.</p>"

  expected_output <- "<h1>This is another title</h1><p>This is some text in a paragraph.</p><p>And this is another paraph.</p>"

  output <- fix_html_title(input_html = input, operation = "add")

  expect_identical(output, expected_output)
})

testthat::test_that("Test html title fixer, remove operation...", {
  input <- "<title>This is the title</title><h1>This is another title</h1><h2>And another title</h2>"

  expected_output <- ""

  output <- fix_html_title(input_html = input, operation = "remove")

  expect_identical(output, expected_output)
  expect_identical(nchar(output), nchar(expected_output))
})

testthat::test_that("Testing input validation...", {
  expect_error(fix_html_title(input_html = "input", operation = "adds"))
  expect_error(fix_html_title(input_html = "input", operation = "fix"))
  expect_error(fix_html_title(input_html = "input", operation = ""))
  expect_error(fix_html_title(input_html = "input"))
})
