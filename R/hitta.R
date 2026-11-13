#' Hitta ett element i en skrapsession
#'
#' Tunt skal runt `selenider::find_element()` som tar sessionsobjektet direkt.
#' Motsvarar seleniders `s()`, som inte går att använda här eftersom den
#' saknar argument för session (paketets sessioner skapas med
#' `local = FALSE`). Elementet kan sedan skickas vidare till t.ex.
#' `selenider::elem_click()`, `selenider::elem_expect()` eller
#' `selenider::elem_text()`.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param ... Skickas vidare till `selenider::find_element()`, t.ex. en
#'   CSS-selektor eller `xpath =`.
#'
#' @return Ett selenider-element.
#' @seealso [hitta_alla()] för alla matchande element och [hitta_via_text()]
#'   för att hitta ett element via dess text.
#' @export
#' @example inst/examples/hitta.R
hitta <- function(skrap, ...) {
  if (!inherits(skrap, "skrapsession")) {
    stop("Objektet \u00e4r inte skapat av starta_skrapsession().")
  }
  begar_dokument(skrap)
  selenider::find_element(skrap$session, ...)
}
