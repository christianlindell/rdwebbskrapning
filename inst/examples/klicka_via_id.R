# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Klicka på knappen med id "visa"
  klicka_via_id(skrap, "#visa")
  print(kor_js(skrap, "document.getElementById('resultat').textContent"))

  # Vilken CSS-selektor som helst går bra, t.ex. en länk via dess href
  klicka_via_id(skrap, "a[href='#tabell']")
  print(kor_js(skrap, "location.hash"))

  # Ett element i en iframe
  klicka_via_id(skrap, "#inne_lank", iframe = "#ram")

  stang_skrapsession(skrap)
}
