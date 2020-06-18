#' Addin for starting develop mode.
#'
#' Allows users to see list of orderly reports and choose one to open in
#' development mode.
#'
#' @export
run_addin <- function() {

  # Our ui will be a simple gadget page, which
  # simply displays the time in a 'UI' output.
  ui <- miniUI::miniPage(
    shiny::includeCSS(system.file("styles", "style.css",
                                  package = "orderly.rstudio")),
    shiny::includeCSS(system.file("styles", "run_style.css",
                                  package = "orderly.rstudio")),
    miniUI::miniTabstripPanel(
      id = "runner",
      miniUI::miniTabPanel("report_list",
                      DT::dataTableOutput("reports")
      ),
      miniUI::miniTabPanel("report_runner",
                      miniUI::miniContentPanel(
                        shiny::textOutput("report_name"),
                        shiny::selectInput("remote", "Remote", choices = NULL),
                        ## Should be conditional (don't show if 0 (or readonly if 1?) instance configured)
                        shiny::selectInput("instance", "DB instance",
                                           choices = get_instance_choices()),
                        shiny::uiOutput("parameters")
                      ),
                      shiny::actionButton("go_report_list", "prev"),
                      shiny::actionButton("run_report", "Run")
      )
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
      actionButton, nrow(report_list), report_list$report, label = "Run",
      class = "btn-hover",
      onclick = 'Shiny.onInputChange(\"run_button\",  this.id)')
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

    chosen_report <- shiny::eventReactive(input$run_button, {
      report_list[report_list$report == input$run_button, "report"]
    })

    output$report_name <- shiny::renderText(chosen_report())

    output$parameters <- shiny::renderUI({
      params <- get_report_params(chosen_report())
      lapply(names(params), function(param) {
        ## If integer use int input
        default <- params[[param]]$default
        if (is.numeric(default)) {
          shiny::numericInput(param, param, default)
        } else {
          shiny::textInput(param, param, default)
        }
      })
    })

    switch_page <- function(tab_id) {
      updateTabsetPanel(session, "runner", selected = tab_id)
    }

    shiny::observeEvent(input$run_button, {
      shiny::updateSelectInput(session, "remote",
                               choices = get_remote_choices())
      switch_page("report_runner")
    })

    shiny::observeEvent(input$go_report_list, switch_page("report_list"))

    shiny::observeEvent(input$run_report, {
      if (is.null(input$insance)) {
        inst <- ""
      } else {
        inst <- input$instance
      }
      if (is.null(input$remote)) {
        remote <- ""
      } else {
        remote <- input$remote
      }
      print(sprintf("running %s, instance: %s, remote %s, parameters %s",
                    chosen_report(), inst, remote, "params"))
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


get_remote_choices <- function() {
  config <- orderly::orderly_config(NULL, locate = TRUE)
  names(config$remote)
}

get_instance_choices <- function() {
  config <- orderly::orderly_config(NULL, locate = TRUE)
  instances <- lapply(config$database, function(x) names(x$instances))
  unlist(instances, use.names = FALSE)
}

get_report_params <- function(report) {
  loc <- orderly:::orderly_develop_location(report, NULL, TRUE)
  recipe <- orderly:::orderly_recipe$new(loc$name, loc$config,
                                       develop = FALSE)
  recipe$parameters
}
