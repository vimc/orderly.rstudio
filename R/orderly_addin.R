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

    output$status <- DT::renderDataTable(
      orderly::orderly_develop_status(),
      rownames = FALSE,
      height = "100%",
      options = list(
        paging = FALSE,
        scrollResize = TRUE,
        scrollY = 250,
        scrollCollapse = TRUE)
    )

    # Listen for 'done' events. When we're finished, we'll
    # stop the gadget.
    shiny::observeEvent(input$done, {
      shiny::stopApp()
    })

    ## Listen for start button click
    observeEvent(input$start, {
      tryCatch({
        orderly::orderly_develop_start()
      },
      error = function(e) {
        message(e$message)
      })
    })

    ## List for cleanup button click
    observeEvent(input$cleanup, {
      orderly::orderly_develop_clean()
    })
  }

  # We'll use a pane viwer, and set the minimum height at
  # 300px to ensure we get enough screen space to display.
  viewer <- shiny::paneViewer(300)

  ## Can this be run in a separate process so RStudio console is still usable?
  shiny::runGadget(ui, server, viewer = viewer)
}
