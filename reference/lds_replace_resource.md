# Replace a resource in a London Datastore dataset

Replaces a resource (file) in the London Datastore dataset. Use this to
replace files that keep the same name (title). If the file names don't
match, call
[`lds_add_resource()`](https://greater-london-authority.github.io/ldndatar2/reference/lds_add_resource.md)
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

  URL slug of the dataset - `https://data.london.gov.uk/dataset/<slug>`.

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
  slug = "2o8xw",
  resource_name = "my_data.csv",
  resource_id = "xxx",
  api_key = Sys.getenv("LDS_API_KEY")
)
} # }
```
