#' Skapa en loggfunktion som visar förfluten tid
#'
#' Returnerar en funktion som skriver ut meddelanden med antal sekunder sedan
#' `tid_start`, t.ex. `"[   3.2 s] Startar nedladdning..."`. Den returnerade
#' funktionen kommer ihåg `verbose` och `tid_start`, så att den bara behöver
#' anropas med en text. Används i skrapskript för att se hur lång tid varje
#' steg tar.
#'
#' Meddelandena skrivs med [message()] och kan alltså tystas med
#' `suppressMessages()`.
#'
#' @param verbose `TRUE` (standard) gör att loggfunktionen skriver ut
#'   meddelanden. Med `FALSE` gör den ingenting, vilket gör det lätt att stänga
#'   av loggningen i ett helt skript.
#' @param tid_start Tidpunkt (POSIXct) som förfluten tid räknas från. Standard
#'   är tidpunkten då `loggning_initiera()` anropas.
#'
#' @return En funktion med ett argument, `txt`, som skriver ut `txt` med
#'   förfluten tid framför.
#' @export
#' @example inst/examples/loggning_initiera.R
loggning_initiera <- function(verbose = TRUE, tid_start = Sys.time()) {
  force(tid_start)
  function(txt) {
    if (isTRUE(verbose)) {
      message(sprintf("[%6.1f s] %s",
                      as.numeric(difftime(Sys.time(), tid_start, units = "secs")),
                      txt))
    }
  }
}
