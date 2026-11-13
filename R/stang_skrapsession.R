#' Stäng en skrapsession och städa bort allt den skapade
#'
#' Stänger selenider-sessionen och chromote-anslutningen, avslutar den
#' webbläsarprocess som [starta_skrapsession()] startade (inte andra Edge-
#' eller Chrome-fönster som redan är öppna på datorn) och tar bort den
#' tillfälliga profilmappen.
#'
#' En rad i stil med "handle_read_frame error ... anslutningen tvingades
#' stänga" kan skrivas ut när sessionen stängs. Den är ofarlig och betyder
#' bara att webbläsaren stängdes innan anslutningen hann kopplas ner.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#'
#' @return Osynligt `TRUE`.
#' @export
#' @example inst/examples/stang_skrapsession.R
stang_skrapsession <- function(skrap) {
  if (!inherits(skrap, "skrapsession")) {
    stop("Objektet \u00e4r inte skapat av starta_skrapsession().")
  }

  message("St\u00e4nger skrapsessionen. En rad i stil med ",
          "'handle_read_frame error ... anslutningen tvingades st\u00e4nga' ",
          "kan visas h\u00e4r - det \u00e4r ofarligt och betyder bara att ",
          "webbl\u00e4sarprocessen st\u00e4ngdes innan anslutningen hann kopplas ner snyggt.")

  # Stang i ratt ordning: selenider -> chromote -> sjalva Edge-processen.
  # Websocket-lagret under chromote loggar annars en ofarlig
  # "handle_read_frame error ... 10054"-rad om Edge-processen doodas innan
  # anslutningen hunnit koppla ned snyggt. Vi ger nedkopplingen en kort
  # respit och fangar stderr under tiden for att halla utskriften borta.
  # (Utskriften kommer fran ett C++-bibliotek, inte som ett R-warning, sa
  # suppressWarnings() biter inte - darfor sink() pa stderr.)
  tyst <- function(expr) {
    tmp <- tempfile()
    con <- file(tmp, open = "wt")
    sink(con, type = "message")
    on.exit({
      sink(type = "message")
      close(con)
      unlink(tmp)
    }, add = TRUE)
    try(expr, silent = TRUE)
  }

  tyst({
    selenider::close_session(skrap$session)
    skrap$chrom$close()
    Sys.sleep(0.5)  # lat websocket-nedkopplingen slutforas
  })

  if (!is.null(skrap$process) && skrap$process$is_alive()) {
    skrap$process$kill()
  }

  if (dir.exists(skrap$profil_dir)) {
    unlink(skrap$profil_dir, recursive = TRUE, force = TRUE)
  }

  invisible(TRUE)
}
