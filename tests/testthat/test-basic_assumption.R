context("basic assumption")

require(quanteda)
require(magrittr)

test_that("simplest example", {
    quanteda::corpus(c('i love you', 'you love me', 'i hate you'),
                 docvars = data.frame(sentiment = c(1,1,0))) -> input_corpus
    quanteda::dfm(input_corpus) -> input_dfm
    export_resdtmf(input_dfm, "example.json")
    example_dfm <- import_resdtmf("example.json")
    unlink("example.json")
    expect_equal(input_dfm, example_dfm)
})

test_that("complicated example", {
    inaugural_dfm <- dfm(data_corpus_inaugural)
    docvars(inaugural_dfm, "Party") <- as.character(docvars(inaugural_dfm, "Party"))
    export_resdtmf(inaugural_dfm, "inaug_dfm.json")
    recon_dfm <- import_resdtmf("inaug_dfm.json")
    unlink("inaug_dfm.json")
    expect_equal(inaugural_dfm, recon_dfm)
})
