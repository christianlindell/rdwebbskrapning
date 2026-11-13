# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  kontroller <- inspektera_kontroller(skrap)

  # Alla select-listor och deras alternativ
  print(kontroller$selects)

  # Länkar, knappar och element som ser klickbara ut
  print(kontroller$klickbara)

  # Textrutor, kryssrutor och radioknappar
  print(kontroller$inmatning)

  stang_skrapsession(skrap)
}
