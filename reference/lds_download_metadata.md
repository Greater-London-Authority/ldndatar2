# Download dataset metadata

Adapted from the original ldndatar pkg. This updated function downloads
the metadata of a given page slug. i.e. will let you know the metadata
about a given page on the London Datastore.

## Usage

``` r
lds_download_metadata(slug, api_key = NULL, inc_tables = FALSE)
```

## Arguments

- slug:

  a URL slug of the dataset - https://data.london.gov.uk/dataset/slug

- api_key:

  London Datastore API key, needed for private datasets, Default: NULL

- inc_tables:

  whether to include data on any tables in the dataset, Default: FALSE

## Value

A tibble of metadata
