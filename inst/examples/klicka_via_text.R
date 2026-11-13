# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Klicka på länken med texten "Till tabellen"
  klicka_via_text(skrap, "Till tabellen")
  print(kor_js(skrap, "location.hash"))

  # Klicka på en knapp, utan att vänta på någon sidladdning
  klicka_via_text(skrap, "Visa", vanta = FALSE)
  print(kor_js(skrap, "document.getElementById('resultat').textContent"))

  # Klicka på en länk inuti en iframe
  klicka_via_text(skrap, "Länk i iframe", iframe = "#ram")

  stang_skrapsession(skrap)
}
