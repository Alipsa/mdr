library("se.alipsa:htmlcreator")

# remember to add export(function name) to NAMESPACE to make them available

# lines is a list of character vectors
parseLines <- function(lines) {
  rCodeBlock <- FALSE
  rCode <- ""
  md2Html <- Md2Html$new()
  html.clear()
  print(paste("Processing", length(lines), "lines..."))
  for(lineNum in 1:length(lines)) {
    element <- lines[[lineNum]]
    #print(paste("element =", class(element), " is list =", is.list(element)))
    lineList <- strsplit(element, "(\r\n|\r|\n)")[[1]]
    print(paste0("  ", lineNum, ". line split into ", length(lineList), " elements"))
    for (lineIdx in 1:length(lineList)) {
      line <- lineList[[lineIdx]]
      print(paste0(" Parsing '", line, "'"))

      if(grepl("```{r", line, fixed = TRUE)) {
        print("  Code block beginning")
        rCodeBlock <- TRUE
      }

      if (rCodeBlock) {
        passedCodeBlockStart <- !grepl("```{r", line, fixed = TRUE)
        if (passedCodeBlockStart && grepl("```", line, fixed = TRUE)) {
          print("  Code block ending")
          rCodeBlock <- FALSE
          print(paste("executing code:", rCode))
          result <- eval(parse(text=rCode))
          print(paste("result is ", result))
          html.add(paste(result, collapse = '\n'))
          rCode <- ""
        } else if (passedCodeBlockStart){
          rCode <- paste(rCode, line, sep="\n")
        }
      } else {
        if (grepl("`r", line, fixed = TRUE)) {
          #print("  inline code detected")
          rSectionStartMatches <- gregexpr('`r', line)[[1]]
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
            #print(paste("    Result is", result))
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
        } else {
          print("  Render plain markdown text")
          html.add(md2Html$render(line))
        }
      }
    }
  }
  html.content()
}