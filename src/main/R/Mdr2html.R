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
  #print(paste("parseMdr, text =", text, ", file =", file))
  if (!is.null(text)) {
    if (is.list(text)) {
      parseLines(text)
    } else {
      parseLines(list(text))
    }
  } else if (!is.null(file)) {
    if (file.exists(file)) {
      #print(paste("parsing", file))
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
  md2Html <- Md2Html$new()
  html.clear()
  md.clear()
  #print(paste("Processing", length(lines), "lines..."))
  for(lineNum in 1:length(lines)) {
    #print(paste("Line number", lineNum))
    element <- lines[[lineNum]]
    #print(paste("element =", class(element), " is list =", is.list(element)))
    lineList <- strsplit(element, "(\r\n|\r|\n)")[[1]]
    #print(paste0("  ", lineNum, ". line split into ", length(lineList), " elements"))
    if (length(lineList) == 0) {
      next
    }
    for (lineIdx in 1:length(lineList)) {
      line <- lineList[[lineIdx]]
      #print(paste0("  ", lineIdx, ". Parsing '", line, "'"))

      if(grepl("```{r", line, fixed = TRUE)) {
        #print("  Code block beginning")
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
          #print("  Code block ending")
          rCodeBlock <- FALSE
          #print(paste("executing code:", rCode))
          if (toBoolean(codeBlockOptions$echo)) {
            if (!endsWith(rCodeBlockLine, "\n") && ! startsWith(rCode, "\n")) {
              startLine <- paste0(rCodeBlockLine, "\n")
            } else {
              startLine <- rCodeBlockLine
            }
            #print(paste("rCodeBlockLine =", rCodeBlockLine))
            #print(paste("startLine =", startLine))
            #print(paste("rCode =", rCode))
            if (endsWith(rCode, "\n")) {
              endLine <- "```</code></pre>"
            } else {
              endLine <- "\n```</code></pre>"
            }
            html.add(paste0("<pre><code>", startLine, rCode, endLine))
            #html.add(md.renderHtml(paste0(rCodeBlockLine, "\n", rCode, "```\n")))
            #html.add(md.renderHtml(paste0("```r\n", rCode, "```\n")))
          }
          if (toBoolean(codeBlockOptions$eval, TRUE)) {
            result <- as.character(eval(parse(text=rCode)))
            if (toBoolean(codeBlockOptions$include, TRUE)) {
              htm <- md.renderHtml(result)
              #print(paste("result is ", result))
              html.add(paste(htm, collapse = '\n'))
            }
          }
          rCode <- ""
        } else if (passedCodeBlockStart){
          rCode <- paste(rCode, line, sep="\n")
        }
      } else {
        if (grepl("`r", line, fixed = TRUE)) {
          #print("  inline code detected")
          rSectionStartMatches <- gregexpr('`r ', line)[[1]]
          knitLine <- ""
          startPos <- 1
          numChar <- nchar(line)
          for (idx in 1:length(rSectionStartMatches)) {
            mdSection <- substr(line, startPos, rSectionStartMatches[[idx]] - 1)
            #print(paste0("----md section is '", mdSection, "'"))
            rest <- substr(line, rSectionStartMatches[[idx]] + 3, numChar)
            #print(paste0("    rest is '", rest, "'"))
            endPos <- regexpr('`', rest)
            code <- substr(rest, 1, endPos - 1)
            #print(paste0("    Code is '", code, "'"))
            result <- eval(parse(text=code))
            # print(paste("    Result is", result))
            #print(paste0("    knitLine before concat is '", knitLine, "'"))
            knitLine <- paste0(knitLine, mdSection, result)
            #print(paste("    final knitLine =", knitLine))
            startPos <- rSectionStartMatches[[idx]] + endPos + 3
            #print(paste("    setting startPos to ", rSectionStartMatches[[idx]], "+", endPos, "=", startPos))
          }
          if (startPos <= numChar) {
            knitLine <- paste0(knitLine, substr(line, startPos, numChar))
          }
          html.add(md2Html$render(knitLine))
        } else if (grepl("$$", line, fixed = TRUE)) {
          # LaTex
          # TODO: seems that Snuggletex is an option: https://www2.ph.ed.ac.uk/snuggletex/documentation/overview-and-features.html
          #   https://mvnrepository.com/artifact/uk.ac.ed.ph.snuggletex/snuggletex-core/1.2.2
          warning("LaTeX expressions are not yet supported")
          html.add(md2Html$render(line))
        } else {
          #print("  Render plain markdown text")
          html.add(md2Html$render(line))
        }
      }
    }
  }
  html.content()
}