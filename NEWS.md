# ldndatar2 (development version)

* `lds_download_metadata()` now reports its own messages for private,
  forbidden and missing datasets. httr2 raised a generic HTTP error before
  they were reached. Any other failed status now errors with its code, and
  `inc_tables` must be a single `TRUE` or `FALSE`.
