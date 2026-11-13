#' Klicka på ett element via CSS-klass och exakt text
#'
#' Som [klicka_via_text()], men klickar bara på element som har en viss
#' CSS-klass och vars text är exakt lika med `text`. Används på sidor där
#' flera element delar samma klass (t.ex. flera "kort" i ett kortgränssnitt),
#' så att varken klassen eller texten ensam räcker för att peka ut rätt
#' element. Fungerar också på div-baserade "knappar" där
#' `selenider::elem_expect(is_visible)` felaktigt säger att elementet inte
#' syns.
#'
#' Om [visa_kontroller()] visar ett element utan `id` och `href` men med en
#' klass, är det troligen en sådan div-knapp, och funktionen skriver då ut
#' ett färdigt anrop till den här funktionen.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param klass CSS-klassens namn utan inledande punkt, t.ex. `"big-button"`.
#'   Obligatorisk.
#' @param text Den synliga text som ska matchas exakt. Obligatorisk.
#' @param tag Elementets HTML-tagg, t.ex. `"div"`, `"span"` eller `"li"`.
#'   Standard är `"div"`.
#' @param vanta `TRUE` (standard) väntar in en sidladdning om klicket startar
#'   en.
#' @param grace Antal sekunder en sidladdning får på sig att börja efter
#'   klicket. Standard är 0,3.
#' @param timeout Högsta antal sekunder att vänta på att en sidladdning blir
#'   klar. Standard är 30.
#' @param iframe CSS-selektor för en iframe som elementet ligger i. `NULL`
#'   (standard) söker på huvudsidan.
#'
#' @return Osynligt `TRUE`. Ger ett fel om inget element matchar.
#' @export
#' @example inst/examples/klicka_via_klass_och_text.R
klicka_via_klass_och_text <- function(skrap, klass, text, tag = "div",
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
         if (els[i].classList.contains(%s) && els[i].textContent.trim() === %s) {
           window.__skrapKlickMarkering = true;
           els[i].click();
           return true;
         }
       }
       return false;
     })()",
    bygg_dokument_js(iframe),
    jsonlite::toJSON(tag, auto_unbox = TRUE),
    jsonlite::toJSON(klass, auto_unbox = TRUE),
    jsonlite::toJSON(text, auto_unbox = TRUE)
  )

  hittad <- kor_js(skrap, js)
  kontrollera_iframe_svar(hittad)
  if (!isTRUE(hittad)) {
    stop("Hittade inget element med tagg '", tag, "', klass '", klass,
         "' och texten: '", text, "'")
  }

  if (isTRUE(vanta)) {
    vanta_pa_sidladdning(skrap, grace = grace, timeout = timeout)
  }
  invisible(TRUE)
}
