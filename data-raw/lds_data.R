## code to prepare `lds_data` dataset goes here

# base url - internal
lds_url <- "https://data.london.gov.uk"

# api url for the Datastore - external
lds_url_api <- "https://data.london.gov.uk/api/"

usethis::use_data(lds_url, lds_url_api, overwrite = TRUE, internal = TRUE)
