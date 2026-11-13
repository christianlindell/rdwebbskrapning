# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Ett enkelt värde: sidans titel
  print(kor_js(skrap, "document.title"))

  # Flera värden returneras som JSON-text och tolkas med jsonlite
  json <- kor_js(skrap, paste0("JSON.stringify([...document.querySelectorAll('#kommuner option')]",
                               ".map(o => o.text))"))
  print(jsonlite::fromJSON(json))

  stang_skrapsession(skrap)
}
