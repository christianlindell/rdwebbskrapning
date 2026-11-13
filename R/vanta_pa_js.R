#' Vänta tills ett JavaScript-villkor blir sant
#'
#' Kontrollerar ett JavaScript-uttryck med jämna mellanrum tills det blir
#' `true`. Kompletterar `selenider::elem_expect(is_visible)`, som bara ser om
#' ett element finns och syns. På vissa sidor syns elementen innan sidans
#' egen JavaScript är klar (t.ex. innan en global variabel som en
#' onchange-hanterare behöver har skapats), och ett klick eller val ger då ett
#' JavaScript-fel trots att elementet syns.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param villkor JavaScript-uttryck som ger ett logiskt värde, t.ex.
#'   `"typeof AR !== 'undefined'"`. Obligatorisk.
#' @param timeout Högsta antal sekunder att vänta. Standard är 30.
#' @param intervall Antal sekunder mellan kontrollerna. Standard är 0,25.
#'
#' @return Osynligt `TRUE` när villkoret är sant. Ger ett fel om villkoret
#'   inte blivit sant inom `timeout` sekunder.
#' @export
#' @example inst/examples/vanta_pa_js.R
vanta_pa_js <- function(skrap, villkor, timeout = 30, intervall = 0.25) {
  if (!inherits(skrap, "skrapsession")) {
    stop("Objektet \u00e4r inte skapat av starta_skrapsession().")
  }

  start <- Sys.time()
  repeat {
    if (isTRUE(kor_js(skrap, villkor))) {
      return(invisible(TRUE))
    }
    if (as.numeric(difftime(Sys.time(), start, units = "secs")) > timeout) {
      stop("Villkoret blev aldrig sant inom ", timeout, " sekunder: ", villkor)
    }
    Sys.sleep(intervall)
  }
}
