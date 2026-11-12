# ldndatar2 (development version)

* `lds_download_metadata()` now reports its own messages for private,
  forbidden and missing datasets. httr2 raised a generic HTTP error before
  they were reached. Any other failed status now errors with its code, and
  `inc_tables` must be a single `TRUE` or `FALSE`.

* The "updated at" timestamp set after adding or deleting a resource is now
  sent as a JSON Patch on `/updatedAt`, in UTC, the same way
  `lds_patch_description()` sets it. It was sent as a plain `updated_at`
  field the endpoint doesn't take.

* `lds_patch_description()` sends `updatedAt` as a UTC ISO 8601 timestamp.
  It sent local time with no zone, so it was an hour out during BST. It also
  now returns the response invisibly, as documented.
