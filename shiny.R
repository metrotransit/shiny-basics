library(shiny)
library(ggplot2)

# generate travel survey dataset
source('generate-travel-data.R')

## first, create one type of plot we'd like to see
p <- ggplot(survey_sim, aes(x = trip_purpose))
p + geom_bar()

# objective: make widget which will allow us to choose which variable to plot, displayed by time of day

# define columns to be choices in the app
xvars <- names(survey_sim)[sapply(survey_sim, is.factor)]

app0 <- shinyApp(
  server = function(input, output) {
    output$main_plot <- renderPlot({
        ggplot(survey_sim, aes_string(x = input$varchoice)) + geom_bar()
    })
  },
  
  ui = shinyUI(
    fluidPage(h4(strong("data exploration plots")),
              p("Plotting counts of observed variables"),
              fluidRow(
                column(3, 
                       selectizeInput(inputId = "varchoice", 
                                      label = "Choose variable:", 
                                      choices = xvars,
                                      selected = xvars[1])),
                column(8,
                       plotOutput(outputId = 'main_plot')
                )# end column
              ) # end FluidRow, 
    ) # end page
    
  ) # end UI
)
app0

## add checkbox option to plot by time

app1 <- shinyApp(
server = function(input, output) {
  output$main_plot <- renderPlot({
    if(input$plotbytime) {
      ggplot(survey_sim, aes(x = factor(hr_surveyed))) + geom_bar(aes_string(fill = input$varchoice)) + 
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    } else {
      ggplot(survey_sim, aes_string(x = input$varchoice)) + geom_bar()
    }
   })
},

ui = shinyUI(
  fluidPage(h4(strong("data exploration plots")),
            p("Plotting density of observed variables, all obs or by time"),
            fluidRow(
              column(3, 
                     selectizeInput(inputId = "varchoice", 
                                    label = "Choose variable:", 
                                    choices = xvars,
                                    selected = xvars[1]),
                    checkboxInput(inputId = 'plotbytime',
                                  label = strong('Plot by time of day'),
                                  value = FALSE)),
              column(8,
                     plotOutput(outputId = 'main_plot')
                     )# end column
              ) # end FluidRow, 
  ) # end page
  
) # end UI
)
app1
