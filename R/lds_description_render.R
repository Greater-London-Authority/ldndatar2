#' @title lds_description_render
#' @description Render the input file to html suitable to be used in the description field of a dataset on the London DataStore.
#' @param input The input file to be rendered. This can be an R script (.R), an R Markdown document (.Rmd), or a plain markdown document.
#' @param output_file The name of the output file. If using NULL then the output filename will be based on filename for the input file. If a filename is provided, a path to the output file can also be provided. Note that the output_dir option allows for specifying the output file path as well, however, if also specifying the path, the directory must exist. If output_file is specified but does not have a file extension, an extension will be automatically added according to the output format. To avoid the automatic file extension, put the output_file value in I(), e.g., I('my-output'). Default: NULL
#' @param output_dir The output directory for the rendered output_file. This allows for a choice of an alternate directory to which the output file should be written (the default output directory of that of the input file). If a path is provided with a filename in output_file the directory specified here will take precedence. Please note that any directory path provided will create any necessary directories if they do not exist. Default: NULL
#' @param include_title Include the YAML title in the output, Default: TRUE
#' @param save_html Save a copy of the rendered html. The HTML will be the fragment only (no header, body, CSS etc). Default: TRUE
#' @param return_html Return a copy of the rendered html. Default: TRUE
#' @param ... Other parameters passed to rmarkdown::render
#' @return By default will return the rendered html string.
#' @details A markdown version of the input file is also rendered and saved.
#' @seealso \code{\link[rmarkdown]{render}}
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname lds_description_render
#' @export
#' @import checkmate
#' @importFrom rmarkdown render
#' @import stringr
#' @importFrom markdown markdownToHTML
lds_description_render <- function(
  input,
  output_file = NULL,
  output_dir = NULL,
  include_title = TRUE,
  save_html = TRUE,
  return_html = TRUE,
  ...
) {
  checkmate::assert_file_exists(input, extension = c("R", "Rmd", "md"))
  checkmate::assert_logical(include_title)

  rmarkdown::render(
    input = input,
    output_format = "md_document",
    output_file = output_file,
    output_dir = output_dir,
    ...
  )
  input_file <- basename(input)
  input_dir <- dirname(input)

  if (is.null(output_file)) {
    output_file <- stringr::str_replace(input_file, "\\.[a-zA-Z]+$", "")
  }
  if (is.null(output_dir)) {
    output_dir <- input_dir
  }
  output_md <- paste0(output_file, ".md")
  output_html <- paste0(output_file, ".html")
  if (include_title) {
    # Extract title from Rmd
    rmd_text <- readLines(input)
    rmd_title <- rmd_text[grepl("^title:", rmd_text)] |>
      stringr::str_replace("title: ", "") |>
      stringr::str_replace_all('\\\\"|"|"', "") |>
      stringr::str_split("`") |>
      unlist()

    rmd_title <- rmd_title[rmd_title != ""]
    # Execute any inline R
    for (i in seq_len(length(rmd_title))) {
      if (grepl("^r ", rmd_title[i])) {
        rmd_title[i] <- rmd_title[i] |>
          stringr::str_replace("r ", "") |>
          parse(text = _) |>
          eval()
      }
    }
    rmd_title <- paste(rmd_title, collapse = "")
    md_title <- paste0("# ", rmd_title)
    md_text <- readLines(file.path(output_dir, output_md))
    md_text <- c(md_title, md_text)
    writeLines(md_text, file.path(output_dir, output_md))
  }
  html <- markdown::markdownToHTML(
    file = file.path(output_dir, output_md),
    fragment.only = TRUE
  )
  # Fix html/datastore encoding issues
  # These may need to be added to
  html <- html |>
    # Change " to ' to make string valid
    # Remove any em/en dashes
    stringr::str_replace_all('\\"|“|”|’|\\\\&quot;', "'") |>

    stringr::str_replace_all("\u2013", "-") |>
    stringr::str_replace_all("\u2014", "-") |>
    stringr::str_replace_all("\u00A0", " ") |>
    stringr::str_replace_all("\\_", "_") |>
    stringr::str_replace_all("\\[", "[") |>
    stringr::str_replace_all("\\]", "]") |>
    stringr::str_replace_all("… ", "... ")
  if (save_html) {
    message("Output created: ", file.path(output_dir, output_html))
    writeLines(html, file.path(output_dir, output_html))
  }
  if (return_html) {
    html <- stringr::str_replace_all(html, "\n", "\\n")
    return(html)
  } else {
    invisible(html)
  }
}
