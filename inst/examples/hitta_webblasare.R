# Sökvägen till den webbläsare som starta_skrapsession() kommer att använda,
# eller NULL om ingen Edge eller Chrome hittas
webblasare <- hitta_webblasare()
webblasare

# Miljövariabeln SKRAP_EDGE_PATH går före de vanliga installationsplatserna.
# Sätt den i .Renviron om webbläsaren ligger någon annanstans.
if (!is.null(webblasare)) {
  gammal <- Sys.getenv("SKRAP_EDGE_PATH")
  Sys.setenv(SKRAP_EDGE_PATH = webblasare)
  print(hitta_webblasare())
  Sys.setenv(SKRAP_EDGE_PATH = gammal)
}
