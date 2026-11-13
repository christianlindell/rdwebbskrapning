#' Klicka på ett element via CSS-selektor
#'
#' Som [klicka_via_text()], men pekar ut elementet med en CSS-selektor, t.ex.
#' ett id (`"#visa"`), i stället för med synlig text. Klicket görs i en enda
#' JavaScript-körning utan seleniders automatiska väntan. Använd för att
#' snabba upp klick på element du vet finns och syns, eller för att ta reda på
#' om ett långsamt `selenider::elem_click()` beror på seleniders väntan eller
#' på att sidan är långsam.
#'
#' Med `vanta = TRUE` väntar funktionen in en sidladdning som klicket startar:
#' en markör läggs på sidan i samma ögonblick som klicket, och försvinner den
#' har en ny sida börjat laddas. Börjar ingen sidladdning inom `grace`
#' sekunder går funktionen vidare.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param css CSS-selektor för elementet som ska klickas, t.ex. `"#visa"`.
#'   Obligatorisk.
#' @param vanta `TRUE` (standard) väntar in en sidladdning om klicket startar
#'   en. Använd `FALSE` när klicket startar en nedladdning.
#' @param grace Antal sekunder en sidladdning får på sig att börja efter
#'   klicket. Det är vad klicket kostar när ingen sidladdning sker. Standard
#'   är 0,3.
#' @param timeout Högsta antal sekunder att vänta på att en sidladdning blir
#'   klar. Standard är 30.
#' @param iframe CSS-selektor för en iframe som elementet ligger i. `NULL`
#'   (standard) söker på huvudsidan.
#'
#' @return Osynligt `TRUE`. Ger ett fel om inget element matchar.
#' @export
#' @example inst/examples/klicka_via_id.R
klicka_via_id <- function(skrap, css, vanta = TRUE, grace = 0.3, timeout = 30,
                          iframe = NULL) {
  if (!inherits(skrap, "skrapsession")) {
    stop("Objektet \u00e4r inte skapat av starta_skrapsession().")
  }
  rlang::check_installed("jsonlite")

  # Markören satts i SAMMA JavaScript-körning som klicket - satts den i ett
  # separat anrop finns en kapplöpning dar navigeringen hinner börja emellan.
  js <- sprintf(
    "(function(){
       %s
       var el = dok.querySelector(%s);
       if (!el) return false;
       window.__skrapKlickMarkering = true;
       el.click();
       return true;
     })()",
    bygg_dokument_js(iframe),
    jsonlite::toJSON(css, auto_unbox = TRUE)
  )

  hittad <- kor_js(skrap, js)
  kontrollera_iframe_svar(hittad)
  if (!isTRUE(hittad)) {
    stop("Hittade inget element som matchar: ", css)
  }

  if (isTRUE(vanta)) {
    vanta_pa_sidladdning(skrap, grace = grace, timeout = timeout)
  }
  invisible(TRUE)
}
