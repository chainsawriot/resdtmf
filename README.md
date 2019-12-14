
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
```

``` r
export_resdtmf(input_dfm, "example")
```

The DTM exported is stored in 3 files.

``` r
readLines("example_triplet.txt")
#>  [1] "\"d\" \"tid\" \"f\"" "\"text1\" 1 1"       "\"text3\" 1 1"      
#>  [4] "\"text1\" 2 1"       "\"text2\" 2 1"       "\"text1\" 3 1"      
#>  [7] "\"text2\" 3 1"       "\"text3\" 3 1"       "\"text2\" 4 1"      
#> [10] "\"text3\" 5 1"
```

``` r
readLines("example_features.txt")
#> [1] "\"tid\" \"term\"" "1 \"i\""          "2 \"love\""      
#> [4] "3 \"you\""        "4 \"me\""         "5 \"hate\""
```

``` r
readLines("example_metadata.txt")
#> [1] "\"d\" \"sentiment\"" "\"text1\" 1"         "\"text2\" 1"        
#> [4] "\"text3\" 0"
```

It can be imported easily back into R.

``` r
example_dfm <- import_resdtmf("example")
example_dfm
#> Document-feature matrix of: 3 documents, 5 features (40.0% sparse).
#> 3 x 5 sparse Matrix of class "dfm"
#>        features
#> docs    i love you me hate
#>   text1 1    1   1  0    0
#>   text3 1    0   1  0    1
#>   text2 0    1   1  1    0
```

And the metadata is preserved. At the moment, the original order of
documents is not preserved.

``` r
docvars(example_dfm)
#>       sentiment
#> text1         1
#> text3         0
#> text2         1
```
