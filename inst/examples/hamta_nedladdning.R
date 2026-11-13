# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Klicka på nedladdningslänken och vänta tills filen är klar. Filen hamnar
  # i en ny tillfällig mapp. vanta = FALSE eftersom klicket inte laddar om sidan.
  fil <- hamta_nedladdning(
    skrap,
    trigger = function() klicka_via_id(skrap, "#nedladdning", vanta = FALSE)
  )
  print(basename(fil))
  print(utils::read.csv2(fil, encoding = "UTF-8"))

  # Bestäm själv mappen och godta bara csv-filer
  fil <- hamta_nedladdning(
    skrap,
    trigger = function() klicka_via_text(skrap, "Ladda ner data", vanta = FALSE),
    nedladdningsmapp = file.path(tempdir(), "befolkning"),
    monster = "[.]csv$",
    timeout = 20
  )
  print(fil)

  stang_skrapsession(skrap)
}
