# mdr2html
Render mdr files as html

The *mdr* file format is somewhat
similar to *rmd* (r markdown) in the sense that it enables enhancing markdown with r code to support
[reproducible research](https://en.wikipedia.org/wiki/Reproducibility#Reproducible_research_method); but
where rmd relies on knitr and "magic rules" for what and how to render r code, mdr puts the responsibility
to generate markdown text from r code on you - and using the [r2md](https://github.com/perNyfelt/r2md) package
this becomes quite a pleasant experience giving you lots of control and power.

The mdr2html package is essentially a package (Renjin extension) that processes mdr text or files and produces html. 
This is used in the [Munin](https://github.com/perNyfelt/munin) reports server to support mdr files as one of its supported report formats.

## Example

````
# Summary
```{r}
md.add(summary(mtcars$qsec))
md.content()
```
How about that?
````

`html <- parseMdr(rmd)` will make the html variable contain the following html:
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
