package se.alipsa.rmd2html;

import org.commonmark.node.*;
import org.commonmark.parser.Parser;
import org.commonmark.renderer.html.HtmlRenderer;
import org.renjin.sexp.StringArrayVector;

public class Md2Html {

  Parser parser;
  HtmlRenderer renderer;

  public Md2Html() {
    parser = Parser.builder().build();
    renderer = HtmlRenderer.builder()
        .softbreak(" ")
        .build();
  }

  public String render(Object content) {
    System.out.println(content.getClass());
    if (content instanceof StringArrayVector) {
      render(((StringArrayVector) content).asString());
    }
    return render(String.valueOf(content));
  }

  public String render(String mdContent) {
    //System.out.println("Rendering " + mdContent);
    Node document = parser.parse(mdContent);
    return renderer.render(document);
  }

}
