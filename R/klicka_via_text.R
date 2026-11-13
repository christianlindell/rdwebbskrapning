#' Klicka på ett element via dess synliga text
#'
#' Klickar på det första elementet (i dokumentordning) vars text, efter att
#' blanksteg i början och slutet tagits bort, är exakt lika med `text`.
#' Klicket görs i en enda JavaScript-körning. Det är mycket snabbare än ett
#' xpath-baserat `selenider::elem_click()` på sidor med många element med
#' liknande text (t.ex. en lång lista med "Alla kommuner", en per län), där
#' seleniders upprepade väntekontroller kan ta uppemot en minut.
#'
#' Standardselektorn tar bara med riktiga klickbara element (`a`, `button`,
#' `input` och `label`), inte `div`, `span` eller `li`. Det är medvetet: en
#' `<div>` som bara innehåller en länk har samma text som länken och kommer
#' före den i dokumentordning, men ett klick på `<div>` gör oftast ingenting.
#' Ange `selector` bara om målelementet är av en annan typ, t.ex. `"td"` för
#' en klickbar tabellcell. För div-"knappar" med en klass, använd
#' [klicka_via_klass_och_text()].
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param text Den synliga text som ska matchas exakt. Obligatorisk.
#' @param selector CSS-selektor som avgränsar vilka element som kontrolleras.
#'   Standard är `"a, button, input[type=button], input[type=submit], label"`.
#' @param vanta `TRUE` (standard) väntar in en sidladdning om klicket startar
#'   en, t.ex. en postback.
#' @param grace Antal sekunder en sidladdning får på sig att börja efter
#'   klicket. Om ingen börjar inom den tiden går funktionen vidare. Standard
#'   är 0,3.
#' @param timeout Högsta antal sekunder att vänta på att en sidladdning blir
#'   klar. Standard är 30.
#' @param iframe CSS-selektor för en iframe som elementet ligger i, eller en
#'   vektor av selektorer för nästlade iframes. `NULL` (standard) söker på
#'   huvudsidan. Fungerar bara för iframes från samma domän.
#'
#' @return Osynligt `TRUE`. Ger ett fel om inget element med texten hittas.
#' @export
#' @example inst/examples/klicka_via_text.R
klicka_via_text <- function(skrap, text, selector = "a, button, input[type=button], input[type=submit], label",
                            vanta = TRUE, grace = 0.3, timeout = 30,
                            iframe = NULL) {
  if (!inherits(skrap, "skrapsession")) {
    stop("Objektet \u00e4r inte skapat av starta_skrapsession().")
  }
  rlang::check_installed("jsonlite")

  js <- sprintf(
    "(function(){
       %s
       var els = dok.querySelectorAll(%s);
       for (var i = 0; i < els.length; i++) {
         if (els[i].textContent.trim() === %s) {
           window.__skrapKlickMarkering = true;
           els[i].click();
           return true;
         }
       }
       return false;
     })()",
    bygg_dokument_js(iframe),
    jsonlite::toJSON(selector, auto_unbox = TRUE),
    jsonlite::toJSON(text, auto_unbox = TRUE)
  )

  hittad <- kor_js(skrap, js)
  kontrollera_iframe_svar(hittad)
  if (!isTRUE(hittad)) {
    stop("Hittade inget klickbart element med texten: '", text, "'")
  }

  if (isTRUE(vanta)) {
    vanta_pa_sidladdning(skrap, grace = grace, timeout = timeout)
  }
  invisible(TRUE)
}
