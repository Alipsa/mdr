# mdr
A [Renjin](https://github.com/bedatadriven/renjin) package (extension) to render mdr files as markdown, html, or pdf

The *mdr* file format is somewhat similar to *rmd* (r markdown) in the sense that it enables enhancing markdown with r code to support
[reproducible research](https://en.wikipedia.org/wiki/Reproducibility#Reproducible_research_method); but
where rmd relies on knitr and "magic rules" for what and especially how to render r code, mdr puts the responsibility
to generate markdown text from r code on you - and using the [r2md](https://github.com/perNyfelt/r2md) package
this becomes quite a pleasant experience giving you lots of control and power.

The mdr package is essentially a package (Renjin extension) that processes mdr text or files and produces html. 
This is used in the [Munin](https://github.com/perNyfelt/munin) reports server to support mdr files as one of its supported report formats.

Use the method `parseMdr()` to parse a mdr character vector (string), a mdr file, or a list of mdr lines into a r2md::Markdown object.
Typically, you will use the `renderMdr()` to parse and render the mdr content into html (or markdown by adding the outputType parameter, 
e.g. `renderMdr(mdrFile, outputType="markdown"`). Valid outputTypes are `html` (default), `markdown`, and `pdf`.

To use it, add the following dependency to your pom.xml
```xml
<dependency>
    <groupId>se.alipsa</groupId>
    <artifactId>mdr</artifactId>
    <version>1.5.0</version>
</dependency>
```

## Example
Given a mdr document with the following content:

````
# Summary
```{r}
md.add(summary(mtcars$qsec))
md.content()
```
How about that?
````
...the code: `html <- renderMdr(rmd)` will make the html variable contain the following html:
```html
<h1>Summary</h1>
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
    </tbody>
</table>
<p>How about that?</p>
```
(Note: indentation above added to clarity, the actual result does not indent the html code)

You can do whatever you like in the R code block but whatever is returned from the block (the last expression) is 
assumed to be the markdown to render into html. So if you do:
````
# Summary
```{r}
md.clear()
md.add(mtcars, attr=list(class="table")
md.content()
"How about that?"
```
````

...none of the markdown code for mtcars will be run, the Markdown content that *will* be added is `"How about that?"`.
However, the code is still executed and since the session for subsequent code blocks is the same, md.content() will
still contain the mtcars data.frame (unless you do md.clear() or md.new() in you next codeblock - then it will be truly lost).

So to summarise the key [r2md](https://github.com/perNyfelt/r2md) methods:
- md.new(): begin a new markdown text
- md.add(): append to the existing markdown text or start a new one if there was none before
- md.addPlot(): append a series of plot commands 
- md.clear(): removes the content of an existing markdown text or creates a new one if none existed before

## Configuration
The following code block options are supported:

- **echo**: Output the code before the result is outputted, defaults to FALSE 
- **eval**: Whether to run the code or not, defaults to TRUE
- **include**: Whether the results of the evaluation should be outputted or not, defaults to TRUE

Example:
````
# Summary
```{r echo=TRUE}
md.add(summary(mtcars$qsec))

# Return the markdown, technically md.add() and md.new() does that as well so we could have skipped the next line
md.content()
```
````
This results in
````html
<h1>Summary</h1>
<pre><code>
```{r echo=TRUE}
md.add(summary(mtcars$qsec))

# Return the markdown, technically md.add() and md.new() does that as well so we could have skipped the next line
md.content()
```
</code></pre>
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
</tbody>
</table>
````

For multiple option, just separate them with comma, e.g:

\`\`\`{r echo=TRUE, include=FALSE}

Note that if you set eval to FALSE, the 'include' parameter is ignored. 
Setting include to TRUE makes no sense and will just be ignored as it has no meaning.

[Here is an example](https://github.com/perNyfelt/mdr2html/blob/main/src/test/resources/research.mdr) of a mdr report.

See the [tests](https://github.com/perNyfelt/mdr2html/blob/main/src/test/R/Mdr2htmlTest.R) for more usage details.

# Version History

### Ver 1.5.0
- upgrade r2md to 1.0.2 to add support for `htest` classes
- rename package to mdr
- add support for pdf output

### Ver 1.4.0, Dec 8, 2021
- upgrade r2md to 1.0.1 to add the md.addPlot function for more versatile plotting.
- switch to 3 position version scheme so bumping version to the 1.4.x range

### Ver 1.3, Jan 31, 2021
- add highlightJs code formatting

### Ver 1.2, Jan 24, 2021
- Remove dependency on htmlcreator
- Add versions plugin with rules excluding beta versions
- Add maven enforcer plugin to require minimum maven version

### Ver 1.1, Jan 10, 2021
Remove direct rendering to html with html.add and change to render into markdown and then to html.
parseMdr now returns a r2md::Markdown object, use renderMdr to get either html (default) or markdown content.

### Ver 1.0, 2021-Jan-08
- Initial release