# Kräver Edge eller Chrome och internetanslutning
if (!is.null(hitta_webblasare()) && test_internetanslutning()) {
  skrap <- starta_skrapsession()
  sida <- system.file("extdata", "exempelsida.html", package = "rdwebbskrapning")
  selenider::open_url(paste0("file:///", sida), session = skrap$session)

  # Hitta rubriken med en CSS-selektor och läs dess text
  rubrik <- hitta(skrap, "h1")
  print(selenider::elem_text(rubrik))

  # Vänta tills listan med år syns innan skriptet går vidare. Villkoret
  # skrivs som en funktion när selenider inte är laddat med library().
  hitta(skrap, "#ar") |>
    selenider::elem_expect(function(x) selenider::is_visible(x), timeout = 10)

  # Hitta ett element med xpath och klicka på det
  hitta(skrap, xpath = "//button[@id='visa']") |> selenider::elem_click()

  stang_skrapsession(skrap)
}
