# Patch a dataset description

Updates the description page of an existing dataset on the London
Datastore.

## Usage

``` r
lds_patch_description(slug, patch, api_key)
```

## Arguments

- slug:

  A character, url slug of the dataset -
  https://data.london.gov.uk/dataset/

- patch:

  A character, output of
  [`lds_description_render()`](https://greater-london-authority.github.io/ldndatar2/reference/lds_description_render.md)

- api_key:

  A character. London Datastore API key - needed to amend a dataset.

## Value

A response object

## Examples

``` r
if (FALSE) { # \dontrun{
new_description <- lds_description_render("datastore_description.Rmd", save_html = FALSE)
lds_patch_description(slug = "2o8xw", patch = new_description, api_key = Sys.getenv("LDS_API_KEY"))
} # }
```
