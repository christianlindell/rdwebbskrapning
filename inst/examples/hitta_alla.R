# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Alla alternativ i listan med kommuner
  alternativ <- hitta_alla(skrap, "#kommuner option")
  print(length(alternativ))

  # Texten i det första alternativet
  print(selenider::elem_text(alternativ[[1]]))

  # Alla div-"knappar" med klassen kort, hittade med xpath
  kort <- hitta_alla(skrap, xpath = "//div[contains(@class, 'kort')]")
  print(length(kort))

  stang_skrapsession(skrap)
}
