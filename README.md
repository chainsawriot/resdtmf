
<!-- README.md is generated from README.Rmd. Please edit that file -->

# resdtmf

<!-- badges: start -->

<!-- badges: end -->

The goal of resdtmf is to create a machine-readable, plain-text and
exchangable file format of document-term matrices (dtm, or
document-feature matrices).

## Installation

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("chainsawriot/resdtmf")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
require(quanteda)
#> Loading required package: quanteda
#> Package version: 1.5.2
#> Parallel computing: 2 of 4 threads used.
#> See https://quanteda.io for tutorials and examples.
#> 
#> Attaching package: 'quanteda'
#> The following object is masked from 'package:utils':
#> 
#>     View
require(magrittr)
#> Loading required package: magrittr
require(resdtmf)
#> Loading required package: resdtmf

quanteda::corpus(c('i love you', 'you love me', 'i hate you'),
                 docvars = data.frame(sentiment = c(1,1,0))) %>%
    quanteda::dfm() -> input_dfm
input_dfm
#> Document-feature matrix of: 3 documents, 5 features (40.0% sparse).
#> 3 x 5 sparse Matrix of class "dfm"
#>        features
#> docs    i love you me hate
#>   text1 1    1   1  0    0
#>   text2 0    1   1  1    0
#>   text3 1    0   1  0    1
```

``` r
export_resdtmf(input_dfm, "example.json")
#> [1] "example.json"
```

The file is machine-readable.

``` r
readLines("example.json")
#> [1] "[[{\"d\":\"text1\",\"tid\":1,\"f\":1},{\"d\":\"text3\",\"tid\":1,\"f\":1},{\"d\":\"text1\",\"tid\":2,\"f\":1},{\"d\":\"text2\",\"tid\":2,\"f\":1},{\"d\":\"text1\",\"tid\":3,\"f\":1},{\"d\":\"text2\",\"tid\":3,\"f\":1},{\"d\":\"text3\",\"tid\":3,\"f\":1},{\"d\":\"text2\",\"tid\":4,\"f\":1},{\"d\":\"text3\",\"tid\":5,\"f\":1}],[{\"tid\":1,\"term\":\"i\"},{\"tid\":2,\"term\":\"love\"},{\"tid\":3,\"term\":\"you\"},{\"tid\":4,\"term\":\"me\"},{\"tid\":5,\"term\":\"hate\"}],[{\"d\":\"text1\",\"sentiment\":1},{\"d\":\"text2\",\"sentiment\":1},{\"d\":\"text3\",\"sentiment\":0}],[{\"order\":1,\"d\":\"text1\"},{\"order\":2,\"d\":\"text2\"},{\"order\":3,\"d\":\"text3\"}]]"
```

It can be imported easily back into R.

``` r
example_dfm <- import_resdtmf("example.json")
example_dfm
#> Document-feature matrix of: 3 documents, 5 features (40.0% sparse).
#> 3 x 5 sparse Matrix of class "dfm"
#>        features
#> docs    i love you me hate
#>   text1 1    1   1  0    0
#>   text2 0    1   1  1    0
#>   text3 1    0   1  0    1
```

And the metadata is preserved.

``` r
docvars(example_dfm)
#>       sentiment
#> text1         1
#> text2         1
#> text3         0
```

Example: serializing a DTM created using the `data_corpus_inaugural`
data.

``` r
inaugural_dfm <- dfm(data_corpus_inaugural)
export_resdtmf(inaugural_dfm, "inaug_dfm.json")
#> [1] "inaug_dfm.json"
```

``` r
inaugural_dfm_from_json <- import_resdtmf("inaug_dfm.json")
inaugural_dfm_from_json
#> Document-feature matrix of: 58 documents, 9,357 features (91.8% sparse).
```

``` r
all.equal(inaugural_dfm, inaugural_dfm_from_json)
#> [1] TRUE
```

Using compression

``` r
export_resdtmf(inaugural_dfm, "inaug_dfm2.json", compress = TRUE)
#> [1] "inaug_dfm2.json.zip"
file.size("inaug_dfm.json")
#> [1] 1965514
file.size("inaug_dfm2.json.zip")
#> [1] 228407
```

``` r
inaugural_dfm_from_json_zip <- import_resdtmf("inaug_dfm2.json.zip")
all.equal(inaugural_dfm, inaugural_dfm_from_json_zip)
#> [1] TRUE
```
