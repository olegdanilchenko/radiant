#######################################
# Quit menu
#######################################
output$savequit <- renderUI({
  sidebarLayout(
    sidebarPanel(
      wellPanel(
        HTML("<label>Save app state:</label>"),
        downloadButton('downloadStateQuit', 'Save')
      ),
      wellPanel(
        HTML("<label>Reset app state:</label>"),
        HTML("<button id='resetState' type='button' class='btn action-button' onClick='window.location.reload()'>Reset</button></br>"),
        # actionButton('resetState', 'Reset'),
        # uiOutput("refreshOnReset"),
        checkboxInput('showInput', 'Show input', FALSE), br(),
        checkboxInput('showState', 'Show state', FALSE)
      ),
      wellPanel(
        tags$button(id = 'quitApp', type = "button",
                    class = "btn action-button",
                    onclick = "window.close();",
                    "Quit")
      ),
      helpModal('State','stateHelp',inclMD("../base/tools/help/state.md"))
    ),
    mainPanel(
      conditionalPanel(condition = "input.showInput == true",
        verbatimTextOutput("showInput")
      ),
      conditionalPanel(condition = "input.showState == true",
        verbatimTextOutput("showState")
      )
      # , uiOutput("debugTools")
    )
  )
})

output$downloadStateQuit <- downloadHandler(
  filename = function() { paste0("RadiantState-",Sys.Date(),".rsf") },
  content = function(file) {
    saveState(file)
  }
)

output$showInput <- renderPrint({
  isolate({
    cat("Input list:\n")
    inp <- reactiveValuesToList(input)
    str(inp[sort(names(inp))])
  })
})

output$showState <- renderPrint({
  cat("State list:\n")
  if(is.null(state_list)) return()
  if(length(state_list) == 0) return("[empty]")
  str(state_list[sort(names(state_list))])
})

observe({
  if(input$quitApp %>% not_pressed || !running_local) return()

  # quit R, unless you are running Rstudio
  if(Sys.getenv("RSTUDIO") != "1") {
    stopApp("Stopped Radiant")
    q("no")
  } else {
    # flush input and values into Rstudio
    isolate({
      assign("state_list", reactiveValuesToList(input), envir = .GlobalEnv)
      assign("values", reactiveValuesToList(values), envir = .GlobalEnv)
      if(!is.null(input$rmd_report) && input$rmd_report != "") {
        os_type <- .Platform$OS.type
        if (os_type == 'windows') {
          cat(input$rmd_report, file = "clipboard")
        } else {
          cat(input$rmd_report, file = pipe("pbcopy"))
        }
      }
      stopApp(cat("\nStopping Radiant. State flushed to Rstudio as lists 'state_list' and 'values'.\n\n"))
    })
  }
})

# output$refreshOnReset <- renderUI({
#   if(input$resetState %>% not_pressed) return()
#   # Joe Cheng: https://groups.google.com/forum/#!topic/shiny-discuss/Olr8m0JwMTo
#   tags$script("window.location.reload();")
# })
