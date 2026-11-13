# Interna hjälpfunktioner för xpath-sökningar.

# Begär sidans dokument från webbläsaren. selenider söker med xpath via
# JavaScript och hoppar över DOM.getDocument, som CSS-sökningarna gör. Är
# xpath-sökningen den första efter att en sida öppnats känner chromote då
# inte till sidans noder, och senare anrop ger felet "Could not find node
# with given id" eller fel svar från t.ex. is_visible().
#' @noRd
begar_dokument <- function(skrap) {
  try(skrap$session$driver$DOM$getDocument(), silent = TRUE)
  invisible(NULL)
}

# Gör om en text till en xpath-strängliteral. xpath har inget sätt att
# skriva ett citattecken inuti en sträng, så en text med både ' och " byggs
# ihop med concat().
#' @noRd
xpath_strang <- function(text) {
  if (!grepl("'", text, fixed = TRUE)) {
    return(paste0("'", text, "'"))
  }
  if (!grepl("\"", text, fixed = TRUE)) {
    return(paste0("\"", text, "\""))
  }
  delar <- strsplit(text, "'", fixed = TRUE)[[1]]
  if (endsWith(text, "'")) delar <- c(delar, "")
  paste0("concat(", paste0("'", delar, "'", collapse = ", \"'\", "), ")")
}
