#' Addin for viewing status of orderly develop mode.
#'
#' Allows users to reload dependencies and to cleanup development mode.
#'
#' @export
status_addin <- function() {

  # Our ui will be a simple gadget page, which
  # simply displays the time in a 'UI' output.
  ui <- miniUI::miniPage(
    shiny::includeCSS(system.file("styles", "style.css",
                                  package = "orderly.rstudio")),
    miniUI::miniContentPanel(
        DT::dataTableOutput("status")
    ),
    miniUI::miniButtonBlock(
      shiny::actionButton("refresh", "Reload dependencies",
                          shiny::icon("redo")),
      shiny::actionButton("clean", "Cleanup develop mode",
                          shiny::icon("broom")),
      shiny::actionButton("done", "Close",
                          shiny::icon("times"))
    )
  )

  server <- function(input, output, session) {

    output$status <- render_status()

    shiny::observeEvent(input$clicked_file, {
      if (file.exists(input$clicked_file)) {
        rstudioapi::navigateToFile(input$clicked_file)
      } else {
        shiny::showNotification(
          sprintf("File %s does not exist", input$clicked_file),
          type = "message")
      }
    })

    # Listen for 'done' events. When we're finished, we'll
    # stop the gadget.
    shiny::observeEvent(input$done, {
      shiny::stopApp()
    })

    ## List for refresh button click
    shiny::observeEvent(input$refresh, {
      tryCatch({
        orderly::orderly_develop_start()
        output$status <- render_status()
      },
      error = function(e) {
        message(e$message)
        shiny::showNotification(e$message, type = "error")
      })
    })

    ## List for clean button click
    shiny::observeEvent(input$clean, {
      tryCatch({
        orderly::orderly_develop_clean()
        output$status <- render_status()
      },
      error = function(e) {
        message(e$message)
        shiny::showNotification(e$message, type = "error")
      })
    })
  }

  viewer <- shiny::dialogViewer("Status")
  shiny::runGadget(ui, server, viewer = viewer)
}

render_status <- function() {
  DT::renderDataTable(
    orderly::orderly_develop_status(),
    callback = get_clicked_row_value(),
    selection = "none",
    rownames = FALSE,
    height = "100%",
    escape = FALSE,
    options = list(
      paging = FALSE,
      scrollResize = TRUE,
      scrollY = 400,
      scrollCollapse = TRUE)
  )
}
