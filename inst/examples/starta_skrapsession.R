# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {

  # Enklaste anropet: headless webbläsare på en ledig port
  skrap <- starta_skrapsession()
  print(skrap$port)
  print(skrap$process$is_alive())

  # Öppna exempelsidan som följer med paketet och läs sidans titel
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)
  print(kor_js(skrap, "document.title"))
  stang_skrapsession(skrap)

  # Med en vanlig user agent, så att sidan inte ser att webbläsaren är
  # headless. Med headless = FALSE öppnas i stället ett synligt fönster.
  ua <- paste("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
              "(KHTML, like Gecko) Chrome/124.0 Safari/537.36 Edg/124.0")
  skrap <- starta_skrapsession(user_agent = ua, bredd = 1200, hojd = 800)
  print(kor_js(skrap, "navigator.userAgent"))
  stang_skrapsession(skrap)
}
