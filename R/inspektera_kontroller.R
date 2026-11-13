#' Kartlägg alla kontroller på den öppna sidan
#'
#' Läser av sidans select-listor (med alla alternativ), klickbara element
#' (länkar, knappar och element som ser klickbara ut) och inmatningsfält
#' (text, kryssrutor, radioknappar och textareor). Används när man bygger ett
#' nytt skrapskript: öppna sidan, kör funktionen och se vilka id:n, värden och
#' texter skriptet ska styra mot. [visa_kontroller()] skriver ut samma
#' uppgifter i läsbar form.
#'
#' Funktionen läser bara huvudsidan, inte innehållet i iframes.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#'
#' @return En lista med tre data frames:
#'   - `selects`: en rad per alternativ, med kolumnerna `select_id`,
#'     `multiple`, `value`, `text` och `selected`.
#'   - `klickbara`: kolumnerna `id`, `tag`, `class`, `href` och `text`.
#'   - `inmatning`: kolumnerna `id`, `typ`, `name`, `value` och `checked`.
#'
#'   Saknar sidan en viss typ av kontroll är motsvarande element en tom lista.
#' @export
#' @example inst/examples/inspektera_kontroller.R
inspektera_kontroller <- function(skrap) {
  if (!inherits(skrap, "skrapsession")) {
    stop("Objektet \u00e4r inte skapat av starta_skrapsession().")
  }
  rlang::check_installed("jsonlite")

  js <- "JSON.stringify({
    selects: [...document.querySelectorAll('select')].flatMap(s =>
      [...s.options].map(o => ({
        select_id: s.id || s.name || '(utan id)',
        multiple: s.multiple,
        value: o.value,
        text: o.text.trim(),
        selected: o.selected
      }))
    ),
    klickbara: [...document.querySelectorAll(
      'a, button, input[type=button], input[type=submit], [onclick], div, span'
    )].filter(e => {
      if (['A','BUTTON','INPUT'].includes(e.tagName)) return true;
      // f\u00f6r div/span/generiska element: bara ta med om de verkar klickbara
      // (cursor: pointer \u00e4r den vanligaste signalen p\u00e5 en icke-semantisk knapp)
      return e.hasAttribute('onclick') || getComputedStyle(e).cursor === 'pointer';
    }).map(e => ({
      id: e.id || '',
      tag: e.tagName.toLowerCase(),
      class: e.className || '',
      href: e.getAttribute('href') || '',
      text: (e.innerText || e.value || '').trim().slice(0, 60)
    })).filter(e => (e.id !== '' || e.href !== '' || e.class !== '') && e.text !== ''),
    inmatning: [...document.querySelectorAll(
      'input[type=text], input[type=checkbox], input[type=radio], textarea'
    )].map(e => ({
      id: e.id || '',
      typ: e.type,
      name: e.name || '',
      value: e.value,
      checked: e.checked
    }))
  })"

  jsonlite::fromJSON(kor_js(skrap, js))
}
