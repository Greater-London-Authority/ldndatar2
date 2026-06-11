# lds_description_render

Render the input file to html suitable to be used in the description
field of a dataset on the London DataStore.

## Usage

``` r
lds_description_render(input, include_title = FALSE, ...)
```

## Arguments

- input:

  The input file to be rendered. This can be an R script (.R), an R
  Markdown document (.Rmd), or a plain markdown document.

- include_title:

  Include the YAML title in the output, Default: TRUE

- ...:

  Other parameters passed to rmarkdown::render

## Value

By default will return the rendered html string.

## Details

A markdown version of the input file is also rendered and saved.

## See also

[`render`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)

## Examples

``` r
if (FALSE) { # \dontrun{
lds_description_render(input = "my_description.Rmd")
} # }
```
