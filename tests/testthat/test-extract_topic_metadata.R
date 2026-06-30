testthat::test_that("Test cleaning metadata...", {
  input <- list(list(
    webpage = "https://data.london.gov.uk/dataset/webpage-test",
    id = "webpage-test",
    team = list(id = "12xx3", title = "Greater London Authority"),
    topics = list(
      list(id = "art-and-culture", title = "Art and Culture"),
      list(id = "business-and-economy", title = "Business and Economy")
    )
  ))

  expected_output <- data.frame(
    id = c("art-and-culture", "business-and-economy"),
    title = c("Art and Culture", "Business and Economy")
  )
  output <- extract_topic_metadata(input)

  expect_identical(output, expected_output)
  expect_identical(nrow(output), nrow(expected_output))

  expect_error(extract_topic_metadata())

  # Bad input
  expect_error(extract_topic_metadata(
    res = list(list(
      webpage = "https://data.london.gov.uk/dataset/webpage-test",
      id = "id",
      topic = list(),
    ))
  ))
})
