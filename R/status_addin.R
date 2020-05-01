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
      shiny::fillCol(
        flex = c(1, NA),
        DT::dataTableOutput("status"),
        DT::dataTableOutput("legend")
      )
    ),
    miniUI::miniButtonBlock(
      shiny::actionButton("refresh", "Reload dependencies",
                          shiny::icon("redo"),
                          class = "btn-success"),
      shiny::actionButton("clean", "Cleanup develop mode",
                          shiny::icon("broom"),
                          class = "btn-danger"),
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

    output$legend <- draw_legend()

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
  status <- get_status()
  DT::renderDataTable({
    data <- DT::datatable(
      status,
      callback = get_clicked_row_value(),
      selection = "none",
      rownames = FALSE,
      height = "100%",
      escape = FALSE,
      options = list(
        paging = FALSE,
        scrollResize = TRUE,
        scrollY = 400,
        scrollCollapse = TRUE,
        columnDefs = list(
          list(
            visible = FALSE,
            targets = 4
          )
        ))
    )
    DT::formatStyle(data, "colour",
                    target = "row",
                    color = "white",
                    backgroundColor =
                      DT::styleEqual(status$colour, status$colour))
  })
}

draw_legend <- function() {
  colours <- get_colours()
  legend <- data.frame(text = c(
    "Not derived",
    "Derived and present (will be removed by cleanup)",
    "Derived and missing (will be created by refreshing sources)"),
    colour = c(colours$blue, colours$green, colours$red),
    stringsAsFactors = FALSE)
  DT::renderDataTable({
    data <- DT::datatable(
      legend,
      selection = "none",
      rownames = FALSE,
      colnames = FALSE,
      height = "100%",
      escape = FALSE,
      options = list(
        paging = FALSE,
        searching = FALSE,
        info = FALSE,
        scrollResize = TRUE,
        scrollY = 400,
        scrollCollapse = TRUE,
        columnDefs = list(
          list(
            visible = FALSE,
            targets = 1
          )
        ))
    )
    DT::formatStyle(data, "colour",
                    target = "row",
                    color = "white",
                    backgroundColor =
                      DT::styleEqual(legend$colour, legend$colour))
  })
}

get_status <- function() {
  status <- orderly::orderly_develop_status()
  colours <- get_colours()
  status$colour <-  ifelse(
    status$present,
    ifelse(status$derived, colours$green, colours$blue),
    ifelse(status$derived, colours$red, colours$white))
  status$present <- ifelse(status$present,
                           as.character(shiny::icon("check")),
                           as.character(shiny::icon("times"))
  )
  status$derived <- ifelse(status$derived,
                           as.character(shiny::icon("check")),
                           as.character(shiny::icon("times"))
  )
  status
}
