#' Get the value in the first column of the clicked row.
#'
#' @return HTML widget
#'
#' @keywords internal
get_clicked_row_value <- function() {
  htmlwidgets::JS(
    "$('div.dataTables_filter input', table.table().container()).focus();

    table.on('click.dt', 'td', function() {
       var clicked_file = table.row(this).data()[0];
       Shiny.onInputChange('clicked_file', clicked_file);
     });")
}

set_filter_focus <- function() {
  htmlwidgets::JS(
    "$('div.dataTables_filter input', table.table().container()).focus();")
}
