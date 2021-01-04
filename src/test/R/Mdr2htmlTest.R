library('hamcrest')
library('se.alipsa:rmd2html')

test.simpleOneLine <- function() {
  html <- parseMdr("This is *Sparta*")
  assertThat(html, equalTo("<p>This is <em>Sparta</em></p>\n"))
}

test.simpleTwoLines <- function() {
  html <- parseMdr(list("# The title", "- The first bullet"))
  assertThat(html, equalTo("<h1>The title</h1>\n<ul>\n<li>The first bullet</li>\n</ul>\n"))
}

test.inline.simple <- function() {
  rmd <- "2 + 5 = `r 2 + 5`."
  html <- parseMdr(rmd)
  assertThat(html, equalTo("<p>2 + 5 = 7.</p>\n"))
}

test.inline.complex <- function() {

  rmd <- "5 = `r 5 * 1`"
  html <- parseMdr(rmd)
  assertThat(html, equalTo("<p>5 = 5</p>\n"))

  rmd <- "2 + 5 = `r 2 + 5`, whereas 2 * 5 = `r 2 * 5`."
  html <- parseMdr(rmd)
  assertThat(html, equalTo("<p>2 + 5 = 7, whereas 2 * 5 = 10.</p>\n"))

  rmd <- "x = 22 + 500 = `r x <- 22 + 500 `, and 2 * x = `r 2 * x `, while x/2 = `r x/2`"
  html <- parseMdr(rmd)
  assertThat(html, equalTo("<p>x = 22 + 500 = 522, and 2 * x = 1044, while x/2 = 261</p>\n"))

}

test.latex <- function() {
  rmd <- "$$f(k) = {n \\choose k} p^{k} (1-p)^{n-k}$$"
  html <- parseMdr(rmd)
  print(html)
  print("TODO: detect LaTeX and convert to html or svg")
}

test.codeBlock <- function() {
  rmd <- "
# Summary
```{r}
md.add(summary(mtcars$qsec))
md.content()
```
How about that?
  "
  html <- parseMdr(rmd)
  #cat(html, file=paste0(getwd(),"/codeBlock.html"))
  assertThat(html, equalTo(
"<h1>Summary</h1>
<table>
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
  html <- parseMdr(rmd)
  assertThat(html, equalTo("<p>3</p>\n<p>For a circle with the radius 3,</p>\n<p>its area is 28.27433388230814.</p>\n"))
}
