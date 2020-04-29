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
      report_list,
      rownames = FALSE,
      height = "100%",
      selection = "none",
      callback = htmlwidgets::JS(
        "table.on('click.dt', 'td', function() {
            var row_=table.cell(this).index().row;
           Shiny.onInputChange('row', row_ + 1 );
        });"),
      options = list(
        paging = FALSE,
        scrollResize = TRUE,
        scrollY = 250,
        scrollCollapse = TRUE)
    )

    shiny::observeEvent(input$row, {
      enter_development_mode(report_list[input$row, "path"])
    })

    # Listen for 'done' events. When we're finished, we'll
    # stop the gadget.
    shiny::observeEvent(input$done, {
      shiny::stopApp()
    })
  }

  # We'll use a pane viwer, and set the minimum height at
  # 300px to ensure we get enough screen space to display.
  viewer <- shiny::paneViewer(300)

  ## Can this be run in a separate process so RStudio console is still usable?
  shiny::runGadget(ui, server, viewer = viewer)
}

list_reports <- function() {
  config <- orderly:::orderly_config_get(NULL, locate = TRUE)
  paths <- orderly:::list_dirs(orderly:::path_src(config$root))
  data.frame(report = basename(paths),
             path = paths,
             stringsAsFactors = FALSE)
}

enter_development_mode <- function(path) {
  setwd(path)
  orderly::orderly_develop_start()
  ## Open wd in file browser
  ## It would be super nice if this works but doesn't work as expected atm
  ## and only opens the working location of the working directory at the time
  ## the shinygadget was started
  ## see https://github.com/rstudio/rstudioapi/issues/148
  ## rstudioapi::executeCommand("goToWorkingDir")
}
