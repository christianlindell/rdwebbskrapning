# rdwebbskrapning

Startar en Chromium-baserad webbläsare (Edge eller Chrome) och styr den från R,
för att hämta data från webbsidor som kräver klick, val i listor eller
nedladdningar. Funktionerna fungerar på datorer med AppLocker och
företagsproxy, och kommer från skriptet `func_webbskrapning.R` i Region
Dalarnas repo [funktioner](https://github.com/Region-Dalarna/funktioner).

## Installation

Kräver R 4.1 eller senare och Microsoft Edge eller Google Chrome.

```r
install.packages("remotes")
remotes::install_local("H:/R/R_claude/rdwebbskrapning", dependencies = TRUE, build_vignettes = TRUE)
```

`build_vignettes = TRUE` gör att vignetten följer med; öppna den med
`vignette("rdwebbskrapning")`.

Paketet hittar Edge eller Chrome själv. Ligger webbläsaren på en ovanlig plats,
spara sökvägen i `.Renviron` (öppna filen med `usethis::edit_r_environ()`):

```
SKRAP_EDGE_PATH=C:/Program Files/Microsoft/Edge/Application/msedge.exe
```

Kör sedan `testa_skrapmiljo()`. Den går igenom förutsättningarna steg för
steg och säger vad som saknas, t.ex. om AppLocker stoppar webbläsaren.

## Kom igång

```r
library(rdwebbskrapning)

skrap <- starta_skrapsession()
selenider::open_url("https://www.exempel.se/statistik", session = skrap$session)

valj_i_lista(skrap, "#ar", "2024")
fil <- hamta_nedladdning(
  skrap,
  trigger = function() klicka_via_text(skrap, "Ladda ner Excel", vanta = FALSE),
  monster = "[.]xlsx$"
)

stang_skrapsession(skrap)
```

Fler exempel finns på varje funktions hjälpsida (`?starta_skrapsession`) och i
vignetten. Exemplen skrapar en exempelsida som följer med paketet, så de kan
köras utan att någon riktig webbplats används.

## Funktioner

| Funktion | Vad den gör | Obligatoriska parametrar |
|---|---|---|
| `testa_skrapmiljo()` | Testa om datorn klarar att köra en skrapsession | – |
| `hitta_webblasare()` | Hitta en installerad webbläsare (Edge eller Chrome) | – |
| `test_internetanslutning()` | Testa internetanslutningen med en riktig HTTP-förfrågan | – |
| `starta_skrapsession()` | Starta en skrapsession i Edge eller Chrome | – |
| `stang_skrapsession()` | Stäng en skrapsession och städa bort allt den skapade | `skrap` |
| `with_skrapsession()` | Kör kod i en skrapsession som stängs automatiskt efteråt | `expr` |
| `inspektera_kontroller()` | Kartlägg alla kontroller på den öppna sidan | `skrap` |
| `visa_kontroller()` | Skriv ut en översikt över sidans kontroller | `skrap` |
| `kor_js()` | Kör JavaScript på sidan och returnera resultatet | `skrap`, `js` |
| `hitta()` | Hitta ett element i en skrapsession | `skrap` |
| `hitta_alla()` | Hitta alla matchande element i en skrapsession | `skrap` |
| `hitta_via_text()` | Hitta ett element via dess synliga text | `skrap`, `text` |
| `klicka_via_text()` | Klicka på ett element via dess synliga text | `skrap`, `text` |
| `klicka_via_klass_och_text()` | Klicka på ett element via CSS-klass och exakt text | `skrap`, `klass`, `text` |
| `klicka_via_id()` | Klicka på ett element via CSS-selektor | `skrap`, `css` |
| `vanta_pa_js()` | Vänta tills ett JavaScript-villkor blir sant | `skrap`, `villkor` |
| `hamta_select_options()` | Läs ut alla alternativ i en select-lista | `skrap`, `css` |
| `hamta_select_varden()` | Läs ut värdena i en select-lista | `skrap`, `css` |
| `valj_i_lista()` | Välj ett alternativ i en select-lista | `skrap`, `css`, `value` |
| `valj_option_utan_event()` | Markera alternativ i en select-lista utan att sidan märker det | `skrap`, `css`, `value` |
| `textruta_inmatning()` | Fyll i text i en textruta | `skrap`, `css`, `text` |
| `hamta_attribut()` | Läs ett attribut från ett element | `skrap`, `css`, `attribut` |
| `hamta_nedladdning()` | Klicka fram en nedladdning och vänta tills filen är klar | `skrap`, `trigger` |
| `stall_in_nedladdningsmapp()` | Ställ in var webbläsaren sparar nedladdade filer | `skrap`, `mapp` |
| `loggning_initiera()` | Skapa en loggfunktion som visar förfluten tid | – |

## Byta från skripten

Ta bort raden

```r
source("https://raw.githubusercontent.com/Region-Dalarna/funktioner/main/func_webbskrapning.R")
```

och lägg till `library(rdwebbskrapning)`. Funktionerna har samma namn,
argument och beteende som i skriptet, förutom rättningarna i
versionshistoriken nedan och dessa skillnader:

- De interna hjälpfunktionerna `bygg_dokument_js()`,
  `kontrollera_iframe_svar()` och `vanta_pa_sidladdning()` syns inte längre.
  De används fortfarande av klick- och listfunktionerna. Behöver ett skript
  anropa dem direkt: `rdwebbskrapning:::vanta_pa_sidladdning()`.
- Paketet kräver R 4.1 eller senare.
- selenider laddas inte åt dig, precis som förut. Använder skriptet t.ex.
  `is_visible` utan `selenider::` behöver det fortfarande `library(selenider)`.

Skriptet `func_webbskrapning.R` finns kvar i repot funktioner. Rättningar som
görs i paketet kommer inte med i skriptet.

## Versionshistorik

### 0.1.1 (2026-11-13)

#### Rättat
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

### 0.1.0 (2026-11-13)

* Första versionen som paket. Funktionerna i `func_webbskrapning.R` har
  samlats i paketet med samma namn och argument, och varje funktion har en
  hjälpsida med ett körbart exempel.
* Exemplen och vignetten använder en exempelsida som följer med paketet
  (`inst/extdata/exempelsida.html`).
