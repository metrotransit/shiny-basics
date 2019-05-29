---
layout: page
element: notes
title: shiny
language: R
---

### [Shiny](https://shiny.rstudio.com/tutorial/)

Shiny is a way to build websites with interactive data visualization.
It is a system implemented in R, but connected to many html
"widgets" and JavaScript libraries to produce web content.

Like the other tools we have been examining, Shiny produces
html that can be stand-alone (in a browser) or made into a hosted
page on the web ([shinyapps.io](http://www.shinyapps.io/)).

Shiny websites can be:

* used to interact with your own data
* used to visualize multi-dimensional data one chunk at a time
* can replace page after page of faceted plots

They can include interactive elements like dropdown lists,
radio buttons, checkboxes, and so on. These can call code
in R to produce a plot, and wrap it in the html and JavaScript
necessary to render the website. 

Examples:
[Operator retention model](https://metrotransitmn.shinyapps.io/operator-retention/)

[Gas usage model](https://metrotransitmn.shinyapps.io/gasUsage/)

### Coding a shiny app

A shiny app has two separate components:

##### **ui**
The user interface component, describing the layout of the html
page the app will display, including:
	- panels, columns, and rows
	- places where user will interact (select, checkbox)
	- how the data, plots, or text should be *rendered*
	
##### **server**
The "back-end" component, encoding how the data will be handled, 
and how plots or data tables are built. 

The server component is made up of functions, which take some
`input` values from the interactive part, and return some `output`
values. 

### A shiny example walk-through
Let's say we want to be able to visualize the histograms for a 
dataset with multiple numeric columns (we'll use the lakes
dataset we have made up for previous examples). Further, let's say we 
wanted to double check the values by treatment, to be sure the
treatments weren't causing undo outliers (we are not in the 
analysis phase, yet, remember). 

We could simply create a bunch of pdf plots, or a markdown
 document with each of the numeric variables on a histogram. 
 But better would be, an interactive plot which let the data
 manager choose which variable to look at in a given moment. 
 And, to choose whether to plot all the data, or to graph each
 treatment separately on the same scale.
 
Let's start by creating the plot we wish to see in the world:
```
p <- ggplot(dat, aes(x = chlA))
p + geom_density(aes(fill = trt), alpha = 0.4)
```

This is the plot we want to make more interactive. Instead of
specifying each `aes(x = )` argument over all of the possible
columns, we want to build an app that will let us pick the 
column we are interested in, but build the rest of the plot
exactly the same way.

One thing we will need is a list of columns to choose from. 
In our dataset there are only two that are numeric, but thinking
ahead to a much larger dataset, we want to make this generic. 
One simple thing is to just take the columns that are defined
as numeric, and put those column names in a vector:

```
xvars <- names(dat)[sapply(dat, is.numeric)]

```

##### server
We know that the server will have to construct the plot. It
is a function, which takes in `input` values and returns `output`, 
which in this case is our plot:

```
server = function(input, output) {
  output$main_plot <- renderPlot({
      ggplot(dat, aes_string(x = input$varchoice)) + 
      geom_density()
   })
}
```
Things to note:

* server is a function with input and output arguments
* the plot to be displayed is assigned as a named object in the
	output 
* the ggplot code refers to an input object in the `aes_string` argument.
* ... `aes_string`?! this is a super-useful version of the `aes`
function which takes a character value and uses it to find the 
corresponding column in the specified dataset. That means we can 
pass column names back and forth between ui and server, rather
than subsetting data and passing that back and forth.

`renderPlot()` is a *reactive* function, which means it will 
adjust and re-create itself based on the value of the input.


##### ui
The user interface is where the selection of the inputs is 
made, and where the output is displayed. Things are passed
back and forth from the ui to the server and vice-versa
using the object names we saw referred to in the server.

- `output$main_plot`: the plot we wish to render
- `input$varchoice`: the variable we wish to see plotted

In the ui these are referred to as quote-named ID values. We
have to define one input, and one output, as well as how the
overall page will look.

```
ui = shinyUI(
    fluidPage(h4(strong("data exploration plots")),
              p("Plotting density of observed variables, all obs or by trt"),
              fluidRow( ...
```

Here we see the first things that look a little non-R-like. There
are functions in R which are mimicking functions in html: `strong()`
is like "boldface", `p()` means a paragraph of text. 

The `fluidPage` and `fluidRow` are shortcuts to creating nicely
laid out blocks in the html, which will work in almost any browser
and on any computer or mobile device.

It takes some getting used to, but when working in the ui, try 
to think as if you were building a static page with sections, 
rather than thinking too much about the interactivity.

```
ui = shinyUI(
    fluidPage(h4(strong("data exploration plots")),
              p("Plotting density of observed variables, all obs or by trt"),
              fluidRow(
                column(3, 
                       selectizeInput(inputId = "varchoice", 
                                      label = "Choose variable:", 
                                      choices = xvars,
                                      selected = xvars[1])),
   
```
Here we have added our drop-down box. `selectizeInput` creates
the selector. 

* The *inputId* should look familiar as the thing
we want to graph, in the server. 
* The *label* is just that, what 
will appear on the screen above or next to the dropdown. 
* The *choices* for the dropdown are what we defined earlier, and the
default selection (*selected*) will simply be the first column in the `xvars`
vector.

***

So the input has been constructed, what about the output? In
this case we just have to create a space on the page in which 
we want the plot to be displayed - same row, a wider column - 
and then refer back to the `outputId` we gave it in our server
definition:

```
ui = shinyUI(
    fluidPage(h4(strong("data exploration plots")),
              p("Plotting density of observed variables, all obs or by trt"),
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
```

To put it all together, we wrap both the server and ui definitions
into a `shinyApp()` function:

```
shinyApp(
  server = function(input, output) {
    output$main_plot <- renderPlot({
        ggplot(dat, aes_string(x = input$varchoice)) + 
        geom_density()
    })
  },
  
  ui = shinyUI(
    fluidPage(h4(strong("data exploration plots")),
              p("Plotting density of observed variables, all obs or by trt"),
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
) # end App
```

To add the checkbox for plotting by treatment, we can start
by adding another input section, this time beginning with the 
ui side (so we know where it will be shown on the page):
```
...
column(3, 
                     selectizeInput(inputId = "varchoice", 
                                    label = "Choose variable:", 
                                    choices = xvars,
                                    selected = xvars[1]),
                    checkboxInput(inputId = 'plotbytrt',
                                  label = strong('Plot by treatment'),
                                  value = FALSE)),                                 
...
```
With `input$plotbytrt` defined, we need to use it on the server
side. Because it is a logical (checkboxes are either TRUE or FALSE)
a straightforward `if() else ` will do:

```
 ...
    if(input$plotbytrt) {
      ggplot(dat, aes_string(x = input$varchoice)) + 
    	geom_density(aes(fill = trt), alpha = 0.4)
    } else {
      ggplot(dat, aes_string(x = input$varchoice)) + 
      	geom_density()
    }
 ...
```

Wrapping those two pieces together with what we had before:

```
shinyApp(
server = function(input, output) {
  output$main_plot <- renderPlot({
    if(input$plotbytrt) {
      ggplot(dat, aes_string(x = input$varchoice)) +
       	geom_density(aes(fill = trt), alpha = 0.4)
    } else {
      ggplot(dat, aes_string(x = input$varchoice)) +
       	geom_density()
    }
   })
},

ui = shinyUI(
  fluidPage(h4(strong("data exploration plots")),
            p("Plotting density of observed variables, all obs or by trt"),
            fluidRow(
              column(3, 
                     selectizeInput(inputId = "varchoice", 
                                    label = "Choose variable:", 
                                    choices = xvars,
                                    selected = xvars[1]),
                    checkboxInput(inputId = 'plotbytrt',
                                  label = strong('Plot by treatment'),
                                  value = FALSE)),
              column(8,
                     plotOutput(outputId = 'main_plot')
                     )# end column
              ) # end FluidRow, 
  ) # end page
  
) # end UI
)
```
