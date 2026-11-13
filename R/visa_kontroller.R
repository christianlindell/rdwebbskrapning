#' Skriv ut en översikt över sidans kontroller
#'
#' Som [inspektera_kontroller()], men skriver ut en lättläst sammanfattning
#' till konsolen: varje select-lista med sina alternativ och alla klickbara
#' element med id, href, klass och text. Har element varken id eller href
#' skriver funktionen också ut ett färdigt anrop till [klicka_via_id()] eller
#' [klicka_via_klass_och_text()] som visar hur de kan klickas.
#'
#' @param skrap Ett objekt skapat av [starta_skrapsession()]. Obligatorisk.
#' @param max_options Högsta antal alternativ som visas per select-lista.
#'   Standard är 10.
#'
#' @return Osynligt samma lista som [inspektera_kontroller()] returnerar.
#' @export
#' @example inst/examples/visa_kontroller.R
visa_kontroller <- function(skrap, max_options = 10) {
  k <- inspektera_kontroller(skrap)

  cat("=== SELECT-LISTOR ===\n")
  if (length(k$selects) && nrow(k$selects)) {
    for (id in unique(k$selects$select_id)) {
      opts <- k$selects[k$selects$select_id == id, ]
      cat(sprintf(
        "#%s (%s, %d alternativ)\n",
        id, if (opts$multiple[1]) "flerval" else "enval", nrow(opts)
      ))
      visa <- utils::head(opts, max_options)
      cat(sprintf("   value=%-12s %s\n", visa$value, visa$text), sep = "")
      if (nrow(opts) > max_options) {
        cat("   ... och", nrow(opts) - max_options, "till\n")
      }
    }
  }

  cat("\n=== KLICKBARA ELEMENT (med id, href eller klass) ===\n")
  if (length(k$klickbara) && nrow(k$klickbara)) {
    med_ankare <- k$klickbara[k$klickbara$id != "" | k$klickbara$href != "" | k$klickbara$class != "", ]
    cat(sprintf("<%s> #%-15s href=%-25s class=%-25s %s\n",
                med_ankare$tag, med_ankare$id, med_ankare$href, med_ankare$class, med_ankare$text), sep = "")

    saknar_id <- sum(med_ankare$id == "" & med_ankare$href != "")
    if (saknar_id > 0) {
      cat(sprintf(
        "\nTips: %d element saknar id men har href. Klicka via CSS-attributselektor, t.ex.\n     klicka_via_id(skrap, \"a[href='%s']\")\n",
        saknar_id, med_ankare$href[med_ankare$id == "" & med_ankare$href != ""][1]
      ))
    }

    saknar_id_och_href <- med_ankare[med_ankare$id == "" & med_ankare$href == "" & med_ankare$class != "", ]
    if (nrow(saknar_id_och_href) > 0) {
      cat(sprintf(
        "\nTips: %d element saknar b\u00e5de id och href, men har en klass (typiskt en div/span-\"knapp\" i en SPA). Klicka via klass + exakt text, t.ex.\n     klicka_via_klass_och_text(skrap, \"%s\", \"%s\", tag = \"%s\")\n",
        nrow(saknar_id_och_href), saknar_id_och_href$class[1], saknar_id_och_href$text[1], saknar_id_och_href$tag[1]
      ))
    }
  }

  invisible(k)
}
