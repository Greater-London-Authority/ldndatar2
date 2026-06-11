# ldndatar2

`ldndatar2` provides functions to access and download data, metadata,
and resources from the [London Datastore](https://data.london.gov.uk).
This package is an updated successor to the original `ldndatar` package,
utilising the current London Datastore API. It allows users to
programmatically catalogue, query, and retrieve datasets published by
the Greater London Authority and partner organisations.

## Installation

You can install `ldndatar2` directly from GitHub. The package is not
available on CRAN.

``` r

# install.packages("pak")
pak::pak("Greater-London-Authority/ldndatar2")
```

Or using `remotes`:

``` r

# install.packages("remotes")
remotes::install_github("Greater-London-Authority/ldndatar2")
```

## Getting Started

``` r

library(ldndatar2)

# Browse available datasets
datasets <- lds_metadata(type = "datasets")

# Browse available resources
resources <- lds_metadata(type = "resources")

# Download metadata for a specific dataset
metadata <- lds_download_metadata(slug = "your-dataset-slug")

# Download a resource to your working directory
lds_download_resource(slug = "your-dataset-slug")
```

### Private Datasets

Some datasets on the London Datastore are private and require an API
key. See
[`vignette("get_london_datastore_api_key")`](https://greater-london-authority.github.io/ldndatar2/articles/get_london_datastore_api_key.md)
for instructions on obtaining one.

``` r

# Access a private dataset using an API key
metadata <- lds_download_metadata(slug = "private-dataset-slug", api_key = "your-api-key")
```
