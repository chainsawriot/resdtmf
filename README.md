
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
#> Package version: 2.0.0
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
#> Document-feature matrix of: 3 documents, 5 features (40.0% sparse) and 1 docvar.
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
#> [1] "{\"triplet\":[{\"d\":\"text1\",\"tid\":1,\"f\":1},{\"d\":\"text3\",\"tid\":1,\"f\":1},{\"d\":\"text1\",\"tid\":2,\"f\":1},{\"d\":\"text2\",\"tid\":2,\"f\":1},{\"d\":\"text1\",\"tid\":3,\"f\":1},{\"d\":\"text2\",\"tid\":3,\"f\":1},{\"d\":\"text3\",\"tid\":3,\"f\":1},{\"d\":\"text2\",\"tid\":4,\"f\":1},{\"d\":\"text3\",\"tid\":5,\"f\":1}],\"features\":[{\"tid\":1,\"term\":\"i\"},{\"tid\":2,\"term\":\"love\"},{\"tid\":3,\"term\":\"you\"},{\"tid\":4,\"term\":\"me\"},{\"tid\":5,\"term\":\"hate\"}],\"dumped_docvars\":[{\"d\":\"text1\",\"sentiment\":1},{\"d\":\"text2\",\"sentiment\":1},{\"d\":\"text3\",\"sentiment\":0}],\"dumped_meta\":[],\"order_of_content\":[{\"order\":1,\"d\":\"text1\"},{\"order\":2,\"d\":\"text2\"},{\"order\":3,\"d\":\"text3\"}]}"
```

It can be imported easily back into R.

``` r
example_dfm <- import_resdtmf("example.json")
example_dfm
#> Document-feature matrix of: 3 documents, 5 features (40.0% sparse) and 1 docvar.
#>        features
#> docs    i love you me hate
#>   text1 1    1   1  0    0
#>   text2 0    1   1  1    0
#>   text3 1    0   1  0    1
```

And the metadata is preserved.

``` r
docvars(example_dfm)
#>   sentiment
#> 1         1
#> 2         1
#> 3         0
```

``` r
all.equal(example_dfm, input_dfm)
#> [1] "Attributes: < Component \"docvars\": Component \"docid_\": Attributes: < Component \"levels\": 2 string mismatches > >"
```

Example: serializing a DTM created using the `data_corpus_inaugural`
data.

``` r
inaugural_dfm <- dfm(data_corpus_inaugural)
export_resdtmf(inaugural_dfm, "inaug_dfm.json")
#> Warning in export_resdtmf(inaugural_dfm, "inaug_dfm.json"): Factor
#> column(s) detected. These column(s) are preserved as characters without
#> factor information.
#> [1] "inaug_dfm.json"
```

``` r
inaugural_dfm_from_json <- import_resdtmf("inaug_dfm.json")
inaugural_dfm_from_json
#> Document-feature matrix of: 58 documents, 9,399 features (91.8% sparse) and 4 docvars.
#>                  features
#> docs              fellow-citizens  of the senate and house representatives
#>   1789-Washington               1  71 116      1  48     2               2
#>   1793-Washington               0  11  13      0   2     0               0
#>   1797-Adams                    3 140 163      1 130     0               2
#>   1801-Jefferson                2 104 130      0  81     0               0
#>   1805-Jefferson                0 101 143      0  93     0               0
#>   1809-Madison                  1  69 104      0  43     0               0
#>                  features
#> docs              : among vicissitudes
#>   1789-Washington 1     1            1
#>   1793-Washington 1     0            0
#>   1797-Adams      0     4            0
#>   1801-Jefferson  1     1            0
#>   1805-Jefferson  0     7            0
#>   1809-Madison    0     0            0
#> [ reached max_ndoc ... 52 more documents, reached max_nfeat ... 9,389 more features ]
```

``` r
all.equal(inaugural_dfm, inaugural_dfm_from_json)
#> [1] "Attributes: < Component \"docvars\": Component \"docid_\": Attributes: < Component \"levels\": 30 string mismatches > >"
#> [2] "Attributes: < Component \"docvars\": Component \"Party\": 'current' is not a factor >"
```

Using compression

``` r
export_resdtmf(inaugural_dfm, "inaug_dfm2.json", compress = TRUE)
#> Warning in export_resdtmf(inaugural_dfm, "inaug_dfm2.json", compress
#> = TRUE): Factor column(s) detected. These column(s) are preserved as
#> characters without factor information.
#> [1] "inaug_dfm2.json.zip"
file.size("inaug_dfm.json")
#> [1] 1969816
file.size("inaug_dfm2.json.zip")
#> [1] 229333
```

``` r
inaugural_dfm_from_json_zip <- import_resdtmf("inaug_dfm2.json.zip")
all.equal(inaugural_dfm, inaugural_dfm_from_json_zip)
#> [1] "Attributes: < Component \"docvars\": Component \"docid_\": Attributes: < Component \"levels\": 30 string mismatches > >"
#> [2] "Attributes: < Component \"docvars\": Component \"Party\": 'current' is not a factor >"
```
