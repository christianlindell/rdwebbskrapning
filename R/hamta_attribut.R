#' Läs ett attribut från ett element
#'
#' Läser ett HTML-attribut (t.ex. `href`, `src` eller `data-*`) från det
#' första elementet som matchar en CSS-selektor. Används t.ex. för att få
#' adressen till en fil som en länk pekar på.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param css CSS-selektor för elementet. Obligatorisk.
#' @param attribut Attributets namn, t.ex. `"href"`. Obligatorisk.
#' @param iframe CSS-selektor för en iframe som elementet ligger i. `NULL`
#'   (standard) söker på huvudsidan.
#'
#' @return Attributets värde som text, eller `NA_character_` om elementet
#'   finns men saknar attributet. Ger ett fel om inget element matchar `css`.
#' @export
#' @example inst/examples/hamta_attribut.R
hamta_attribut <- function(skrap, css, attribut, iframe = NULL) {
  if (!inherits(skrap, "skrapsession")) {
    stop("Objektet \u00e4r inte skapat av starta_skrapsession().")
  }
  rlang::check_installed("jsonlite")

  js <- sprintf(
    "(function(){
       %s
       var el = dok.querySelector(%s);
       if (!el) return 'ELEMENT_SAKNAS';
       var v = el.getAttribute(%s);
       return v === null ? 'ATTRIBUT_SAKNAS' : v;
     })()",
    bygg_dokument_js(iframe),
    jsonlite::toJSON(css, auto_unbox = TRUE),
    jsonlite::toJSON(attribut, auto_unbox = TRUE)
  )

  resultat <- kor_js(skrap, js)
  kontrollera_iframe_svar(resultat)
  if (identical(resultat, "ELEMENT_SAKNAS")) {
    stop("Hittade inget element som matchar: ", css)
  }
  if (identical(resultat, "ATTRIBUT_SAKNAS")) {
    return(NA_character_)
  }
  resultat
}
