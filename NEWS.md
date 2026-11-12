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

* `lds_delete_resource()` and `lds_replace_resource()` look the resource up
  on the dataset itself, with the API key, rather than in the public resource
  export. Resources on private datasets were always reported as not found.

* `lds_description_render()` renders into a directory of its own and reads
  the file `rmarkdown::render()` returns. It globbed every `.html` file in
  the session's temp directory, so a second call, or any other html file
  there, made it fail. The output is read as UTF-8, and `include_title` is
  checked as a single flag.

* `lds_download_resource()` checks that `dir` exists before downloading,
  gives a clear error for a dataset with no resources, and documents that it
  returns the path of the downloaded file.
