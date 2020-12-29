library('hamcrest')
library('se.alipsa:rmd2html')

test.simpleOneLine <- function() {
  html <- parseLines(lines = list("This is *Sparta*"))
  assertThat(html, equalTo("<p>This is <em>Sparta</em></p>\n"))
}

test.simpleTwoLines <- function() {
  html <- parseLines(lines = list("# The title", "- The first bullet"))
  assertThat(html, equalTo("<h1>The title</h1>\n<ul>\n<li>The first bullet</li>\n</ul>\n"))
}

test.inline.simple <- function() {
  rmd <- "2 + 5 = `r 2 + 5`."
  html <- parseLines(lines = list(rmd))
  assertThat(html, equalTo("<p>2 + 5 = 7.</p>\n"))
}

test.inline.complex <- function() {
  rmd <- "2 + 5 = `r 2 + 5`, whereas 2 * 5 = `r 2 * 5`."
  html <- parseLines(lines = list(rmd))
  assertThat(html, equalTo("<p>2 + 5 = 7, whereas 2 * 5 = 10.</p>\n"))
  rmd <- "x = 22 + 500 = `r x <- 22 + 500 `, and 2 * x = `r 2 * x `, while x/2 = `r x/2`."
  html <- parseLines(lines = list(rmd))
  assertThat(html, equalTo("<p>x = 22 + 500 = 522, and 2 * x = 1044, while x/2 = 261.</p>\n"))

}

test.latex <- function() {
  rmd <- "$$f(k) = {n \\choose k} p^{k} (1-p)^{n-k}$$"
  html <- parseLines(lines = list(rmd))
  print(html)
  print("TODO: detect LaTeX and convert to html or svg")
}

test.codeBlock <- function() {
  rmd <- "
# Summary
```{r}
summary(mtcars)
```
How about that?
  "
  html <- parseLines(lines = list(rmd))
  print(html)
}

test.inline.mixed <- function() {
  rmd <- "
```{r}
  x = 5  # radius of a circle
```

For a circle with the radius `r x`,
its area is `r pi * x^2`.
  "
}
