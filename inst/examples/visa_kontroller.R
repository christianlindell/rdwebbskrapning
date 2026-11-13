# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Översikt över sidans select-listor och klickbara element
  visa_kontroller(skrap)

  # Visa högst två alternativ per lista
  visa_kontroller(skrap, max_options = 2)

  stang_skrapsession(skrap)
}
