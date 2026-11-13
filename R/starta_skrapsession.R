#' Starta en skrapsession i Edge eller Chrome
#'
#' Startar webbläsaren med en felsökningsport, ansluter chromote till den och
#' kopplar en selenider-session till samma webbläsare. Sessionen skickas sedan
#' till paketets övriga funktioner och stängs med [stang_skrapsession()].
#' Vill du att sessionen stängs automatiskt, använd [with_skrapsession()].
#'
#' Några detaljer som gör att det fungerar på företagsdatorer:
#' - chromote ansluter via `127.0.0.1` och inte `localhost`, som kan lösas
#'   till `::1` och göra att chromote får timeout trots att webbläsaren svarar.
#' - Webbläsaren startas med `processx::process$new(..., supervise = FALSE)`.
#'   Annars startar processx en hjälpprocess (supervisor.exe) som ofta
#'   blockeras av AppLocker.
#' - Internetanslutningen testas först med [test_internetanslutning()], så att
#'   man får ett tydligt fel direkt om nätverket saknas.
#'
#' @param port Felsökningsport för webbläsaren, som heltal. `NULL` (standard)
#'   väljer en ledig port automatiskt, vilket också gör att flera sessioner
#'   kan köras samtidigt.
#' @param headless `TRUE` (standard) kör webbläsaren utan synligt fönster.
#'   `FALSE` öppnar ett maximerat fönster, vilket är bra när man bygger ett
#'   nytt skript och vill se vad som händer.
#' @param browser_path Sökväg till msedge.exe eller chrome.exe, som text.
#'   `NULL` (standard) söker upp webbläsaren med [hitta_webblasare()].
#'   Miljövariabeln `SKRAP_EDGE_PATH` har företräde om den är satt.
#' @param profil_dir Mapp för webbläsarens tillfälliga användarprofil. Standard
#'   är en ny tillfällig mapp för varje session. Mappen tas bort av
#'   [stang_skrapsession()].
#' @param timeout Antal sekunder att vänta på att felsökningsporten svarar.
#'   Standard är 15.
#' @param view `TRUE` visar webbläsarfönstret via chromote (kräver även
#'   `headless = FALSE`). Standard är `FALSE`.
#' @param bredd Visningsytans bredd i pixlar. Standard är 1600. Höj om sidan
#'   bara syns i en smal kolumn trots ett maximerat fönster.
#' @param hojd Visningsytans höjd i pixlar. Standard är 1000.
#' @param user_agent User agent-sträng som webbläsaren ska använda, som text.
#'   `NULL` (standard) behåller webbläsarens egen. I headless-läge innehåller
#'   den "HeadlessChrome", som enkla botskydd känner igen; ange då en vanlig
#'   webbläsares user agent.
#'
#' @return Ett objekt av klassen `skrapsession`, en lista med fälten `session`
#'   (selenider-session), `chrom` (Chromote-objekt), `process`
#'   (processx-process), `profil_dir` och `port`.
#' @seealso [testa_skrapmiljo()] om sessionen inte går att starta.
#' @export
#' @example inst/examples/starta_skrapsession.R
starta_skrapsession <- function(port = NULL,
                                headless = TRUE,
                                browser_path = NULL,
                                profil_dir = tempfile("edge-profil-"),
                                timeout = 15,
                                view = FALSE,
                                bredd = 1600,
                                hojd = 1000,
                                user_agent = NULL) {

  # Kolla internetanslutning forst - ger ett tydligt fel direkt istallet for
  # att spendera flera sekunder pa att starta Edge/chromote i onodan, for
  # att sedan fastna med ett kryptiskt timeout-fel langre in i skrapningen.
  if (!test_internetanslutning()) {
    stop(
      "Ingen internetanslutning kunde uppt\u00e4ckas (n\u00e5dde inte ",
      "raw.githubusercontent.com).\n",
      "Kontrollera n\u00e4tverkskabel/wifi, VPN och brandv\u00e4gg/proxy, och f\u00f6rs\u00f6k igen.\n",
      "K\u00f6r testa_skrapmiljo() f\u00f6r en steg-f\u00f6r-steg-diagnos av \u00f6vriga ",
      "f\u00f6ruts\u00e4ttningar (webbl\u00e4sare, portar, chromote)."
    )
  }

  # Leta upp Edge/Chrome automatiskt om ingen sokvag angetts uttryckligen
  if (is.null(browser_path)) {
    browser_path <- hitta_webblasare()
  }
  if (is.null(browser_path) || !file.exists(browser_path)) {
    stop(
      "Hittar ingen Chromium-baserad webbl\u00e4sare (Edge eller Chrome).\n",
      "Ange s\u00f6kv\u00e4gen via argumentet browser_path, eller s\u00e4tt milj\u00f6variabeln ",
      "SKRAP_EDGE_PATH i .Renviron.\n",
      "K\u00f6r testa_skrapmiljo() f\u00f6r en steg-f\u00f6r-steg-diagnos."
    )
  }

  # Valj en ledig port automatiskt om ingen port angetts. Detta undviker att
  # av misstag ansluta till en gammal, kvarglomd Edge-process pa samma port
  # (vilket ger kryptiska fel som "Session and underlying target have been
  # closed"), och gor det ocksa mojligt att kora flera sessioner parallellt.
  if (is.null(port)) {
    rlang::check_installed("httpuv", reason = "f\u00f6r att v\u00e4lja en ledig port automatiskt")
    port <- httpuv::randomPort(min = 9222, max = 9999, host = "127.0.0.1")
  }

  dir.create(profil_dir, showWarnings = FALSE, recursive = TRUE)

  args <- c(
    if (isTRUE(headless)) "--headless" else "--start-maximized",
    paste0("--remote-debugging-port=", port),
    paste0("--user-data-dir=", profil_dir),
    "--no-first-run",
    "--no-default-browser-check",
    # Headless-laget avslojar sig sjalvt via "HeadlessChrome" i user
    # agent-strangen - den vanligaste signalen enkla botskydd tittar pa.
    # Med user_agent kan en vanlig UA-strang sattas aven i headless-lage.
    if (!is.null(user_agent)) paste0("--user-agent=", user_agent)
  )

  # supervise = FALSE ar avgorande: undviker processx supervisor.exe
  proc <- processx::process$new(
    command = browser_path,
    args = args,
    supervise = FALSE
  )

  # Vanta tills Edges debug-port svarar (eller processen dor)
  url <- sprintf("http://127.0.0.1:%d/json/version", port)
  ok <- FALSE
  forsok <- max(1L, ceiling(timeout * 2))
  for (i in seq_len(forsok)) {
    if (!proc$is_alive()) {
      stop(
        "Edge avslutades ov\u00e4ntat vid start. Kontrollera s\u00f6kv\u00e4g, ",
        "r\u00e4ttigheter och att porten ", port, " inte redan \u00e4r upptagen."
      )
    }
    ok <- tryCatch(
      {
        httr::GET(url, httr::timeout(1))
        TRUE
      },
      error = function(e) FALSE
    )
    if (ok) break
    Sys.sleep(0.5)
  }

  if (!ok) {
    proc$kill()
    unlink(profil_dir, recursive = TRUE, force = TRUE)
    stop("Edge svarade inte p\u00e5 debug-porten inom ", timeout, " sekunder.")
  }

  b <- chromote::ChromeRemote$new(host = "127.0.0.1", port = port)
  chrom <- chromote::Chromote$new(browser = b)

  session <- selenider::selenider_session(
    options = selenider::chromote_options(parent = chrom, width = bredd, height = hojd),
    view = view,
    local = FALSE
  )

  structure(
    list(
      session = session,
      chrom = chrom,
      process = proc,
      profil_dir = profil_dir,
      port = port
    ),
    class = "skrapsession"
  )
}
