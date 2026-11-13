# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Välj år 2022. Sidans onchange-kod körs och uppdaterar texten "Valt år".
  valj_i_lista(skrap, "#ar", "2022")
  print(kor_js(skrap, "document.getElementById('valt_ar').textContent"))

  # Välj det senaste året, med listan utpekad via sitt namn
  senaste <- max(hamta_select_varden(skrap, "#ar"))
  valj_i_lista(skrap, "select[name='ar']", senaste)
  print(kor_js(skrap, "document.getElementById('valt_ar').textContent"))

  stang_skrapsession(skrap)
}
