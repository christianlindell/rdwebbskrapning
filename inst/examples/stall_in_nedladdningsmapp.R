# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Spara nedladdningar i en tillfällig mapp
  mapp <- stall_in_nedladdningsmapp(skrap, file.path(tempdir(), "skrapade_filer"))

  # Klicka på nedladdningslänken och vänta tills filen finns i mappen.
  # hamta_nedladdning() gör samma sak och väntar dessutom tills filen är klar.
  klicka_via_id(skrap, "#nedladdning", vanta = FALSE)
  for (i in 1:20) {
    if (file.exists(file.path(mapp, "befolkning.csv"))) break
    Sys.sleep(0.5)
  }
  print(list.files(mapp))

  stang_skrapsession(skrap)
  unlink(mapp, recursive = TRUE)
}
