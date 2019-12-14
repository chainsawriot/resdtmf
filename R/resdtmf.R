#' Export a DFM into resdtmf
#'
#' This function exports a dfm into the Responsible Document-term Matrix format.
#' @param input_dfm dfm object
#' @param file_prefix characters, file prefix of the 3 exported files
#' @param compress logical, to compress the 3 files into a zip file
#' @importFrom magrittr %>%
#' @export
export_resdtmf <- function(input_dfm, file_prefix, compress = FALSE) {
    input_triplet <- quanteda::convert(input_dfm, to = 'tripletlist')
    unique_feature <- unique(input_triplet$feature)
    clean_feature <- match(input_triplet$feature, unique_feature)
    tibble::tibble(d = input_triplet$document, tid = clean_feature, f = input_triplet$frequency) %>% write.table(file = paste0(file_prefix, "_triplet.txt"), row.names = FALSE)
    tibble::tibble(tid = seq_along(unique_feature), term = unique_feature) %>% write.table(file = paste0(file_prefix, "_features.txt"), row.names = FALSE)
    cbind(tibble::tibble(d = rownames(quanteda::docvars(input_dfm))), quanteda::docvars(input_dfm)) %>% write.table(file = paste0(file_prefix, "_metadata.txt"), row.names = FALSE)
    if (compress) {
        files <- c(paste0(file_prefix, "_triplet.txt"), paste0(file_prefix, "_features.txt"), paste0(file_prefix, "_metadata.txt"))
        zip(zipfile = paste0(file_prefix, ".resdtmf"), files = files)
        file.remove(files)
    }
}


#' Import resdtmf files into a dfm
#'
#' This function imports resdtmf files exported using export_resdtmf into a dfm object.
#' @param file_prefix characters, file prefix of the 3 exported files
#' @export
import_resdtmf <- function(file_prefix) {
    triplet <- read.table(paste0(file_prefix, "_triplet.txt"), header = TRUE)
    features <- read.table(paste0(file_prefix, "_features.txt"), header = TRUE)
    metadata <- read.table(paste0(file_prefix, "_metadata.txt"), header = TRUE)
    output <- Matrix::sparseMatrix(i = match(triplet$d, unique(triplet$d)), j = triplet$tid, x = triplet$f, dimnames = list(unique(triplet$d), features$term))
    output_dfm <- quanteda::as.dfm(output)
    arranged_meta <- metadata[match(metadata$d, unique(triplet$d)), ] %>% dplyr::select(-d)
    quanteda::docvars(output_dfm) <- arranged_meta
    return(output_dfm)
}
