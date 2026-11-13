#' rdwebbskrapning: webbskrapning med Edge eller Chrome
#'
#' Paketet startar en Chromium-baserad webbläsare (Microsoft Edge eller Google
#' Chrome) och styr den från R via chromote och selenider. Det används för att
#' hämta data från webbsidor som inte har något API, där man måste klicka,
#' välja i listor, fylla i fält eller ladda ner filer.
#'
#' Webbläsaren startas så att det fungerar även på datorer med AppLocker och
#' företagsproxy. Kör [testa_skrapmiljo()] först på en ny dator för att se om
#' allt som behövs finns.
#'
#' @section Starta och stänga:
#' - [starta_skrapsession()], [stang_skrapsession()], [with_skrapsession()]
#' - [testa_skrapmiljo()], [hitta_webblasare()], [test_internetanslutning()]
#'
#' @section Undersöka en sida:
#' - [inspektera_kontroller()], [visa_kontroller()], [kor_js()]
#' - [hitta()], [hitta_alla()], [hitta_via_text()]
#'
#' @section Klicka och vänta:
#' - [klicka_via_text()], [klicka_via_klass_och_text()], [klicka_via_id()]
#' - [vanta_pa_js()]
#'
#' @section Listor, textrutor och attribut:
#' - [hamta_select_options()], [hamta_select_varden()]
#' - [valj_i_lista()], [valj_option_utan_event()]
#' - [textruta_inmatning()], [hamta_attribut()]
#'
#' @section Ladda ner filer och logga:
#' - [hamta_nedladdning()], [stall_in_nedladdningsmapp()]
#' - [loggning_initiera()]
#'
#' @keywords internal
"_PACKAGE"
