#' Läs ut alla alternativ i en select-lista
#'
#' Läser alla alternativs `value` och text ur en `<select>`-lista i en enda
#' JavaScript-körning. Det går mycket snabbare än att loopa över
#' `find_elements("option")` och `elem_attr()`, som gör ett anrop per
#' alternativ och blir långsamt för långa listor. Behöver du bara värdena,
#' använd [hamta_select_varden()].
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param css CSS-selektor för `<select>`-elementet, t.ex. `"#AR"`.
#'   Obligatorisk.
#' @param iframe CSS-selektor för en iframe som listan ligger i. `NULL`
#'   (standard) söker på huvudsidan.
#'
#' @return En data frame med kolumnerna `value` och `text`, en rad per
#'   alternativ.
#'
#'   Ger ett fel om ingen lista matchar `css`, eller om sidan inte svarar
#'   (vilket brukar betyda att den håller på att laddas om, t.ex. efter en
#'   postback; vänta då in ett element med `selenider::elem_expect()` först).
#' @export
#' @example inst/examples/hamta_select_options.R
hamta_select_options <- function(skrap, css, iframe = NULL) {
  if (!inherits(skrap, "skrapsession")) {
    stop("Objektet \u00e4r inte skapat av starta_skrapsession().")
  }
  rlang::check_installed("jsonlite")

  js <- sprintf(
    "(function(){
       %s
       var sel = dok.querySelector(%s);
       if (!sel) return 'ELEMENT_SAKNAS';
       return JSON.stringify([...sel.options].map(o => ({value: o.value, text: o.text.trim()})));
     })()",
    bygg_dokument_js(iframe),
    jsonlite::toJSON(css, auto_unbox = TRUE)
  )

  resultat <- kor_js(skrap, js)
  kontrollera_iframe_svar(resultat)

  if (is.null(resultat)) {
    stop(
      "Fick inget svar fr\u00e5n sidan vid avl\u00e4sning av ", css, ". ",
      "Detta h\u00e4nder typiskt om sidan h\u00e5ller p\u00e5 att laddas om (t.ex. efter ",
      "en postback) - v\u00e4nta in ett element med elem_expect(is_visible) ",
      "innan avl\u00e4sningen."
    )
  }
  if (identical(resultat, "ELEMENT_SAKNAS")) {
    stop("Hittade ingen select-lista som matchar: ", css)
  }

  jsonlite::fromJSON(resultat)
}
