#' Export a DFM into resdtmf
#'
#' This function exports a dfm into the Responsible Document-term Matrix format.
#' @param input_dfm dfm object
#' @param file_path characters, file path of the exported file
#' @param compress logical, compress the json file into a zip file. File extension ".zip" will be added to file_path, if TRUE.
#' @param order logical, preserve the order of input_dfm in the exported file?
#' @importFrom magrittr %>%
#' @return file path of exported file.
#' @export
export_resdtmf <- function(input_dfm, file_path, order = TRUE, compress = FALSE, return_path = FALSE) {
    input_triplet <- quanteda::convert(input_dfm, to = 'tripletlist')
    unique_feature <- unique(input_triplet$feature)
    clean_feature <- match(input_triplet$feature, unique_feature)
    triplet <- tibble::tibble(d = input_triplet$document, tid = clean_feature, f = input_triplet$frequency)
    features <- tibble::tibble(tid = seq_along(unique_feature), term = unique_feature)
    if (length(names(Filter(is.factor, docvars(input_dfm)))) != 0) {
        ## there is factor column(s) in the data.frame
        warning("Factor column(s) detected. These column(s) are preserved as characters without factor information.")
    }
    dumped_docvars <- cbind(tibble::tibble(d = rownames(input_dfm)), quanteda::docvars(input_dfm)) %>% tibble::as_tibble()
    order_of_content <- tibble::tibble(order = seq_along(rownames(input_dfm)), d = rownames(input_dfm))
    json_content <- jsonlite::toJSON(list(triplet = triplet, features = features, dumped_docvars = dumped_docvars, dumped_meta = meta(input_dfm), order_of_content = order_of_content))
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
#' @return a dfm object.
#' @export
import_resdtmf <- function(file_path, compress = FALSE) {
    if (compress | grepl("\\.zip$", file_path)) {
        tmpdir <- tempdir()
        unzip(file_path, exdir = tmpdir)
        file_path <- grep("\\.json$", list.files(tmpdir, full.names = TRUE), value = TRUE)[1]
    }
    json_content <- jsonlite::read_json(file_path, simplifyDataFrame = TRUE)
    triplet <- json_content$triplet
    features <- json_content$features
    dumped_docvars <- json_content$dumped_docvars
    output <- Matrix::sparseMatrix(i = match(triplet$d, unique(triplet$d)), j = triplet$tid, x = triplet$f, dimnames = list(unique(triplet$d), features$term))
    output_dfm <- quanteda::as.dfm(output)
    arranged_meta <- dumped_docvars[match(rownames(output_dfm), dumped_docvars$d), ] %>% dplyr::select(-d)
    quanteda::docvars(output_dfm) <- arranged_meta
    order_of_content <- json_content$order_of_content
    output_dfm <- output_dfm[match(order_of_content$d, rownames(output_dfm)),]
    ### This is a guess!
    meta(output_dfm) <- lapply(json_content$dumped_meta, unlist)
    return(output_dfm)
}
