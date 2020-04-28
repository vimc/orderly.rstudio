#' Adding for orderly develop mode.
#'
#' Opens in view pane. Button to allow users to start, shows an updating(?)
#' status. Allows users to cleanup develop mode.
#'
#' @export
develop_addin <- function() {

  # Our ui will be a simple gadget page, which
  # simply displays the time in a 'UI' output.
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("Orderly Develop"),
    miniUI::miniContentPanel(
        shiny::tableOutput("status")
    ),
    miniUI::miniButtonBlock(
      shiny::actionButton("start", "Start develop mode"),
      shiny::actionButton("clean", "Cleanup develop mode")
    )
  )

  server <- function(input, output, session) {

    # We'll use a 'reactiveTimer()' to force Shiny
    # to update and show the clock every second.
    invalidatePeriodically <- shiny::reactiveTimer(intervalMs = 1000)
    shiny::observe({

      # Call our reactive timer in an 'observe' func"2020-04-27 18:24:30"tion
      # to ensure it's repeatedly fired.
      invalidatePeriodically()

      # Get the time, and render it as a large paragraph element.
      output$status <- shiny:::renderTable({
        orderly::orderly_develop_status()
      })
    })

    # Listen for 'done' events. When we're finished, we'll
    # stop the gadget.
    shiny::observeEvent(input$done, {
      shiny::stopApp()
    })

    ## Listen for start button click
    observeEvent(input$start, {
      orderly::orderly_develop_start()
    })

    ## List for cleanup button click
    observeEvent(input$cleanup, {
      orderly::orderly_develop_clean()
    })
  }

  # We'll use a pane viwer, and set the minimum height at
  # 300px to ensure we get enough screen space to display.
  viewer <- shiny::paneViewer(300)
  shiny::runGadget(ui, server, viewer = viewer)
}
