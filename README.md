
<!-- README.md is generated from README.Rmd. Please edit that file -->
rlena
=====

[![Project Status: Concept - Minimal or no implementation has been done yet.](http://www.repostatus.org/badges/0.1.0/concept.svg)](http://www.repostatus.org/#concept)

An R package for extracting data from LENA .its files.

Proof of Concept
----------------

There are just a few functions at the moment:

-   `read_its_file()` loads the ITS file in R as an XML document.
-   `gather_ava_info()` extracts the AVA (Automatic Vocalization Assessment) scores into a dataframe.
-   `gather_child_info()` extracts the child information.
-   `gather_conversations()` collects the attributes of every `<Conversation>` node into a dataframe.

``` r
library(rlena)
library(dplyr, warn.conflicts = FALSE)

lena_log <- read_its_file("tests/testthat/data/file-for-testing.its") 
```

Examples of simple information extraction.

``` r
gather_ava_info(lena_log)
#> # A tibble: 1 x 5
#>                  ITSFile AVA_Raw AVA_Stnd AVA_EstMLU AVA_EstDevAge
#>                    <chr>   <dbl>    <dbl>      <dbl>         <chr>
#> 1 20140507_132613_009814  -0.285   95.727      3.286          P43M
gather_child_info(lena_log)
#> # A tibble: 1 x 6
#>                  ITSFile  Birthdate Gender ChronologicalAge AVAModelAge
#>                    <chr>     <date>  <chr>            <chr>       <chr>
#> 1 20140507_132613_009814 2010-07-23      M             P45M        P45M
#> # ... with 1 more variables: VCVModelAge <chr>
```

We can extract a dataframe of conversations and play with the data.

``` r
conversations <- gather_conversations(lena_log)
conversations
#> # A tibble: 1,985 x 41
#>                   ITSFile   num  type average_dB peak_dB turnTaking
#>                     <chr> <int> <chr>      <dbl>   <dbl>      <int>
#>  1 20140507_132613_009814     1 XIOCA     -21.88   -7.73          0
#>  2 20140507_132613_009814     2  AICF     -18.99   -8.38          1
#>  3 20140507_132613_009814     3  AICF     -21.59   -9.95          2
#>  4 20140507_132613_009814     4   CIC     -23.36  -10.99          1
#>  5 20140507_132613_009814     5    XM     -33.57  -18.29          0
#>  6 20140507_132613_009814     6   CIC     -20.70   -9.36          4
#>  7 20140507_132613_009814     7    CM     -18.04   -8.86          0
#>  8 20140507_132613_009814     8  AICF     -22.23   -9.33          1
#>  9 20140507_132613_009814     9   CIC     -22.82   -8.11          2
#> 10 20140507_132613_009814    10  AICF     -28.76   -9.14          1
#> # ... with 1,975 more rows, and 35 more variables:
#> #   femaleAdultInitiation <int>, maleAdultInitiation <int>,
#> #   childResponse <int>, childInitiation <int>, femaleAdultResponse <int>,
#> #   maleAdultResponse <int>, adultWordCnt <dbl>, femaleAdultWordCnt <dbl>,
#> #   maleAdultWordCnt <dbl>, femaleAdultUttCnt <int>,
#> #   maleAdultUttCnt <int>, femaleAdultUttLen <chr>, maleAdultUttLen <chr>,
#> #   femaleAdultNonSpeechLen <chr>, maleAdultNonSpeechLen <chr>,
#> #   childUttCnt <int>, childUttLen <chr>, childCryVfxLen <chr>, TVF <chr>,
#> #   FAN <chr>, OLN <chr>, SIL <chr>, NOF <chr>, CXF <chr>, OLF <chr>,
#> #   CHF <chr>, MAF <chr>, TVN <chr>, NON <chr>, CXN <chr>, CHN <chr>,
#> #   MAN <chr>, FAF <chr>, startTime <dbl>, endTime <dbl>

# Create long data-frame of word counts
library("tidyr")
word_counts <- conversations %>% 
  select(num, Time = startTime, 
         Female = femaleAdultWordCnt, Male = maleAdultWordCnt) %>% 
  gather(Speaker, Count, -num, -Time) %>% 
  filter(Count != 0)

library("ggplot2")
ggplot(word_counts) + 
  aes(x = Time, y = Count, color = Speaker) + 
  geom_point() + 
  ylab("Adult Word Count Per Conversation")
```

![](fig/README-conversation-demo-1.png)
