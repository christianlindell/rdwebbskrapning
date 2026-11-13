# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  profil <- skrap$profil_dir

  stang_skrapsession(skrap)

  # Webbläsaren är avslutad och den tillfälliga profilmappen borttagen
  print(skrap$process$is_alive())
  print(dir.exists(profil))
}
