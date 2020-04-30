#' Get the value in the first column of the clicked row.
#'
#' @return HTML widget
#'
#' @keywords internal
get_clicked_row_value <- function() {
  htmlwidgets::JS(
    "table.on('click.dt', 'td', function() {
       var clicked_file = table.row(this).data()[0];
       Shiny.onInputChange('clicked_file', clicked_file);
     });")
}
