# Testa mot standardadressen (raw.githubusercontent.com)
test_internetanslutning()

# Testa mot en annan adress med kortare väntetid
test_internetanslutning("https://www.scb.se", timeout_sek = 2)
