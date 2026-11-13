# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Värde och text för varje alternativ i listan med id "kommuner"
  print(hamta_select_options(skrap, "#kommuner"))

  # Listan kan också pekas ut med namn
  print(hamta_select_options(skrap, "select[name='ar']"))

  stang_skrapsession(skrap)
}
