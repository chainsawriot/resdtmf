#' Export a DFM into resdtmf
#'
#' This function exports a dfm into the Responsible Document-term Matrix format.
#' @param input_dfm dfm object
#' @param file_path characters, file path of the exported file
#' @param compress logical, to compress the 3 files into a zip file (not implemented yet)
#' @importFrom magrittr %>%
#' @export
export_resdtmf <- function(input_dfm, file_path, compress = FALSE) {
    input_triplet <- quanteda::convert(input_dfm, to = 'tripletlist')
    unique_feature <- unique(input_triplet$feature)
    clean_feature <- match(input_triplet$feature, unique_feature)
    triplet <- tibble::tibble(d = input_triplet$document, tid = clean_feature, f = input_triplet$frequency)
    features <- tibble::tibble(tid = seq_along(unique_feature), term = unique_feature)
    metadata <- cbind(tibble::tibble(d = rownames(quanteda::docvars(input_dfm))), quanteda::docvars(input_dfm)) %>% tibble::as_tibble()
    json_content <- jsonlite::toJSON(list(triplet, features, metadata))
    writeLines(json_content, file_path)
}


#' Import resdtmf files into a dfm
#'
#' This function imports resdtmf files exported using export_resdtmf into a dfm object.
#' @param file_path characters, file path of the json file.
#' @export
import_resdtmf <- function(file_path) {
    json_content <- jsonlite::read_json(file_path, simplifyDataFrame = TRUE)
    triplet <- json_content[[1]]
    features <- json_content[[2]]
    metadata <- json_content[[3]]
    output <- Matrix::sparseMatrix(i = match(triplet$d, unique(triplet$d)), j = triplet$tid, x = triplet$f, dimnames = list(unique(triplet$d), features$term))
    output_dfm <- quanteda::as.dfm(output)
    arranged_meta <- metadata[match(metadata$d, unique(triplet$d)), ] %>% dplyr::select(-d)
    quanteda::docvars(output_dfm) <- arranged_meta
    return(output_dfm)
}
