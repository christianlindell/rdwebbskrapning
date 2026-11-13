# rdwebbskrapning 0.1.1

## Rättat
* `stang_skrapsession()` stänger nu selenider-sessionen med
  `selenider::close_session()`. Tidigare anropades en funktion som inte finns
  i selenider, men webbläsaren stängdes ändå.
* `hitta()`, `hitta_alla()` och `hitta_via_text()` fungerar nu även när en
  xpath-sökning är den första sökningen efter `selenider::open_url()`.
  Tidigare gav de då felet "Could not find node with given id" eller ett
  element som felaktigt inte syntes, så att man först behövde vänta in ett
  element med en CSS-selektor.
* `hitta_via_text()` klarar texter med apostrof (`'`) och citattecken.
* `valj_option_utan_event()` ger ett begripligt fel om sidan inte svarar,
  t.ex. när den laddas om, i stället för ett fel från `startsWith()`.
* Felmeddelandet i `hamta_nedladdning()` när `trigger` inte är en funktion
  visar nu ett exempel som fungerar (`hitta(skrap, 'button')`).
* Meddelanden och felmeddelanden skrivs med å, ä och ö.

# rdwebbskrapning 0.1.0

* Första versionen som paket. Funktionerna i `func_webbskrapning.R` har
  samlats i paketet med samma namn och argument, och varje funktion har en
  hjälpsida med ett körbart exempel.
* Exemplen och vignetten använder en exempelsida som följer med paketet
  (`inst/extdata/exempelsida.html`).
