#' Fyll i text i en textruta
#'
#' Sätter värdet i ett `input`-fält eller en `textarea` i en enda
#' JavaScript-körning, utan seleniders automatiska väntan. Efteråt skickas
#' `input`- och `change`-händelser, precis som när en användare skriver, så
#' att sidans egen kod (t.ex. validering) märker att fältet ändrats.
#'
#' Räcker inte det, t.ex. för ett sökfält som söker för varje tangent som
#' trycks ned, använd i stället
#' `hitta(skrap, css) |> selenider::elem_send_keys(text)`.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param css CSS-selektor för textrutan. Obligatorisk.
#' @param text Texten som ska skrivas in. Obligatorisk.
#' @param rensa `TRUE` (standard) ersätter det som står i fältet. `FALSE`
#'   lägger till `text` sist.
#' @param iframe CSS-selektor för en iframe som textrutan ligger i. `NULL`
#'   (standard) söker på huvudsidan.
#'
#' @return Osynligt `TRUE`. Ger ett fel om inget fält matchar `css`.
#' @export
#' @example inst/examples/textruta_inmatning.R
textruta_inmatning <- function(skrap, css, text, rensa = TRUE, iframe = NULL) {
  if (!inherits(skrap, "skrapsession")) {
    stop("Objektet \u00e4r inte skapat av starta_skrapsession().")
  }
  rlang::check_installed("jsonlite")

  js <- sprintf(
    "(function(){
       %s
       var el = dok.querySelector(%s);
       if (!el) return 'ELEMENT_SAKNAS';
       el.value = %s ? %s : (el.value || '') + %s;
       el.dispatchEvent(new Event('input', {bubbles: true}));
       el.dispatchEvent(new Event('change', {bubbles: true}));
       return 'OK';
     })()",
    bygg_dokument_js(iframe),
    jsonlite::toJSON(css, auto_unbox = TRUE),
    if (isTRUE(rensa)) "true" else "false",
    jsonlite::toJSON(as.character(text), auto_unbox = TRUE),
    jsonlite::toJSON(as.character(text), auto_unbox = TRUE)
  )

  resultat <- kor_js(skrap, js)
  kontrollera_iframe_svar(resultat)
  if (identical(resultat, "ELEMENT_SAKNAS")) {
    stop("Hittade ingen textruta som matchar: ", css)
  }
  invisible(TRUE)
}
