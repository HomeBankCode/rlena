
<!-- README.md is generated from README.Rmd. Please edit that file -->
rlena
=====

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)

Overview
--------

The `rlena` package makes it easy to work with LENA `.its` files in R.

The *Language Environment ANalysis (LENA)* system produces automatic annotations for audio recordings. Its annotations can be exported as `.its` files, that contain an `xml` structure. The `rlena` package helps with importing `.its` files into R and with creating and producing tidy data frames for further analysis.

The `read_its_file()` fuction takes the path to an .its file and returns an XML object.

All other functions work with this object to extract information:

-   `gather_ava_info()` returns the AVA (Automatic Vocalization Assessment).
-   `gather_child_info()` returns child information (e.g. birth data, age, gender).
-   `gather_conversations()` returns the content of all `<Conversation>` nodes.

All three functions return tidy data frames that can be manipulated with the usual tools from the tidyverse.

***Warning:** Please be aware that this package is early work in progress and subject to potentially code-breaking change.*

Installation
------------

``` r
# rlena is not (yet) available on CRAN. 
# You can install the developmental version from GitHub:

# install.packages("devtools")
devtools::install_github("HomeBankCode/rlena")
```

Usage
-----

Load an `.its` file

``` r
library(rlena)
library(dplyr, warn.conflicts = FALSE)

# Loading an example .its file
its_file <- system.file('extdata', 'example.its', package = 'rlena')
its <- read_its_file(its_file) 
```

Extract child info and results of the Automatic Vocalization Assessment (an index of the child's language development).

``` r
gather_child_info(its)
#> # A tibble: 1 x 6
#>   ITSFile  Birthdate Gender ChronologicalAge AVAModelAge VCVModelAge
#>     <chr>     <date>  <chr>            <chr>       <chr>       <chr>
#> 1    test 2015-01-01      M             P21M        P21M        P21M
gather_ava_info(its)
#> # A tibble: 1 x 5
#>   ITSFile AVA_Raw AVA_Stnd AVA_EstMLU AVA_EstDevAge
#>     <chr>   <dbl>    <dbl>      <dbl>         <chr>
#> 1    test  -0.805   87.923      1.286          P18M
```

Extract all conversations. Each row of the returned data frame corresponds to one converstion node in the `.its` file. The columns contain the node's attributes, such as the number of adult words and child vocalizations.

``` r
conversations <- gather_conversations(its)
conversations
#> # A tibble: 147 x 41
#>    ITSFile   num  type average_dB peak_dB turnTaking femaleAdultInitiation
#>      <chr> <int> <chr>      <dbl>   <dbl>      <int>                 <int>
#>  1    test     1  AICF     -16.00   -3.11          1                     1
#>  2    test     2    XM     -39.26  -26.90          0                     0
#>  3    test     3   CIC     -20.48   -6.03          1                     0
#>  4    test     4   AMF     -27.13   -6.74          0                     0
#>  5    test     5 XIOCC     -23.72   -7.70          0                     0
#>  6    test     6 CIOCX     -20.85   -5.46          0                     0
#>  7    test     7    CM     -25.66  -21.56          0                     0
#>  8    test     8   XIC     -18.28   -5.22          1                     0
#>  9    test     9 CIOCX     -19.23   -3.18          0                     0
#> 10    test    10  AICM     -14.63   -3.26          1                     0
#> # ... with 137 more rows, and 34 more variables:
#> #   maleAdultInitiation <int>, childResponse <int>, childInitiation <int>,
#> #   femaleAdultResponse <int>, maleAdultResponse <int>,
#> #   adultWordCnt <dbl>, femaleAdultWordCnt <dbl>, maleAdultWordCnt <dbl>,
#> #   femaleAdultUttCnt <int>, maleAdultUttCnt <int>,
#> #   femaleAdultUttLen <chr>, maleAdultUttLen <chr>,
#> #   femaleAdultNonSpeechLen <chr>, maleAdultNonSpeechLen <chr>,
#> #   childUttCnt <int>, childUttLen <chr>, childCryVfxLen <chr>, TVF <chr>,
#> #   FAN <chr>, OLN <chr>, SIL <chr>, NOF <chr>, CXF <chr>, OLF <chr>,
#> #   CHF <chr>, MAF <chr>, TVN <chr>, NON <chr>, CXN <chr>, CHN <chr>,
#> #   MAN <chr>, FAF <chr>, startTime <dbl>, endTime <dbl>
```

Plot male and female adult word counts.

``` r
library("tidyr")

# Create long data-frame of word counts
word_counts <- conversations %>% 
  select(conversation_nr = num,
         time = startTime,
         female = femaleAdultWordCnt, 
         male = maleAdultWordCnt) %>% 
  gather(key = speaker, value = count, female, male) %>% 
  filter(count != 0)

# Add acumulated word count
word_counts <- word_counts %>%
  group_by(speaker) %>% 
  arrange(conversation_nr) %>%
  mutate(count_acc = cumsum(count))

library("ggplot2")
word_counts %>%
  ggplot(aes(time, count, color = speaker)) + 
    geom_point() + 
    labs(title = "Adult Word Count per Conversation",
         x = "Time (sec since start of recording)",
         y = "Words")
```

![](fig/README-conversation-demo-1.png)

``` r
  
  ggplot(word_counts) + 
    aes(time, y = count_acc, color = speaker) + 
    geom_line() + 
    labs(title = "Accumulated Adult Word Count throughout Recording",
         x = "Time (sec since start of recording)",
         y = "Words (Accumulated)")
```

![](fig/README-conversation-demo-2.png)
