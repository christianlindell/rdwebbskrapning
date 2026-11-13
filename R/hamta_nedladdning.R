#' Klicka fram en nedladdning och vänta tills filen är klar
#'
#' Ställer in en nedladdningsmapp med [stall_in_nedladdningsmapp()], kör den
#' kod som startar nedladdningen (t.ex. ett klick på en exportknapp) och
#' väntar sedan tills en ny fil dykt upp i mappen och slutat växa, det vill
#' säga tills webbläsaren skrivit klart den.
#'
#' Webbläsaren sparar ofärdiga nedladdningar med ändelsen `.crdownload` eller
#' `.tmp`. Sådana filer räknas inte.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param trigger En funktion utan argument som startar nedladdningen, t.ex.
#'   `function() klicka_via_id(skrap, "#exportera", vanta = FALSE)`.
#'   Obligatorisk.
#' @param nedladdningsmapp Mapp dit filen sparas. Standard är en ny tillfällig
#'   mapp för varje anrop.
#' @param monster Reguljärt uttryck som filnamnet måste matcha, t.ex.
#'   `"\\.xlsx$"`. Behövs om sidan skapar flera filer och bara en av dem är
#'   den du vill ha. `NULL` (standard) tar den första nya filen.
#' @param timeout Högsta antal sekunder att vänta på att filen dyker upp och
#'   blir klar. Standard är 30.
#' @param stabil_tid Antal sekunder filens storlek måste vara oförändrad innan
#'   filen räknas som klar. Standard är 1. Höj för stora filer på långsamma
#'   nät.
#'
#' @return Sökvägen till den nedladdade filen, som text. Ger ett fel om ingen
#'   fil blivit klar inom `timeout` sekunder.
#' @export
#' @example inst/examples/hamta_nedladdning.R
hamta_nedladdning <- function(skrap,
                              trigger,
                              nedladdningsmapp = tempfile("nedladdning-"),
                              monster = NULL,
                              timeout = 30,
                              stabil_tid = 1) {

  if (!inherits(skrap, "skrapsession")) {
    stop("Objektet \u00e4r inte skapat av starta_skrapsession().")
  }
  if (!is.function(trigger)) {
    stop("trigger m\u00e5ste vara en funktion utan argument, t.ex. ",
         "function() hitta(skrap, 'button') |> selenider::elem_click()")
  }

  stall_in_nedladdningsmapp(skrap, nedladdningsmapp)

  filer_innan <- list.files(nedladdningsmapp, full.names = TRUE)

  trigger()

  start <- Sys.time()
  senast_storlek <- -1
  stabil_sedan <- NULL

  repeat {
    if (as.numeric(difftime(Sys.time(), start, units = "secs")) > timeout) {
      stop(
        "Ingen nedladdning blev klar inom ", timeout,
        " sekunder i mappen: ", nedladdningsmapp
      )
    }

    alla_filer <- list.files(nedladdningsmapp, full.names = TRUE)
    if (!is.null(monster)) {
      alla_filer <- alla_filer[grepl(monster, alla_filer)]
    }
    nya_filer <- setdiff(alla_filer, filer_innan)
    # Ignorera Edges/Chromes ofardiga nedladdningsfiler
    kandidater <- nya_filer[!grepl("\\.crdownload$|\\.tmp$", nya_filer)]

    if (length(kandidater) >= 1) {
      fil <- kandidater[[1]]
      storlek <- suppressWarnings(file.info(fil)$size)

      if (!is.na(storlek) && storlek == senast_storlek && storlek > 0) {
        if (is.null(stabil_sedan)) {
          stabil_sedan <- Sys.time()
        }
        if (as.numeric(difftime(Sys.time(), stabil_sedan, units = "secs")) >= stabil_tid) {
          return(fil)
        }
      } else {
        senast_storlek <- storlek
        stabil_sedan <- NULL
      }
    }

    Sys.sleep(0.3)
  }
}
