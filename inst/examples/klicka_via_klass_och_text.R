# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Exempelsidan har två div-"knappar" med klassen "kort". Klicka på den med
  # texten "Arbetsmarknad".
  klicka_via_klass_och_text(skrap, "kort", "Arbetsmarknad")
  print(kor_js(skrap, "document.getElementById('resultat').textContent"))

  # Samma sak för en annan tagg och utan att vänta på sidladdning
  klicka_via_klass_och_text(skrap, "kort", "Befolkning", tag = "div", vanta = FALSE)
  print(kor_js(skrap, "document.getElementById('resultat').textContent"))

  stang_skrapsession(skrap)
}
