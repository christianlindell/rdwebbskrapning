#' Testa om datorn klarar att köra en skrapsession
#'
#' Går igenom förutsättningarna för [starta_skrapsession()] en i taget och
#' skriver ut var det brister, så att en ny användare ser om det är
#' paketinstallationen, webbläsarens sökväg, AppLocker eller nätverket som
#' stoppar i stället för att fastna i ett kryptiskt felmeddelande.
#'
#' Testerna, i ordning:
#' 1. Att det finns internetanslutning (raw.githubusercontent.com nås).
#' 2. Att de R-paket som behövs är installerade.
#' 3. Att webbläsaren hittas på angiven eller förväntad sökväg.
#' 4. Att processx kan starta webbläsaren med en felsökningsport (fångar
#'    AppLocker-blockering av själva starten).
#' 5. Att felsökningsporten svarar på 127.0.0.1 (fångar brandvägg och
#'    blockerad lokal trafik).
#' 6. Att chromote kan ansluta hela vägen och skapa en session.
#'
#' Testet avbryts vid första steg som misslyckas.
#'
#' @param browser_path Sökväg till msedge.exe eller chrome.exe, som text.
#'   `NULL` (standard) söker upp webbläsaren med [hitta_webblasare()].
#'
#' @return Osynligt `TRUE` om alla tester gick igenom, annars `FALSE`.
#'   Resultatet av varje steg skrivs ut med [message()].
#' @export
#' @example inst/examples/testa_skrapmiljo.R
testa_skrapmiljo <- function(browser_path = NULL) {

  ok_rad  <- function(txt) message("  [OK]    ", txt)
  fel_rad <- function(txt) message("  [FEL]   ", txt)
  info_rad <- function(txt) message("          ", txt)

  message("Testar f\u00f6ruts\u00e4ttningar f\u00f6r skrapsession ...\n")

  # --- 1. Internetanslutning -------------------------------------------------
  if (!test_internetanslutning()) {
    fel_rad("Ingen internetanslutning kunde uppt\u00e4ckas.")
    info_rad("N\u00e5dde inte raw.githubusercontent.com. Kontrollera n\u00e4tverkskabel/")
    info_rad("wifi, VPN och brandv\u00e4gg/proxy, och f\u00f6rs\u00f6k igen.")
    return(invisible(FALSE))
  }
  ok_rad("Internetuppkoppling fungerar.")

  # --- 2. R-paket -----------------------------------------------------------
  noodvandiga <- c("chromote", "selenider", "processx", "httr", "jsonlite", "httpuv")
  saknade <- noodvandiga[!vapply(noodvandiga, requireNamespace, logical(1), quietly = TRUE)]
  if (length(saknade)) {
    fel_rad(paste0("F\u00f6ljande R-paket saknas: ", paste(saknade, collapse = ", ")))
    info_rad(paste0("Installera med: install.packages(c(",
                    paste0('\"', saknade, '\"', collapse = ", "), "))"))
    info_rad("G\u00e5r inte det: kontrollera \u00e5tkomst till CRAN (proxy?) och att")
    info_rad("kompilering till\u00e5ts (Rtools). Avbryter h\u00e4r.")
    return(invisible(FALSE))
  }
  ok_rad("Alla n\u00f6dv\u00e4ndiga R-paket \u00e4r installerade.")

  # --- 3. Webblasare hittas -------------------------------------------------
  if (is.null(browser_path)) {
    browser_path <- hitta_webblasare()
  }
  if (is.null(browser_path) || !file.exists(browser_path)) {
    fel_rad("Hittar ingen Chromium-baserad webbl\u00e4sare (Edge eller Chrome).")
    info_rad("Ange r\u00e4tt s\u00f6kv\u00e4g via SKRAP_EDGE_PATH i .Renviron, t.ex.:")
    info_rad('  SKRAP_EDGE_PATH=C:/Program Files/Microsoft/Edge/Application/msedge.exe')
    return(invisible(FALSE))
  }
  ok_rad(paste0("Webbl\u00e4sare hittad: ", browser_path))

  # --- 4. Starta Edge med debug-port (fangar AppLocker) --------------------
  port <- httpuv::randomPort(min = 9222, max = 9999, host = "127.0.0.1")
  profil_dir <- tempfile("edge-testprofil-")
  dir.create(profil_dir, showWarnings = FALSE, recursive = TRUE)

  proc <- tryCatch(
    processx::process$new(
      command = browser_path,
      args = c("--headless", paste0("--remote-debugging-port=", port),
               paste0("--user-data-dir=", profil_dir),
               "--no-first-run", "--no-default-browser-check"),
      supervise = FALSE
    ),
    error = function(e) e
  )
  if (inherits(proc, "error")) {
    fel_rad("Kunde inte starta Edge-processen.")
    if (grepl("1260|grupprincip|blocked", conditionMessage(proc), ignore.case = TRUE)) {
      info_rad("Felet tyder p\u00e5 AppLocker/gruppolicy (felkod 1260) - starten av")
      info_rad("webbl\u00e4saren blockeras. Kontakta IT om vitlistning, eller testa")
      info_rad("om en annan Edge-s\u00f6kv\u00e4g under Program Files \u00e4r till\u00e5ten.")
    } else {
      info_rad(paste0("Felmeddelande: ", conditionMessage(proc)))
    }
    unlink(profil_dir, recursive = TRUE, force = TRUE)
    return(invisible(FALSE))
  }
  ok_rad("Edge-processen startade.")

  # Stad upp oavsett hur resten gar
  on.exit({
    if (proc$is_alive()) proc$kill()
    unlink(profil_dir, recursive = TRUE, force = TRUE)
  }, add = TRUE)

  # --- 5. Debug-porten svarar pa 127.0.0.1 (fangar loopback/brandvagg) -----
  url <- sprintf("http://127.0.0.1:%d/json/version", port)
  svarat <- FALSE
  for (i in 1:20) {
    if (!proc$is_alive()) {
      fel_rad("Edge avslutades ov\u00e4ntat direkt efter start.")
      info_rad("Kan tyda p\u00e5 att en policy st\u00e4nger webbl\u00e4saren, eller att")
      info_rad("debug-porten \u00e4r sp\u00e4rrad. Kontakta IT.")
      return(invisible(FALSE))
    }
    svarat <- tryCatch({ httr::GET(url, httr::timeout(1)); TRUE },
                       error = function(e) FALSE)
    if (svarat) break
    Sys.sleep(0.5)
  }
  if (!svarat) {
    fel_rad(paste0("Debug-porten ", port, " svarade inte p\u00e5 127.0.0.1."))
    info_rad("Edge k\u00f6r, men g\u00e5r inte att n\u00e5 via loopback. Kan bero p\u00e5 en")
    info_rad("brandv\u00e4gg eller EDR-produkt som blockerar lokal trafik. Kontakta IT.")
    return(invisible(FALSE))
  }
  ok_rad("Debug-porten svarar p\u00e5 127.0.0.1.")

  # --- 6. chromote ansluter hela vagen -------------------------------------
  anslutning <- tryCatch({
    b <- chromote::ChromeRemote$new(host = "127.0.0.1", port = port)
    chrom <- chromote::Chromote$new(browser = b)
    sess <- chrom$new_session()
    sess$close()
    chrom$close()
    TRUE
  }, error = function(e) e)

  if (inherits(anslutning, "error")) {
    fel_rad("chromote kunde inte ansluta hela v\u00e4gen.")
    info_rad(paste0("Felmeddelande: ", conditionMessage(anslutning)))
    return(invisible(FALSE))
  }
  ok_rad("chromote ansl\u00f6t och kunde skapa en session.")

  message("\nAlla tester gick igenom - milj\u00f6n klarar av att k\u00f6ra en skrapsession.")
  invisible(TRUE)
}
