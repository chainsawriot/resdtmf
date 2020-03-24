context("Converting")

require(quanteda)
require(magrittr)

test_that("converting the result", {
    quanteda::corpus(c('i love you', 'you love me', 'i hate you'),
                 docvars = data.frame(sentiment = c(1,1,0))) -> input_corpus
    quanteda::dfm(input_corpus) -> input_dfm
    export_resdtmf(input_dfm, "example.json")
    example_dfm <- import_resdtmf("example.json", convert_to = "data.frame")
    expect_is(example_dfm, "data.frame")
    expect_error(import_resdtmf("example.json", convert_to = "whatever"))
    unlink("example.json")
})

test_that("Coercing the input", {
    require(topicmodels)
    data("AssociatedPress")
    expect_error(export_resdtmf(AssociatedPress, "ap_test.json"), NA)
    unlink("ap_test.json")
})
