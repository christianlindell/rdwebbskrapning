#' Läs ut värdena i en select-lista
#'
#' Kortform av [hamta_select_options()] för det vanliga fallet att man bara
#' behöver alternativens `value`, t.ex. för att välja alla utom vissa med
#' `setdiff(hamta_select_varden(skrap, "#AR"), "2014")`.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param css CSS-selektor för `<select>`-elementet. Obligatorisk.
#' @param iframe CSS-selektor för en iframe som listan ligger i. `NULL`
#'   (standard) söker på huvudsidan.
#'
#' @return En textvektor med alternativens `value`.
#' @export
#' @example inst/examples/hamta_select_varden.R
hamta_select_varden <- function(skrap, css, iframe = NULL) {
  hamta_select_options(skrap, css, iframe = iframe)$value
}
