# Add a resource to a London Datastore dataset

Uploads a file as a new resource to an existing dataset on the London
Datastore. Requires an API key with write access.

## Usage

``` r
lds_add_resource(
  file_path,
  slug,
  api_key,
  res_title = NULL,
  description = NULL,
  temporal_coverage_from = NULL,
  temporal_coverage_to = NULL,
  update_timestamp = TRUE
)
```

## Arguments

- file_path:

  Path to the file to upload.

- slug:

  URL slug of the dataset - `https://data.london.gov.uk/dataset/<slug>`.

- api_key:

  London Datastore API key (required for write operations).

- res_title:

  Resource title. If `NULL`, the file name is used. Default: `NULL`.

- description:

  Description of the resource. Default: `NULL`.

- temporal_coverage_from:

  Optional start date (`Date` or `character`). Default: `NULL`.

- temporal_coverage_to:

  Optional end date (`Date` or `character`). Default: `NULL`.

- update_timestamp:

  Whether to set the dataset's "updated at" timestamp to the current
  time after upload. Default: `TRUE`.

## Value

The parsed JSON response from the API (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
lds_add_resource(
  file_path = "data/my_data.csv",
  slug = "2o8xw",
  api_key = Sys.getenv("LDS_API_KEY"),
  res_title = "My Data CSV",
  description = "Monthly counts of things"
)
} # }
```
