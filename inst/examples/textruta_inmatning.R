# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Skriv "Dalarna" i sökrutan och klicka på Visa
  textruta_inmatning(skrap, "#sokruta", "Dalarna")
  klicka_via_id(skrap, "#visa")
  print(kor_js(skrap, "document.getElementById('resultat').textContent"))

  # Lägg till text efter det som redan står i fältet
  textruta_inmatning(skrap, "#sokruta", " län", rensa = FALSE)
  print(kor_js(skrap, "document.getElementById('sokruta').value"))

  stang_skrapsession(skrap)
}
