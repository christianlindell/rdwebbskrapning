#' Ställ in var webbläsaren sparar nedladdade filer
#'
#' Talar om för webbläsaren (via Chrome DevTools-protokollet) att
#' nedladdningar ska tillåtas och sparas i `mapp`. Anropas normalt inte
#' direkt utan av [hamta_nedladdning()], men behövs om du vill ladda ner filer
#' på annat sätt, t.ex. med flera klick i följd.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param mapp Mapp dit nedladdningar ska sparas. Skapas om den inte finns.
#'   Obligatorisk.
#'
#' @return Osynligt mappens sökväg, som den angavs.
#' @export
#' @example inst/examples/stall_in_nedladdningsmapp.R
stall_in_nedladdningsmapp <- function(skrap, mapp) {
  if (!inherits(skrap, "skrapsession")) {
    stop("Objektet \u00e4r inte skapat av starta_skrapsession().")
  }

  dir.create(mapp, showWarnings = FALSE, recursive = TRUE)

  # Windows-Edge ar sakrast med backslash-sokvagar i downloadPath
  mapp_norm <- normalizePath(mapp, winslash = "\\", mustWork = FALSE)

  # Vilken niva kommandot maste skickas till (hela webblasaren eller den
  # enskilda flikens session) varierar mellan Chrome/Edge-versioner - satt
  # pa BADA for att vara saker. try() pa webblasarnivan eftersom vissa
  # versioner avvisar kommandot dar nar det saknar browserContextId.
  try(
    skrap$chrom$Browser$setDownloadBehavior(
      behavior = "allow",
      downloadPath = mapp_norm
    ),
    silent = TRUE
  )
  skrap$session$driver$Browser$setDownloadBehavior(
    behavior = "allow",
    downloadPath = mapp_norm
  )

  invisible(mapp)
}
