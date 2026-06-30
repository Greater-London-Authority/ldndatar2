# Download a dataset resource

Downloads resource using URL for a specified resource. This function
replaces the `lds_resource_url` from the original `ldndatar` package.
Because of the new authentication the file has to be downloaded after
the request.

## Usage

``` r
lds_download_resource(
  slug,
  dir = getwd(),
  res_title = NULL,
  res_id = NULL,
  api_key = NULL
)
```

## Arguments

- slug:

  A URL slug of the dataset - https://data.london.gov.uk/dataset/

- dir:

  Where to save the output. Default: current working directory

- res_title:

  The title of the resource, Default: NULL

- res_id:

  The ID of the resource, Default: NULL

- api_key:

  London Datastore API key, only needed for private datasets, Default:
  NULL

## Value

A URL string of the resource
