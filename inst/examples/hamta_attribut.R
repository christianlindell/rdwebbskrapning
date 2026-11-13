# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Vart länken "Till tabellen" pekar
  print(hamta_attribut(skrap, "#tabell_lank", "href"))

  # Ett data-attribut på ett element i en iframe
  print(hamta_attribut(skrap, "#inne_lank", "data-info", iframe = "#ram"))

  # Attribut som saknas ger NA
  print(hamta_attribut(skrap, "#tabell_lank", "title"))

  stang_skrapsession(skrap)
}
