library('hamcrest')
library('se.alipsa:mdr')


str.beginsWith <- function(expected) {
  if(is.na(expected)) {
    stop("expected is NA, str.beginsWith NA makes no sense")
  }
  function(actual) {
    startsWith(as.character(actual), as.character(expected))
  }
}

str.endsWith <- function(expected) {
  if(is.na(expected)) {
    stop("expected is NA, str.endsWith NA makes no sense")
  }
  function(actual) {
    endsWith(as.character(actual), as.character(expected))
  }
}

test.simpleOneLine <- function() {
  html <- renderMdr("This is *Sparta*")
  assertThat(html, equalTo("<p>This is <em>Sparta</em></p>\n"))
}

test.simpleTwoLines <- function() {
  html <- renderMdr(list("# The title", "- The first bullet"))
  assertThat(html, equalTo("<h1>The title</h1>\n<ul>\n<li>The first bullet</li>\n</ul>\n"))
}

test.inline.simple <- function() {
  rmd <- "2 + 5 = `r 2 + 5`."
  html <- renderMdr(rmd)
  assertThat(html, equalTo("<p>2 + 5 = 7.</p>\n"))
}

test.inline.complex <- function() {

  rmd <- "5 = `r 5 * 1`"
  html <- renderMdr(rmd)
  assertThat(html, equalTo("<p>5 = 5</p>\n"))

  rmd <- "2 + 5 = `r 2 + 5`, whereas 2 * 5 = `r 2 * 5`."
  html <- renderMdr(rmd)
  assertThat(html, equalTo("<p>2 + 5 = 7, whereas 2 * 5 = 10.</p>\n"))

  rmd <- "x = 22 + 500 = `r x <- 22 + 500 `, and 2 * x = `r 2 * x `, while x/2 = `r x/2`"
  html <- renderMdr(rmd)
  assertThat(html, equalTo("<p>x = 22 + 500 = 522, and 2 * x = 1044, while x/2 = 261</p>\n"))

}

test.latex <- function() {
  rmd <- "$$f(k) = {n \\choose k} p^{k} (1-p)^{n-k}$$"
  html <- renderMdr(rmd)
  print(html)
  print("TODO: detect LaTeX and convert to html or svg")
}

