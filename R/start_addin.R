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

    shinyInput <- function(FUN, len, ids, ...) {
      inputs <- character(len)
      for (i in seq_len(len)) {
        inputs[i] <- as.character(FUN(ids[i], ...))
      }
      inputs
    }

    report_list <- list_reports()
    report_list$action <- shinyInput(
      shiny::actionButton, nrow(report_list), report_list$report,
      label = "Open", class = "btn-hover",
      onclick = 'Shiny.onInputChange(\"open_button\",  this.id)')
    output$reports <- DT::renderDataTable({
      data <- DT::datatable(report_list[, c("report", "modified", "action")],
      escape = FALSE,
      callback = set_filter_focus(),
      rownames = FALSE,
      height = "100%",
      selection = "none",
      options = list(
        paging = FALSE,
        scrollResize = TRUE,
        scrollY = 380,
        scrollCollapse = TRUE,
        language = list(
          search = "Filter:"
        ),
        columnDefs = list(
          list(
            targets = 2,
            orderable = FALSE,
            title = "",
            width = 50
          )
        ))
      )
      DT::formatDate(data, 2, method = "toLocaleString")
    })

    shiny::observeEvent(input$open_button, {
      path <- report_list[report_list$report == input$open_button, "path"]
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
  config <- orderly::orderly_config(NULL, locate = TRUE)
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
  shiny::stopApp()
  rstudioapi::executeCommand("goToWorkingDir")
}

