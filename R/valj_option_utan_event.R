#' Markera alternativ i en select-lista utan att sidan märker det
#'
#' Markerar ett eller flera alternativ direkt via JavaScript utan att skicka
#' någon `change`-händelse. Används när sidans egen onchange-kod är trasig
#' och kraschar, vilket kan hindra sidan från att registrera valet innan t.ex.
#' en ASP.NET-postback läser av det. Markeringen finns ändå i listan och
#' skickas med formuläret vid nästa knapptryck.
#'
#' Eftersom ingen händelse skickas körs inte heller sidans riktiga
#' onchange-kod (t.ex. en räknare som uppdateras). Använd
#' `selenider::elem_select()` eller [valj_i_lista()] i första hand, och den
#' här funktionen bara när onchange-koden ställer till problem.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param css CSS-selektor för `<select>`-elementet. Obligatorisk.
#' @param value Textvektor med `value` för de alternativ som ska markeras.
#'   Flera värden går bara i flervalslistor. Befintlig markering ersätts.
#'   Obligatorisk.
#' @param iframe CSS-selektor för en iframe som listan ligger i. `NULL`
#'   (standard) söker på huvudsidan.
#'
#' @return Osynligt `TRUE`. Ger ett fel om ingen lista matchar `css` eller om
#'   något av värdena saknas i listan.
#' @export
#' @example inst/examples/valj_option_utan_event.R
valj_option_utan_event <- function(skrap, css, value, iframe = NULL) {
  if (!inherits(skrap, "skrapsession")) {
    stop("Objektet \u00e4r inte skapat av starta_skrapsession().")
  }
  rlang::check_installed("jsonlite")

  js <- sprintf(
    "(function(){
       %s
       var sel = dok.querySelector(%s);
       if (!sel) return 'ELEMENT_SAKNAS';
       var varden = %s;
       var saknade = [];
       for (var i = 0; i < sel.options.length; i++) {
         sel.options[i].selected = varden.indexOf(sel.options[i].value) !== -1;
       }
       for (var j = 0; j < varden.length; j++) {
         var finns = [...sel.options].some(o => o.value === varden[j]);
         if (!finns) saknade.push(varden[j]);
       }
       return saknade.length ? 'SAKNAS:' + saknade.join(',') : 'OK';
     })()",
    bygg_dokument_js(iframe),
    jsonlite::toJSON(css, auto_unbox = TRUE),
    jsonlite::toJSON(as.character(value))
  )

  resultat <- kor_js(skrap, js)
  if (!is.character(resultat) || length(resultat) != 1) {
    stop("Fick inget svar fr\u00e5n sidan n\u00e4r ", css, " skulle markeras. ",
         "Sidan laddas kanske om. V\u00e4nta tills den laddats klart, t.ex. med ",
         "vanta_pa_js(), och f\u00f6rs\u00f6k igen.")
  }
  kontrollera_iframe_svar(resultat)
  if (identical(resultat, "ELEMENT_SAKNAS")) {
    stop("Hittade ingen select-lista som matchar: ", css)
  }
  if (startsWith(resultat, "SAKNAS:")) {
    stop("F\u00f6ljande value(s) finns inte i ", css, ": ",
         sub("^SAKNAS:", "", resultat))
  }
  invisible(TRUE)
}
