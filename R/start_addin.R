#' Addin for starting develop mode.
#'
#' Allows users to see list of orderly reports and choose one to open in
#' development mode.
#'
#' @export
start_addin <- function() {

  # Our ui will be a simple gadget page, which
  # simply displays the time in a 'UI' output.
  ui <- miniUI::miniPage(
    shiny::includeCSS(system.file("styles", "style.css",
                                  package = "orderly.rstudio")),
    miniUI::miniContentPanel(
      DT::dataTableOutput("reports")
    ),
    miniUI::miniButtonBlock(
      shiny::actionButton("done", "Close",
                          shiny::icon("times"))
    )
  )

  server <- function(input, output, session) {

    report_list <- list_reports()
    output$reports <- DT::renderDataTable(
      DT::datatable(report_list[, c("report", "modified")],
      rownames = FALSE,
      height = "100%",
      selection = "none",
      callback = get_clicked_row_value(),
      options = list(
        paging = FALSE,
        scrollResize = TRUE,
        scrollY = 400,
        scrollCollapse = TRUE)
      ) %>%
      DT::formatDate(2, method = "toLocaleString")
    )

    shiny::observeEvent(input$clicked_file, {
      path <- report_list[report_list$report == input$clicked_file, "path"]
      enter_development_mode(path)
    })

    # Listen for 'done' events. When we're finished, we'll
    # stop the gadget.
    shiny::observeEvent(input$done, {
      shiny::stopApp()
    })
  }

  viewer <- shiny::dialogViewer("Start")
  shiny::runGadget(ui, server, viewer = viewer)
}

list_reports <- function() {
  config <- orderly:::orderly_config_get(NULL, locate = TRUE)
  paths <- orderly:::list_dirs(orderly:::path_src(config$root))
  meta <- file.info(paths)
  data.frame(report = basename(paths),
             path = paths,
             modified = meta$mtime,
             stringsAsFactors = FALSE)
}

enter_development_mode <- function(path) {
  tryCatch({
    setwd(path)
    orderly::orderly_develop_start()
  },
  error = function(e) {
    message(e$message)
    shiny::showNotification(e$message, type = "error")
  })
  ## Open wd in file browser
  ## It would be super nice if this works but doesn't work as expected atm
  ## and only opens the working location of the working directory at the time
  ## the shinygadget was started
  ## see https://github.com/rstudio/rstudioapi/issues/148
  ## rstudioapi::executeCommand("goToWorkingDir")
}
