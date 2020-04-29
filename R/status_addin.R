#' Addin for viewing status of orderly develop mode.
#'
#' Allows users to reload dependencies and to cleanup development mode.
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

    status <- orderly::orderly_develop_status()
    output$status <- render_status(status)

    shiny::observeEvent(input$row, {
      file <- status[input$row, "filename"]
      if (file.exists(status[input$row, "filename"])) {
        rstudioapi::navigateToFile(status[input$row, "filename"])
      } else {
        shiny::showNotification(sprintf("File %s does not exist", file),
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
        status <- orderly::orderly_develop_status()
        output$status <- render_status(status)
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
        status <- orderly::orderly_develop_status()
        output$status <- render_status(status)
      },
      error = function(e) {
        message(e$message)
        shiny::showNotification(e$message, type = "error")
      })
    })
  }

  # We'll use a pane viwer, and set the minimum height at
  # 300px to ensure we get enough screen space to display.
  viewer <- shiny::paneViewer(300)

  ## Can this be run in a separate process so RStudio console is still usable?
  shiny::runGadget(ui, server, viewer = viewer)
}

render_status <- function(status) {
  DT::renderDataTable(
    status,
    callback = htmlwidgets::JS(
      "table.on('click.dt', 'td', function() {
            var row_=table.cell(this).index().row;
           Shiny.onInputChange('row', row_ + 1 );
        });"),
    selection = "none",
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
