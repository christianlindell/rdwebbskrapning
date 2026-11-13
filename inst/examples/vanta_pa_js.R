# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Exempelsidan sätter variabeln sidanKlar en halv sekund efter laddningen.
  # Vänta tills den finns innan sidan används.
  vanta_pa_js(skrap, "window.sidanKlar === true")

  # Vänta på ett villkor om sidans innehåll, med kortare timeout och tätare
  # kontroller
  vanta_pa_js(skrap, "document.querySelectorAll('#ar option').length === 3",
              timeout = 5, intervall = 0.1)

  stang_skrapsession(skrap)
}
