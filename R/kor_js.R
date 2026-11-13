#' Kör JavaScript på sidan och returnera resultatet
#'
#' Utvärderar ett JavaScript-uttryck på den sida som är öppen i sessionen och
#' returnerar värdet. Bra för att felsöka och undersöka en sida, och för att
#' läsa ut sådant som paketet inte har någon egen funktion för.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param js JavaScript-uttryck som text. Uttryckets värde returneras.
#'   Obligatorisk.
#'
#' @return Uttryckets värde, omvandlat till R (text, tal, logiskt värde eller
#'   `NULL`). Objekt och listor returneras bäst som JSON-text med
#'   `JSON.stringify()`.
#' @export
#' @example inst/examples/kor_js.R
kor_js <- function(skrap, js) {
  skrap$session$driver$Runtime$evaluate(js)$result$value
}
