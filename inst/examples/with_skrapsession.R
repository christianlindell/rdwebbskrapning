sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")

# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {

  # Sessionen finns i variabeln skrap och stängs automatiskt efteråt.
  # Det sista värdet i koden returneras.
  titel <- with_skrapsession({
    selenider::open_url(paste0("file:///", sida), session = skrap$session)
    kor_js(skrap, "document.title")
  })
  print(titel)

  # Argument efter koden skickas vidare till starta_skrapsession()
  bredd <- with_skrapsession(kor_js(skrap, "window.innerWidth"), bredd = 1200)
  print(bredd)
}
