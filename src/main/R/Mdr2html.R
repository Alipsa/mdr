library("se.alipsa:htmlcreator")
library("se.alipsa:r2md")

codeblockArgs <- function(...) {
  args <- list(...)
  args
}

toBoolean <- function(arg, defaultVal = FALSE) {
  if (is.null(arg)) defaultVal else arg
}

parseMdr <- function(text=NULL, file=NULL) {
  if (!is.null(text)) {
    if (is.list(text)) {
      parseLines(text)
    } else {
      parseLines(list(text))
    }
  } else if (!is.null(file)) {
    if (file.exists(file)) {
      parseLines(readLines(file))
    } else {
      stop("File does not exist!")
    }
  } else {
    stop(paste("Unknown argument: should be either text (a string) or file"))
  }
}
#' @param lines is a list of character vectors
#' @returns the equivalent html of the mdr content
parseLines <- function(lines) {
  rCodeBlock <- FALSE
  rCode <- ""
  md <- Markdown$new()
  for(lineNum in 1:length(lines)) {
    element <- lines[[lineNum]]
    lineList <- strsplit(element, "(\r\n|\r|\n)")[[1]]
    if (length(lineList) == 0) {
      next
    }
    for (lineIdx in 1:length(lineList)) {
      line <- lineList[[lineIdx]]

      if(grepl("```{r", line, fixed = TRUE)) {
        rCodeBlock <- TRUE
        rCodeBlockLine <- line
        opt <- ""
        if (grepl("=", rCodeBlockLine, fixed = TRUE)) {
          optionsStart <- gregexpr('r ', rCodeBlockLine)[[1]] +1
          optionEnd <- gregexpr('}', rCodeBlockLine)[[1]] -1

          opt <- substr(rCodeBlockLine, optionsStart, optionEnd)
        }
        codeBlockOptions <- eval(parse(text = paste("codeblockArgs(", opt, ")")))
      }

      if (rCodeBlock) {
        passedCodeBlockStart <- !grepl("```{r", line, fixed = TRUE)
        if (passedCodeBlockStart && grepl("```", line, fixed = TRUE)) {
          rCodeBlock <- FALSE
          if (toBoolean(codeBlockOptions$echo)) {
            if (endsWith(rCode, "\n")) {
              endLine <- "```"
            } else {
              endLine <- "\n```"
            }
            md$add(paste0("```r", rCode, endLine))
          }
          if (toBoolean(codeBlockOptions$eval, TRUE)) {
            result <- as.character(eval(parse(text=rCode)))
            if (toBoolean(codeBlockOptions$include, TRUE)) {
              md$add(result)
            }
          }
          rCode <- ""
        } else if (passedCodeBlockStart){
          rCode <- paste(rCode, line, sep="\n")
        }
      } else {
        # `r is inclinde code whereas ```r is just a block that should render with syntax highlighting (i.e. processed as normal markdown)
        if (grepl("`r", line, fixed = TRUE) && !grepl("```r", line, fixed = TRUE) ) {
          rSectionStartMatches <- gregexpr('`r ', line)[[1]]
          knitLine <- ""
          startPos <- 1
          numChar <- nchar(line)
          for (idx in 1:length(rSectionStartMatches)) {
            mdSection <- substr(line, startPos, rSectionStartMatches[[idx]] - 1)
            rest <- substr(line, rSectionStartMatches[[idx]] + 3, numChar)
            endPos <- regexpr('`', rest)
            code <- substr(rest, 1, endPos - 1)
            result <- eval(parse(text=code))
            knitLine <- paste0(knitLine, mdSection, result)
            startPos <- rSectionStartMatches[[idx]] + endPos + 3
          }
          if (startPos <= numChar) {
            knitLine <- paste0(knitLine, substr(line, startPos, numChar))
          }
          md$add(knitLine)
        } else if (grepl("$$", line, fixed = TRUE)) {
          # LaTex
          # TODO: seems that Snuggletex is an option: https://www2.ph.ed.ac.uk/snuggletex/documentation/overview-and-features.html
          #   https://mvnrepository.com/artifact/uk.ac.ed.ph.snuggletex/snuggletex-core/1.2.2
          warning("LaTeX expressions are not yet supported")
          md$add(line)
        } else {
          md$add(line)
        }
      }
    }
  }
  md
}

renderMdr <- function(text=NULL, file=NULL, outputType="html") {
  md <- parseMdr(text, file)
  if (outputType == "html") {
    return(md.renderHtml(md$getContent()))
  } else if (outputType == "markdown") {
    return(md$getContent())
  } else {
    stop(paste("Unknown output type: ", outputType))
  }
}