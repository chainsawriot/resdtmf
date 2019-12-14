#' Export a DFM into resdtmf
#'
#' This function exports a dfm into the Responsible Document-term Matrix format.
#' @param input_dfm dfm object
#' @param file_path characters, file path of the exported file
#' @param compress logical, compress the json file into a zip file. File extension ".zip" will be added to file_path, if TRUE.
#' @param order logical, present order of input_dfm?
#' @importFrom magrittr %>%
#' @return file path of exported file.
#' @export
export_resdtmf <- function(input_dfm, file_path, order = TRUE, compress = FALSE, return_path = FALSE) {
    input_triplet <- quanteda::convert(input_dfm, to = 'tripletlist')
    unique_feature <- unique(input_triplet$feature)
    clean_feature <- match(input_triplet$feature, unique_feature)
    triplet <- tibble::tibble(d = input_triplet$document, tid = clean_feature, f = input_triplet$frequency)
    features <- tibble::tibble(tid = seq_along(unique_feature), term = unique_feature)
    metadata <- cbind(tibble::tibble(d = rownames(quanteda::docvars(input_dfm))), quanteda::docvars(input_dfm)) %>% tibble::as_tibble()
    order_content <- tibble::tibble(order = seq_along(rownames(input_dfm)), d = rownames(input_dfm))
    if (!order) {
        json_content <- jsonlite::toJSON(list(triplet, features, metadata))
    } else {
        json_content <- jsonlite::toJSON(list(triplet, features, metadata, order_content))
    }
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
    triplet <- json_content[[1]]
    features <- json_content[[2]]
    metadata <- json_content[[3]]
    output <- Matrix::sparseMatrix(i = match(triplet$d, unique(triplet$d)), j = triplet$tid, x = triplet$f, dimnames = list(unique(triplet$d), features$term))
    output_dfm <- quanteda::as.dfm(output)
    arranged_meta <- metadata[match(rownames(output_dfm), metadata$d), ] %>% dplyr::select(-d)
    quanteda::docvars(output_dfm) <- arranged_meta
    if (length(json_content) == 4) {
        order_content <- json_content[[4]]
        output_dfm <- output_dfm[match(order_content$d, rownames(output_dfm)),]
    }
    return(output_dfm)
}
