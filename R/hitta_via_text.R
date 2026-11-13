#' Hitta ett element via dess synliga text
#'
#' Returnerar det innersta elementet vars hela text, med blanksteg
#' normaliserade, är exakt lika med `text`. Det fungerar även när texten och
#' andra element är blandade, t.ex. `<label><input>Text</label>`. Använd när
#' du vill gå vidare med elementet (`selenider::elem_expect()`,
#' `selenider::elem_text()` m.fl.). Ska elementet bara klickas är
#' [klicka_via_text()] snabbare, särskilt på sidor med många liknande texter.
#'
#' Texten får innehålla apostrofer och citattecken, t.ex. `"Barn's \"bästa\""`.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param text Den synliga text som ska matchas exakt. Obligatorisk.
#'
#' @return Ett selenider-element.
#' @export
#' @example inst/examples/hitta_via_text.R
hitta_via_text <- function(skrap, text) {
  t <- xpath_strang(text)
  hitta(skrap, xpath = paste0(
    "//*[normalize-space(.)=", t, "]",
    "[not(.//*[normalize-space(.)=", t, "])]"
  ))
}
