# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Bara värdena i listan med år
  ar <- hamta_select_varden(skrap, "#ar")
  print(ar)

  # Alla år utom 2022
  print(setdiff(ar, "2022"))

  stang_skrapsession(skrap)
}
