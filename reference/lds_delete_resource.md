# Delete a resource in a London Datastore dataset

Deletes a resource (file) on the London Datastore dataset. For security
reasons, it requires file name and id, and it prompts the user to
confirm operation. Requires an API key with write access.

## Usage

``` r
lds_delete_resource(slug, resource_name, resource_id, api_key)
```

## Arguments

- slug:

  URL slug of the dataset – `https://data.london.gov.uk/dataset/<slug>`.

- resource_name:

  A character - the name of the file to be deleted.

- resource_id:

  A character, the resource id.

- api_key:

  London Datastore API key (required for write operations).

## Value

The parsed JSON response from the API (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
lds_delete_resource(
  resource_name = "my_data.csv",
  slug = "my-dataset",
  resource_id = "xxx",
  api_key = Sys.getenv("LDS_API_KEY"),
)
} # }
```
