## From tm::DublinCore

## contributor: character(0)
## coverage   : character(0)
## creator    : character(0)
## date       : 1987-02-26 17:00:56
## description:
## format     : character(0)
## identifier : 127
## language   : en
## publisher  : character(0)
## relation   : character(0)
## rights     : character(0)
## source     : character(0)
## subject    : character(0)
## title      : DIAMOND SHAMROCK (DIA) CUTS CRUDE PRICES
## type       : character(0)

### From Wikipedia
## Contributor – “An entity responsible for making contributions to the resource.”
## Coverage – “The spatial or temporal topic of the resource, the spatial applicability of the resource, or the jurisdiction under which the resource is relevant.”
## Creator – “An entity primarily responsible for making the resource.”
## Date – “A point or period of time associated with an event in the lifecycle of the resource.”
## Description – “An account of the resource.”
## Format – “The file format, physical medium, or dimensions of the resource.”
## Identifier – “An unambiguous reference to the resource within a given context.”
## Language – “A language of the resource.”
## Publisher – “An entity responsible for making the resource available.”
## Relation – “A related resource.”
## Rights – “Information about rights held in and over the resource.”
## Source – “A related resource from which the described resource is derived.”
## Subject – “The topic of the resource.”
## Title – “A name given to the resource.”
## Type – “The nature or genre of the resource.”

#' @export
create_dc <- function(contributor = NA, coverage = NA, creator = NA, date = NA, description = NA, format = NA, identifier = NA, language = NA, publisher = NA, relation = NA, rights = NA, source = NA, subject = NA, title = NA, type = NA) {
    ## if (all(Map(is.null, contributor, coverage, creator, date, description, format, identifier, language, publisher, relation, rights, source, subject, title, type))) {
    ##     stop("At least one argument must not be NA.")
    ## }
    res <- tibble::tibble(DC.contributor = contributor,
                          DC.coverage = coverage,
                          DC.creator = creator,
                          DC.date = date,
                          DC.description = description,
                          DC.format = format,
                          DC.identifier = identifier,
                          DC.language = language,
                          DC.publisher = publisher,
                          DC.relation = relation,
                          DC.rights = rights,
                          DC.source = source,
                          DC.subject = subject,
                          DC.title = title,
                          DC.type = type
                          )
    return(res)
}

#' @export
put_dc <- function(x, dublin_meta) {
    ## TODO: check for dublin cols
    docvars(x) <- cbind(docvars(x), dublin_meta)
    return(x)
}

.clean_dc_col <- function(dc_meta_vector, i) {
    tools::toTitleCase(stringr::str_replace(names(dc_meta_vector)[i], "^DC\\.", ""))
}

#' @export
inspect_dc <- function(x, format = "display") {
    if (format == "xml") {
        stop("To be developed! Sorry!")
    }
    doc_meta <- docvars(x)
    if (nrow(doc_meta) > 1 & format == "display") {
        warning("inspect_dc with format = 'display' is not useful for x with more than one element. Try format = 'xml' instead")
        print(tibble::as_tibble(doc_meta[, grepl("^DC\\.", colnames(doc_meta))]))
        return(invisible(NULL))
    }
    if (nrow(doc_meta) == 1 & format == "display") {
        dc_meta <- doc_meta[, grepl("^DC\\.", colnames(doc_meta))]
        dc_meta_vector <- as.vector(t(dc_meta))
        names(dc_meta_vector) <- as.vector(colnames(dc_meta))
        for (i in seq_along(dc_meta_vector)) {
            if (!is.na(dc_meta_vector[i])) {
                dc_name <- .clean_dc_col(dc_meta_vector, i)
                cat(paste0(dc_name, ": ", dc_meta_vector[i], "\n"))
            }
        }
        return(invisible(NULL))
    }
}
