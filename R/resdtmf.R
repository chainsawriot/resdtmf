#' Export a DFM into resdtmf
#'
#' This function exports a dfm into the Responsible Document-term Matrix format.
#' @param input_dfm dfm object. Other object types are converted to dfm using \code{quanteda::as.dfm}. Examples of these types are \code{Matrix} (from the Matrix package) and \code{DocumentTermMatrix} (from the tm package).
#' @param file_path characters, file path of the exported file
#' @param compress logical, compress the json file into a zip file. File extension ".zip" will be added to file_path, if TRUE.
#' @param order logical, preserve the order of input_dfm in the exported file?
#' @return file path of exported file.
#' @export
export_resdtmf <- function(input_dfm, file_path, order = TRUE, compress = FALSE, return_path = FALSE) {
    if (!is.dfm(input_dfm)) {
        input_dfm <- as.dfm(input_dfm)
    }
    input_triplets <- quanteda::convert(input_dfm, to = 'tripletlist')
    unique_feature <- unique(input_triplets$feature)
    clean_feature <- match(input_triplets$feature, unique_feature)
    triplets <- tibble::tibble(docid = input_triplets$document, tid = clean_feature, f = input_triplets$frequency)
    features <- tibble::tibble(tid = seq_along(unique_feature), term = unique_feature)
    if (length(names(Filter(is.factor, docvars(input_dfm)))) != 0) {
        ## there is factor column(s) in the data.frame
        warning("Factor column(s) detected. These column(s) are preserved as character without factor information.")
    }
    dumped_docvars <- tibble::as_tibble(cbind(tibble::tibble(docid = rownames(input_dfm)), quanteda::docvars(input_dfm)))
    order_of_content <- tibble::tibble(order = seq_along(rownames(input_dfm)), docid = rownames(input_dfm))
    json_content <- jsonlite::toJSON(list(triplets = triplets, features = features, dumped_docvars = dumped_docvars, dumped_meta = meta(input_dfm), order_of_content = order_of_content))
    writeLines(json_content, file_path)
    if (compress) {
        return_path <- paste0(file_path, ".zip")
        zip(zipfile = return_path, files = file_path)
        file.remove(file_path)
    } else {
        return_path <- file_path
    }
    return(return_path)
}


#' Import a resdtmf file into DFM
#'
#' This function imports a resdtmf file exported using export_resdtmf into a dfm object.
#' @param file_path characters, file path of the resdtmf json file.
#' @param compress boolean, is the file created with export_resdtmf(compress = TRUE)? Will automatically set to TRUE when file_path ends with .zip.
#' @param convert_to characters, convert the imported dfm to another format. Please consult \code{help(quanteda::convert)} for possible options. Some examples are "lda", "stm" and "data.frame"
#' @param ... additional parameters to quanteda::convert.
#' @return a dfm object.
#' @export
import_resdtmf <- function(file_path, compress = FALSE, convert_to = NULL, ...) {
    if (compress | grepl("\\.zip$", file_path)) {
        tmpdir <- tempdir()
        unzip(file_path, exdir = tmpdir)
        file_path <- grep("\\.json$", list.files(tmpdir, full.names = TRUE), value = TRUE)[1]
    }
    json_content <- jsonlite::read_json(file_path, simplifyDataFrame = TRUE)
    triplets <- json_content$triplets
    features <- json_content$features
    dumped_docvars <- json_content$dumped_docvars
    output <- Matrix::sparseMatrix(i = match(triplets$docid, unique(triplets$docid)), j = triplets$tid, x = triplets$f, dimnames = list(unique(triplets$docid), features$term))
    output_dfm <- quanteda::as.dfm(output)
    arranged_meta <- subset(dumped_docvars[match(rownames(output_dfm), dumped_docvars$d), ], select = -c(docid))
    quanteda::docvars(output_dfm) <- arranged_meta
    order_of_content <- json_content$order_of_content
    ### Fixing the order
    output_dfm <- output_dfm[match(order_of_content$docid, rownames(output_dfm)),]
    output_dfm@docvars$docid_ <- factor(output_dfm@docvars$docid_, order_of_content$docid)
    ### This is a guess!
    meta(output_dfm) <- lapply(json_content$dumped_meta, unlist)
    if (!is.null(convert_to)) {
        output_dfm <- quanteda::convert(output_dfm, to = convert_to, ...)
    }
    return(output_dfm)
}
