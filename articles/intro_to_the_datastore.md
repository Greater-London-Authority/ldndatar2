# Intro to the London Datastore

The [London Datastore](https://data.london.gov.uk) is a free and open
data-sharing portal where anyone can access data relating to the
capital. Whether you’re a citizen, business owner, researcher or
developer, the site provides over a thousand datasets to help you
understand the city and develop solutions to London’s challenges.

The `ldndatar2` package provides a convenient R interface to the London
Datastore API, enabling users to discover datasets, download resources,
and contribute to the portal directly from R. By streamlining access to
the London Datastore, the package helps analysts incorporate open data
into reproducible, end-to-end workflows.

### Understanding London Datastore terminology

If you’re new to the London Datastore there are a few things you need to
know to navigagte this package:

- **Slug**  
  The slug is the last part of the URL address that serves as an unique
  identifies. For example, in this URL
  `https://data.london.gov.uk/dataset/mps-monthly-crime-dashboard-data-e5n6w`
  the slug is `e5n6w`.

- **Datasets**  
  In the London Datastore, each webpage is referred to as a *dataset*.
  For example, the [Metropolitan Police on Monthly Crime Data
  page](https://data.london.gov.uk/dataset/mps-monthly-crime-dashboard-data-e5n6w)
  is a dataset. You can use the `lds_metadata(type = "datasets")`
  function to get information about available datasets.

- **Resources**  
  Each file in a London Datastore page (dataset) is referred to as a
  resource. For example, the [Metropolitan Police on Monthly Crime Data
  page](https://data.london.gov.uk/dataset/mps-monthly-crime-dashboard-data-e5n6w)
  all csv and excel files are resources. You can use the
  `lds_metadata(type = "resources")` function to get information about
  available resources.

- **Topics**  
  Topics group datasets and resources by subject area, helping users
  discover related content in the London Datastore. You can use
  `lds_metadata(type = "topics")` to retrieve metadata for all available
  topics.

- **Teams**  
  Teams (previously called organisations) are the publishers and
  maintainers of datasets and resources in the London Datastore.
  Examples include the Office for National Statistics (ONS), Transport
  for London (TfL), and the Greater London Authority (GLA). Use
  `lds_metadata(type = "teams")` to retrieve metadata for all teams.

### Exploring the London Datastore using `ldndatar2`

As demonstrated above, `ldndatar2` enables users to download metadata
for datasets, resources, teams, and topics. This functionality helps
users discover resources that may not be directly associated with a
dataset by name or whose descriptions are embedded within an iframe,
making them difficult to locate through the standard web interface.

The
[`lds_download_resource()`](https://greater-london-authority.github.io/ldndatar2/reference/lds_download_resource.md)
function enables users and analysts to integrate API calls directly into
their workflows, reducing manual steps and giving R users greater
flexibility when accessing and processing data.

### `ldndatar2` for publishers

`ldndatar2` helps publishers streamline their workflows by automating
common publishing tasks. For example, for recurring publications that
require regular updates to description pages and resources, `ldndatar2`
reduces the need for repetitive point-and-click and drag-and-drop
actions, via functions like
[`lds_add_resource()`](https://greater-london-authority.github.io/ldndatar2/reference/lds_add_resource.md),
[`lds_replace_resource()`](https://greater-london-authority.github.io/ldndatar2/reference/lds_replace_resource.md)
and
[`lds_patch_description()`](https://greater-london-authority.github.io/ldndatar2/reference/lds_patch_description.md).
This supports the principles of the [Reproducible Analytical Pipelines
(RAP)](https://analysisfunction.civilservice.gov.uk/support/reproducible-analytical-pipelines/)
framework by enabling more automated, consistent, and reproducible
publishing workflows.

`ldndatar2` also allows users to search for the most and least recently
updated datasets and resources, helping teams identify stale resources
and track new publications.

``` r

# Get Datastore metada
metadata <- ldndatar2::lds_metadata(type = "resources")

# Sort by most recent updated
ordered_metada <- metadata[
  order(
    as.Date(metadata$check_timestamp, format = "%Y-%m-%d %H:%M:%S %Z"),
    decreasing = TRUE,
    na.last = NA
  ),
]

# A tibble: 11,323 × 15
#>   dataset_id dataset id                webpage title format permalink url   temporal_coverage_from temporal_coverage_to check_timestamp
#>   <chr>      <chr>   <chr>             <chr>   <chr> <chr>  <chr>     <chr> <date>                 <date>               <dttm>
#> 1 236kk      236kk   3wp               https:… Q4_2… pdf    https://… http… 2026-01-01             2026-03-01           2026-06-16 14:53:05
#> 2 2zjmn      2zjmn   01c5a3ab-b7ae-42… https:… Data… html   https://… http… NA                     NA                   2026-06-16 07:00:00
#> 3 2zjmn      2zjmn   03dee8f3-70a6-4e… https:… Data… html   https://… http… NA                     NA                   2026-06-16 08:00:20
#> 4 2zjmn      2zjmn   0a9b858d-367e-48… https:… Data… html   https://… http… NA                     NA                   2026-06-16 01:00:11
#> 5 2zjmn      2zjmn   0f2d5c6d-4e59-4e… https:… Data… html   https://… http… NA                     NA                   2026-06-16 01:00:10
```
