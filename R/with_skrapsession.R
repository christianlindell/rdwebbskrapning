#' Kör kod i en skrapsession som stängs automatiskt efteråt
#'
#' Startar en session med [starta_skrapsession()], kör `expr` och stänger
#' sessionen med [stang_skrapsession()], även om koden i `expr` ger ett fel.
#' I `expr` finns sessionen i variabeln `skrap`.
#'
#' Objekt som skapas i `expr` finns inte kvar efteråt. Låt i stället `expr`
#' sluta med det värde du vill ha tillbaka.
#'
#' @param expr Kod som ska köras. Variabeln `skrap` pekar på sessionen.
#'   Obligatorisk.
#' @param ... Skickas vidare till [starta_skrapsession()], t.ex.
#'   `headless = FALSE`.
#'
#' @return Värdet av `expr`.
#' @export
#' @example inst/examples/with_skrapsession.R
with_skrapsession <- function(expr, ...) {
  skrap <- starta_skrapsession(...)
  on.exit(stang_skrapsession(skrap), add = TRUE)
  eval(substitute(expr), envir = list(skrap = skrap), enclos = parent.frame())
}
