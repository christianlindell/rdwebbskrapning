# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Markera Falun och Mora i flervalslistan
  valj_option_utan_event(skrap, "#kommuner", c("2080", "2062"))
  print(kor_js(skrap, paste0("[...document.querySelector('#kommuner').selectedOptions]",
                             ".map(o => o.text).join(', ')")))

  # Markera år 2023. Ingen change-händelse skickas, så texten "Valt år" på
  # sidan uppdateras inte, men listan har värdet 2023.
  valj_option_utan_event(skrap, "#ar", "2023")
  print(kor_js(skrap, "document.querySelector('#ar').value"))
  print(kor_js(skrap, "document.getElementById('valt_ar').textContent"))

  stang_skrapsession(skrap)
}
