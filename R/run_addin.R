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
                           miniUI::miniContentPanel(
                             DT::dataTableOutput("reports")
                           ),
                           miniUI::miniButtonBlock(
                             shiny::actionButton("done", "Close",
                                                 shiny::icon("times"))
                           )
      ),
      miniUI::miniTabPanel("report_runner",
                      miniUI::miniContentPanel(
                        shiny::textOutput("report_name"),
                        shiny::uiOutput("remote"),
                        ## Should be conditional (don't show if 0 (or readonly if 1?) instance configured)
                        shiny::uiOutput("instance"),
                        shiny::uiOutput("parameters")
                      ),
                      miniUI::miniContentPanel(
                        shiny::verbatimTextOutput("log")
                      ),
                      miniUI::miniButtonBlock(
                        shiny::actionButton("go_report_list", "Back",
                                            shiny::icon("arrow-left")),
                        shiny::actionButton("done2", "Close",
                                            shiny::icon("times")),
                        shiny::actionButton("run_report", "Run",
                                            shiny::icon("play"))
                      )
      )
    )
  )

  server <- function(input, output, session) {

    rv <- shiny::reactiveValues()

    shinyInput <- function(FUN, len, ids, ...) {
      inputs <- character(len)
      for (i in seq_len(len)) {
        inputs[i] <- as.character(FUN(ids[i], ...))
      }
      inputs
    }

    ## Build report list
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

    ## On clicking run from report list
    ## Populate chosen_report variable rendering it in the page
    ## and build the report runner form UI then switch to it
    chosen_report <- shiny::eventReactive(input$run_button, {
      report_list[report_list$report == input$run_button, "report"]
    })
    output$report_name <- shiny::renderText(chosen_report())

    output$remote <- shiny::renderUI({
        choices <- get_remote_choices()
        if (length(choices) > 0) {
          choices <- c("local", choices)
          shiny::selectInput("remote_select", "Remote", choices = choices)
        }
      })
      output$instance <- shiny::renderUI({
        choices <- get_instance_choices()
        if (length(choices) > 0) {
          choices <- c("local", choices)
          shiny::selectInput("instance_select", "DB instance",
                             choices = choices)
        }
      })

      output$parameters <- shiny::renderUI({
        message("rendering UI")
        rv$parameters_ui
      })

      shiny::observe({
        report_name <- chosen_report()
        message(report_name)
        params <- get_report_params(report_name)
        ids <- paste0("param_", names(params))
        add_input <- function(id, name, default) {
          if (is.numeric(default)) {
            shiny::numericInput(id, name, default)
          } else {
            shiny::textInput(id, name, default)
          }
        }
        if (length(params) == 0) {
          rv$parameters_ui <- NULL
          rv$parameters_id <- NULL
        } else {
          rv$parameters_ui <- Map(add_input, ids, names(params), unname(params))
          rv$parameters_id <- setNames(ids, names(params))
        }
      })

      switch_page("report_runner")
    })


    ## On clicking back to report list from repot runner page
    ## Show the report list again and null selected
    shiny::observeEvent(input$go_report_list, {
      switch_page("report_list")
    })

    ## Action taken when a report is run from report runner page
    shiny::observeEvent(input$run_report, {
      params <- get_params(input, rv$parameters_id)
      inst <- input$instance
      remote <- input$remote
      if (identical(inst, "local")) {
        inst <- NULL
      }
      if (identical(remote, "local")) {
        remote <- NULL
      }
      output$log <- shiny::renderText(
        capture(orderly::orderly_run(name = chosen_report(),
                                     parameters = params,
                                     instance = input$instance,
                                     remote = input$remote)),
                sep = "\n")
    })

    ## Helper for programatically switching between panels
    switch_page <- function(tab_id) {
      updateTabsetPanel(session, "runner", selected = tab_id)
    }

    # Listen for 'done' events. When we're finished, we'll
    # stop the gadget.
    shiny::observeEvent(input$done, {
      shiny::stopApp()
    })
    shiny::observeEvent(input$done2, {
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

get_params <- function(input, ids) {
  setNames(lapply(ids, function(x) input[[x]]), names(ids))
}

capture <- function(do) {
  t <- tempfile()
  sink_output_no <- sink.number("output")
  sink_message_no <- sink.number("message")
  con <- file(t, open = "w")
  sink(con, type = "message")
  sink(con, append = T, type = "output")
  new_out_sink_count <- sink.number(type = "output") - sink_output_no
  on.exit(for (i in seq_len(new_out_sink_count)) {
    sink(NULL, type = "output")
  })
  new_message_sink_count <- sink.number(type = "message") - sink_message_no
  on.exit(for (i in seq_len(new_message_sink_count)) {
    sink(NULL, type = "message")
  }, add = TRUE)
  on.exit(close(con), add = TRUE)
  out <- eval(do)
  print(out)
  readLines(t)
}

