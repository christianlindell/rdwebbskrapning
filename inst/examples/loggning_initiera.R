# Skapa en loggfunktion och använd den i ett skript
logg <- loggning_initiera()
logg("Startar skrapningen")
Sys.sleep(0.2)
logg("Klar med första steget")

# Med en egen starttid, t.ex. när skriptet började
start <- Sys.time() - 5
logg <- loggning_initiera(tid_start = start)
logg("Har kört i drygt fem sekunder")

# verbose = FALSE stänger av all loggning utan att ändra resten av skriptet
logg <- loggning_initiera(verbose = FALSE)
logg("Det här skrivs inte ut")
