#' Hitta en installerad webbläsare (Edge eller Chrome)
#'
#' Letar efter Microsoft Edge eller Google Chrome på de vanliga
#' installationsplatserna i Windows och, som sista utväg, i Windows-registret.
#' Används av [starta_skrapsession()] och [testa_skrapmiljo()] när ingen
#' sökväg anges, så att paketet fungerar utan inställningar oavsett om
#' webbläsaren ligger under "Program Files" eller "Program Files (x86)".
#'
#' Sökordning: miljövariabeln `SKRAP_EDGE_PATH` (om den är satt och filen
#' finns) går alltid först, därefter Edge före Chrome och 64-bitars före
#' 32-bitars.
#'
#' @return Sökvägen till den första webbläsaren som hittas, som text, eller
#'   `NULL` om ingen hittas.
#' @export
#' @example inst/examples/hitta_webblasare.R
hitta_webblasare <- function() {
  # 1. Uttrycklig miljövariabel vinner alltid
  fran_env <- Sys.getenv("SKRAP_EDGE_PATH", "")
  if (nzchar(fran_env) && file.exists(fran_env)) {
    return(fran_env)
  }

  # 2. Kända sökvägar, Edge fore Chrome
  pf    <- Sys.getenv("PROGRAMFILES", "C:/Program Files")
  pf86  <- Sys.getenv("PROGRAMFILES(X86)", "C:/Program Files (x86)")
  lokal <- Sys.getenv("LOCALAPPDATA", "")

  kandidater <- c(
    file.path(pf86, "Microsoft/Edge/Application/msedge.exe"),
    file.path(pf,   "Microsoft/Edge/Application/msedge.exe"),
    file.path(pf,   "Google/Chrome/Application/chrome.exe"),
    file.path(pf86, "Google/Chrome/Application/chrome.exe"),
    if (nzchar(lokal)) file.path(lokal, "Google/Chrome/Application/chrome.exe")
  )
  kandidater <- gsub("\\\\", "/", kandidater)

  for (k in kandidater) {
    if (file.exists(k)) return(k)
  }

  # 3. Windows-registret som sista utväg (App Paths)
  reg_sok <- function(exe) {
    nyckel <- paste0(
      "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\", exe
    )
    varde <- tryCatch(
      utils::readRegistry(nyckel, hive = "HLM", maxdepth = 1)[["(Default)"]],
      error = function(e) NULL
    )
    if (!is.null(varde) && file.exists(varde)) gsub("\\\\", "/", varde) else NULL
  }
  for (exe in c("msedge.exe", "chrome.exe")) {
    traff <- reg_sok(exe)
    if (!is.null(traff)) return(traff)
  }

  NULL
}
