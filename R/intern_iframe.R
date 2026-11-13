# --- interna hjälpare för iframe-stöd -------------------------------------

# Bygger JavaScript som satter variabeln `dok` till ratt document:
# huvudsidans document om iframe ar NULL, annars dokumentet inuti angiven
# iframe (eller nastlade iframes om en vektor av selektorer anges).
# Fungerar for same-origin-iframes; cross-origin blockeras av weblasarens
# sakerhetsmodell och ger ett tydligt fel via kontrollera_iframe_svar().
#' @noRd
bygg_dokument_js <- function(iframe = NULL) {
  if (is.null(iframe)) {
    return("var dok = document;")
  }
  rlang::check_installed("jsonlite")
  sprintf(
    "var dok = document;
     var framar = %s;
     for (var fi = 0; fi < framar.length; fi++) {
       var fr = dok.querySelector(framar[fi]);
       if (!fr) return 'IFRAME_SAKNAS:' + framar[fi];
       try { dok = fr.contentDocument || fr.contentWindow.document; }
       catch (e) { return 'IFRAME_KORSDOMAN:' + framar[fi]; }
       if (!dok) return 'IFRAME_KORSDOMAN:' + framar[fi];
     }",
    jsonlite::toJSON(as.character(iframe))
  )
}

# Kastar begripliga fel om JavaScript-svaret signalerar iframe-problem.
#' @noRd
kontrollera_iframe_svar <- function(resultat) {
  if (is.character(resultat) && length(resultat) == 1) {
    if (startsWith(resultat, "IFRAME_SAKNAS:")) {
      stop("Hittade ingen iframe som matchar: ",
           sub("^IFRAME_SAKNAS:", "", resultat))
    }
    if (startsWith(resultat, "IFRAME_KORSDOMAN:")) {
      stop(
        "Iframen '", sub("^IFRAME_KORSDOMAN:", "", resultat),
        "' laddar inneh\u00e5ll fr\u00e5n en annan dom\u00e4n (cross-origin) - d\u00e5 blockerar ",
        "webbl\u00e4sarens s\u00e4kerhetsmodell \u00e5tkomst via JavaScript. Enklaste ",
        "l\u00f6sningen \u00e4r oftast att navigera direkt till iframens src-URL med ",
        "open_url() i st\u00e4llet."
      )
    }
  }
  invisible(NULL)
}
