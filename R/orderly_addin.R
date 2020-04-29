#' Adding for orderly develop mode.
#'
#' Opens in view pane. Button to allow users to start, shows an updating(?)
#' status. Allows users to cleanup develop mode.
#'
#' @export
status_addin <- function() {

  # Our ui will be a simple gadget page, which
  # simply displays the time in a 'UI' output.
  ui <- miniUI::miniPage(
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

    # Listen for 'done' events. When we're finished, we'll
    # stop the gadget.
    shiny::observeEvent(input$done, {
      shiny::stopApp()
    })

    ## List for refresh button click
    observeEvent(input$refresh, {
      tryCatch({
        orderly::orderly_develop_start()
        output$status <- render_status()
      },
      error = function(e) {
        message(e$message)
        showNotification(e$message, type = "error")
      })
    })

    ## List for clean button click
    observeEvent(input$clean, {
      tryCatch({
        orderly::orderly_develop_clean()
        output$status <- render_status()
      },
      error = function(e) {
        message(e$message)
        showNotification(e$message, type = "error")
      })
    })
  }

  # We'll use a pane viwer, and set the minimum height at
  # 300px to ensure we get enough screen space to display.
  viewer <- shiny::paneViewer(300)

  ## Can this be run in a separate process so RStudio console is still usable?
  shiny::runGadget(ui, server, viewer = viewer)
}

render_status <- function() {
  DT::renderDataTable(
    orderly::orderly_develop_status(),
    rownames = FALSE,
    height = "100%",
    escape = FALSE,
    options = list(
      paging = FALSE,
      scrollResize = TRUE,
      scrollY = 250,
      scrollCollapse = TRUE)
  )
}
