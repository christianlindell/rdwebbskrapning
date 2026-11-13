# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Hitta länken med texten "Till tabellen" och läs vart den pekar
  lank <- hitta_via_text(skrap, "Till tabellen")
  print(selenider::elem_attr(lank, "href"))

  # Vänta tills ett element med en viss text syns och klicka sedan
  hitta_via_text(skrap, "Befolkning") |>
    selenider::elem_expect(function(x) selenider::is_visible(x), timeout = 10) |>
    selenider::elem_click()
  print(kor_js(skrap, "document.getElementById('resultat').textContent"))

  # Texten får innehålla apostrofer
  kalla <- hitta_via_text(skrap, "Källa: SCB:s 'Befolkningsstatistik'")
  print(selenider::elem_attr(kalla, "id"))

  stang_skrapsession(skrap)
}
