## code to prepare `DATASET` dataset goes here

#* Base URL
lds_url <- "https://data.london.gov.uk"

#* API URL
lds_api_url <- "https://data.london.gov.uk/api/"


#* Save as internal for user
usethis::use_data(lds_url, lds_api_url, overwrite = TRUE, internal = TRUE)
