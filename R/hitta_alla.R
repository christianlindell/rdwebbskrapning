#' Hitta alla matchande element i en skrapsession
#'
#' Som [hitta()], men returnerar alla element som matchar. Motsvarar
#' `selenider::find_elements()` och seleniders `ss()`.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param ... Skickas vidare till `selenider::find_elements()`, t.ex. en
#'   CSS-selektor eller `xpath =`.
#'
#' @return En samling selenider-element.
#' @export
#' @example inst/examples/hitta_alla.R
hitta_alla <- function(skrap, ...) {
  if (!inherits(skrap, "skrapsession")) {
    stop("Objektet \u00e4r inte skapat av starta_skrapsession().")
  }
  begar_dokument(skrap)
  selenider::find_elements(skrap$session, ...)
}
