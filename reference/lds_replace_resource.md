# Replace a resource in a London Datastore dataset

Replaces a resource (file) in the London Datastore dataset. This
function should be use to replace files with with the same name (title).
If file names don't match, user is encourage to call `lds_add_resource`
instead. For security reasons, it requires file name and id, and it
prompts the user to confirm operation. Requires an API key with write
access.

## Usage

``` r
lds_replace_resource(file_path, slug, resource_name, resource_id, api_key)
```

## Arguments

- file_path:

  A character - path where file to replace is located.

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
lds_replace_resource(
  file_path = "path/to/my_data.csv",
  slug = "my-dataset",
  resource_name = "my_data.csv",
  resource_id = "xxx",
  api_key = Sys.getenv("LDS_API_KEY"),
)
} # }
```
