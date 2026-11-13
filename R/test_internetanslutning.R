#' Testa internetanslutningen med en riktig HTTP-förfrågan
#'
#' Skickar en GET-förfrågan till `url` med httr, som följer systemets och
#' proxyns inställningar. [starta_skrapsession()] anropar funktionen först, så
#' att man får ett tydligt fel direkt om nätverket saknas.
#'
#' Funktionen använder medvetet inte `curl::has_internet()`. Den gör en
#' DNS-uppslagning mot en publik DNS-server (t.ex. 8.8.8.8), vilket ofta är
#' blockerat på företagsnät även när vanlig webbtrafik via proxy fungerar, och
#' ger då falska larm om att anslutning saknas.
#'
#' @param url Adress att testa mot, som text. Standard är
#'   `"https://raw.githubusercontent.com"`.
#' @param timeout_sek Högsta antal sekunder att vänta på svar. Standard är 5.
#'
#' @return `TRUE` om servern svarar med en statuskod under 500, annars `FALSE`.
#' @export
#' @example inst/examples/test_internetanslutning.R
test_internetanslutning <- function(url = "https://raw.githubusercontent.com", timeout_sek = 5) {
  tryCatch({
    svar <- httr::GET(url, httr::timeout(timeout_sek))
    httr::status_code(svar) < 500
  }, error = function(e) FALSE)
}
