#' Välj ett alternativ i en select-lista
#'
#' Sätter listans värde via JavaScript och skickar sedan `change`- och
#' `input`-händelser, precis som när en användare väljer. Använd när sidan
#' (t.ex. formulär byggda med Vue eller Vuetify) inte reagerar på att bara
#' värdet sätts, eller när `selenider::elem_select()` kraschar med
#' `SyntaxError` på grund av hur selektorn ser ut.
#'
#' Ska sidans egen onchange-kod inte köras, använd i stället
#' [valj_option_utan_event()]. Den klarar också flervalslistor.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param css CSS-selektor för `<select>`-elementet, t.ex. `"select#AR"` eller
#'   `"select[name='categories']"`. Obligatorisk.
#' @param value `value` för det alternativ som ska väljas, som text. Använd
#'   [hamta_select_varden()] för att se vilka värden som finns. Obligatorisk.
#' @param iframe CSS-selektor för en iframe som listan ligger i. `NULL`
#'   (standard) söker på huvudsidan.
#'
#' @return Osynligt `TRUE`. Ger ett fel om ingen lista matchar `css`.
#' @export
#' @example inst/examples/valj_i_lista.R
valj_i_lista <- function(skrap, css, value, iframe = NULL) {
  if (!inherits(skrap, "skrapsession")) {
    stop("Objektet \u00e4r inte skapat av starta_skrapsession().")
  }
  rlang::check_installed("jsonlite")

  js <- sprintf(
    "(function(){
       %s
       var sel = dok.querySelector(%s);
       if (!sel) return false;
       sel.value = %s;
       sel.dispatchEvent(new Event('change', { bubbles: true }));
       sel.dispatchEvent(new Event('input', { bubbles: true }));
       return true;
     })()",
    bygg_dokument_js(iframe),
    jsonlite::toJSON(css, auto_unbox = TRUE),
    jsonlite::toJSON(value, auto_unbox = TRUE)
  )

  hittad <- kor_js(skrap, js)
  kontrollera_iframe_svar(hittad)
  if (!isTRUE(hittad)) {
    stop("Hittade ingen select-lista som matchar: ", css)
  }
  invisible(TRUE)
}
