
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

quanteda::corpus(c('i love you', 'you love me', 'i hate you'), docvars = data.frame(sentiment = c(1,1,0))) %>% quanteda::dfm() -> input_dfm
```

``` r
export_resdtmf(input_dfm, "example")
```

``` r
import_resdtmf("example")
#> Document-feature matrix of: 3 documents, 5 features (40.0% sparse).
#> 3 x 5 sparse Matrix of class "dfm"
#>        features
#> docs    i love you me hate
#>   text1 1    1   1  0    0
#>   text3 1    0   1  0    1
#>   text2 0    1   1  1    0
```