test.codeBlock <- function() {
  rmd <- "
# Summary
```{r}
md.new(summary(mtcars$qsec))
md.content()
```
How about that?
  "
  html <- renderMdr(rmd)
  cat(html, file=paste0(getwd(),"/codeBlock.html"))
  assertThat(html, equalTo(
'<h1>Summary</h1>
<table class="table">
<thead>
<tr><th>Var1</th><th>Freq</th></tr>
</thead>
<tbody>
<tr><td>Min.</td><td>14.5</td></tr>
<tr><td>1st Qu.</td><td>16.892</td></tr>
<tr><td>Median</td><td>17.71</td></tr>
<tr><td>Mean</td><td>17.849</td></tr>
<tr><td>3rd Qu.</td><td>18.9</td></tr>
<tr><td>Max.</td><td>22.9</td></tr>
</tbody>\n</table>
<p>How about that?</p>
'))
}

test.codeBlockInitialize <- function() {
  rmd <- '# Summary
```{r}
md.add("# Hello")
```
Some text
```{r}
md.add("## Hello again")
```
'
  html <- renderMdr(rmd)
  cat(html, file=paste0(getwd(),"/codeBlockInitialize.html"))
  assertThat(html, equalTo("<h1>Summary</h1>
<h1>Hello</h1>
<p>Some text</p>
<h2>Hello again</h2>
"))
}

test.codeBlockNoInitialize <- function() {
  rmd <- '# Summary
```{r}
md.add("# Hello")
```
Some text
```{r initialize=FALSE}
md.add("## Hello again")
```
'
  html <- renderMdr(rmd)
  cat(html, file=paste0(getwd(),"/codeBlockInitialize.html"))
  assertThat(html, equalTo("<h1>Summary</h1>
<h1>Hello</h1>
<p>Some text</p>
<h1>Hello</h1>
<h2>Hello again</h2>
"))
}

test.inline.mixed <- function() {
  rmd <- "
```{r}
  x = 3  # radius of a circle
```

  For a circle with the radius `r x`,
  its area is `r pi * x^2`.
"
  html <- renderMdr(rmd)
  assertThat(html, equalTo("<p>3</p>\n<p>For a circle with the radius 3,<br />\nits area is 28.27433388230814.</p>\n"))
}

test.barplot <- function() {
  mdr <- "
  # Barplot
  ```{r}
  md.add(
    barplot,
    table(mtcars$gear),
    main='Car Distribution',
    horiz=TRUE,
    names.arg=c('3 Gears', '4 Gears', '5 Gears'),
    col=c('darkblue','red', 'green')
  )
  ```
  "
  html <- renderMdr(mdr)
  #print(html)
  assertThat(html, str.beginsWith("<h1>Barplot</h1>\n<p><img src=\"data:image/png;base64,"))
  assertThat(html, str.endsWith("/></p>\n"))

  mdr <- "
  # Plot
  ```{r}
  md.addPlot({
    plot(mtcars$mpg ~ mtcars$hp)
    abline(h = mean(mtcars$mpg))
  })
  ```"
  html <- renderMdr(mdr)
  assertThat(html, str.beginsWith("<h1>Plot</h1>\n<p><img src=\"data:image/png;base64,"))
  assertThat(html, str.endsWith("/></p>\n"))
}

test.longerfile <- function() {
  mdrFile <- paste0(getwd(), "/research.mdr")
  stopifnot(file.exists(mdrFile))

  html <- renderMdr(file = mdrFile)
  #print(html)
  # TODO: some assertions would be nice
}

test.echo <- function() {
  rmd <- "
# Summary
```{r echo=TRUE}
md.new(summary(mtcars$qsec))

# Return the markdown
md.content()
```
  "
  html <- renderMdr(rmd)
  cat(html, file=paste0(getwd(),"/test.echo.html"))
  assertThat(html, equalTo(
    '<h1>Summary</h1>
<pre><code class=\"language-r\">md.new(summary(mtcars$qsec))

# Return the markdown
md.content()
</code></pre>
<table class="table">
<thead>
<tr><th>Var1</th><th>Freq</th></tr>
</thead>
<tbody>
<tr><td>Min.</td><td>14.5</td></tr>
<tr><td>1st Qu.</td><td>16.892</td></tr>
<tr><td>Median</td><td>17.71</td></tr>
<tr><td>Mean</td><td>17.849</td></tr>
<tr><td>3rd Qu.</td><td>18.9</td></tr>
<tr><td>Max.</td><td>22.9</td></tr>
</tbody>
</table>
'))
}

test.eval <- function() {
  rmd <- "
# Summary
```{r eval=FALSE}
md.add(summary(mtcars$qsec))

# Return the markdown
md.content()
```
  "
  html <- renderMdr(rmd)
  assertThat(html, equalTo("<h1>Summary</h1>\n"))
}

test.include <- function() {
  rmd <- "
# Summary
```{r include=FALSE}
md.add(summary(mtcars$qsec))
qsecMean <- mean(mtcars$qsec)
# Return the markdown
md.content()
```
Not included but evaluated, mean(mtcars$qsec) = `r qsecMean`
  "
  html <- renderMdr(rmd)
  assertThat(html, equalTo("<h1>Summary</h1>\n<p>Not included but evaluated, mean(mtcars$qsec) = 17.84875</p>\n"))
}

test.withquoteblock <- function() {
  rmd <- "
# Summary
```{r include=FALSE}
md.add(summary(mtcars$qsec))
qsecMean <- mean(mtcars$qsec)
# Return the markdown
md.content()
```
```r
# Here is the key code:
qsecMean <- mean(mtcars$qsec)
```
Not included but evaluated, mean(mtcars$qsec) = `r qsecMean`
  "
  html <- renderMdr(rmd)
  cat(html, file=paste0(getwd(),"/test.withquoteblock.html"))
  assertThat(html, equalTo("<h1>Summary</h1>\n<pre><code class=\"language-r\"># Here is the key code:\nqsecMean &lt;- mean(mtcars$qsec)\n</code></pre>\n<p>Not included but evaluated, mean(mtcars$qsec) = 17.84875</p>\n"))
}

