#' Vänta in en eventuell sidladdning efter ett klick (intern)
#'
#' Förutsätter att en markör (window.__skrapKlickMarkering) planterades pa
#' sidan i samma JavaScript-körning som klicket. Logiken:
#' - Är markören borta har en navigering skett (den nya sidan har den inte)
#'   - vänta tills document.readyState === 'complete'.
#' - Är markören kvar efter respitperioden `grace` skedde ingen navigering
#'   - släpp vidare direkt.
#' - Svarar sidan inte alls (JS-kontexten riven) pagar navigeringen - vänta.
#'
#' Anropas av klicka_via_text(), klicka_via_klass_och_text() och
#' klicka_via_id() när vanta = TRUE.
#'
#' @noRd
vanta_pa_sidladdning <- function(skrap, grace = 0.3, timeout = 30, intervall = 0.1) {
  start <- Sys.time()
  navigering_sedd <- FALSE

  js <- "(function(){
    if (window.__skrapKlickMarkering === true) {
      return document.readyState === 'complete' ? 'KVAR_KLAR' : 'KVAR_LADDAR';
    }
    return document.readyState === 'complete' ? 'NY_KLAR' : 'NY_LADDAR';
  })()"

  repeat {
    status <- tryCatch(kor_js(skrap, js), error = function(e) NULL)
    tid <- as.numeric(difftime(Sys.time(), start, units = "secs"))

    if (is.null(status) || identical(status, "NY_LADDAR")) {
      # JS-kontexten riven eller ny sida under inladdning - navigering pagar
      navigering_sedd <- TRUE
    } else if (identical(status, "NY_KLAR")) {
      # Ny sida fardigladdad
      return(invisible(TRUE))
    } else if (identical(status, "KVAR_KLAR") && !navigering_sedd && tid >= grace) {
      # Markören kvar och ingen navigering setts under respitperioden
      return(invisible(TRUE))
    }
    # KVAR_LADDAR eller inom respitperioden - fortsatt vanta

    if (tid > timeout) {
      stop("Sidan blev inte f\u00e4rdigladdad inom ", timeout, " sekunder efter klicket.")
    }
    Sys.sleep(intervall)
  }
}
