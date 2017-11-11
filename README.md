
<!-- README.md is generated from README.Rmd. Please edit that file -->
rlena
=====

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip) [![Build Status](https://travis-ci.org/Teebusch/rlena.svg?branch=master)](https://travis-ci.org/Teebusch/rlena) [![Coverage Status](https://coveralls.io/repos/github/Teebusch/rlena/badge.svg?branch=master)](https://coveralls.io/github/Teebusch/rlena?branch=master)

Overview
--------

The rlena package makes it easy to work with LENA `.its` files in R.

The *Language Environment ANalysis (LENA)* system produces automatic annotations for audio recordings. Its annotations can be exported as `.its` files, that contain an `xml` structure. The rlena package helps with importing and preparing `.its` files for further anlysis in R.

The `read_its_file()` fuction takes the path to an `.its` file and returns an XML object. All other functions work with this object to extract information. They return tidy data frames that can easily be manipulated with the usual tools from the tidyverse:

-   `gather_recordings()` - Returns all `<Recording>` nodes
-   `gather_blocks()` - Returns all `<Conversation>` and `<Pause>` nodes
-   `gather_conversations()`- Returns all `<Conversation>` nodes
-   `gather_pauses()` - Returns all `<Pause>` nodes
-   `gather_segments()` - Returns all `<Segment>` nodes
-   `gather_ava_info()` - Returns AVA (Automatic Vocalization Assessment) info
-   `gather_child_info()` - Returns child info (e.g. birth data, age, gender)

:warning: ***Warning:** This package is early work in progress and subject to potentially code-breaking change.*

Installation
------------

``` r
# rlena is not (yet) available on CRAN, but you can install the developmental 
# version from GitHub (requires devtools):
if(!require(devtools) install.packages("devtools")
devtools::install_github("HomeBankCode/rlena", dependencies = TRUE)
```

Usage
-----

-   Load an `.its` file. For this example we download a file from [HomeBankCode/lena-its-tools](https://github.com/HomeBankCode/lena-its-tools).

``` r
library(rlena)
library(dplyr, warn.conflicts = FALSE)

# Download the example ITS file
url <- "https://cdn.rawgit.com/HomeBankCode/lena-its-tools/master/Example/e20160420_165405_010572.its"
tmp <- tempfile()
download.file(url, tmp)
its <- read_its_file(tmp)
```

-   Extract child info and results of the Automatic Vocalization Assessment (an index of the child's language development).

``` r
gather_child_info(its)
#> # A tibble: 1 x 6
#>                    itsId  Birthdate Gender ChronologicalAge AVAModelAge
#>                    <chr>     <date>  <chr>            <chr>       <chr>
#> 1 20160420_165405_010572 2015-11-19      M              P4M         P4M
#> # ... with 1 more variables: VCVModelAge <chr>
gather_ava_info(its)
#> # A tibble: 1 x 5
#>                    itsId AVA_Raw AVA_Stnd AVA_EstMLU AVA_EstDevAge
#>                    <chr>   <dbl>    <dbl>      <chr>         <chr>
#> 1 20160420_165405_010572   0.715  110.724        ORL           P5M
```

-   Extract all conversations. Each row of the returned data frame corresponds to one conversation node in the `.its` file. The columns contain the node's attributes, such as the number of adult words and child vocalizations.

``` r
conversations <- gather_conversations(its)
conversations
#> # A tibble: 655 x 48
#>    recId blkId blkTypeId      blkType startTime endTime
#>    <int> <int>     <int>        <chr>     <dbl>   <dbl>
#>  1     1     2         1 Conversation     12.27   15.81
#>  2     1     4         2 Conversation     21.18   27.82
#>  3     1     6         3 Conversation     34.20   49.98
#>  4     1     8         4 Conversation     71.69   79.84
#>  5     1    10         5 Conversation     93.53  100.85
#>  6     1    12         6 Conversation    110.91  124.47
#>  7     1    14         7 Conversation    132.32  139.73
#>  8     1    16         8 Conversation    150.82  161.87
#>  9     1    18         9 Conversation    176.87  192.18
#> 10     1    20        10 Conversation    198.31  199.25
#> # ... with 645 more rows, and 42 more variables: startClockTime <dttm>,
#> #   endClockTime <dttm>, startClockTimeLocal <dttm>,
#> #   endClockTimeLocal <dttm>, itsId <chr>, type <chr>, average_dB <dbl>,
#> #   peak_dB <dbl>, turnTaking <int>, femaleAdultInitiation <int>,
#> #   maleAdultInitiation <int>, childResponse <int>, childInitiation <int>,
#> #   femaleAdultResponse <int>, maleAdultResponse <int>,
#> #   adultWordCnt <dbl>, femaleAdultWordCnt <dbl>, maleAdultWordCnt <dbl>,
#> #   femaleAdultUttCnt <int>, maleAdultUttCnt <int>,
#> #   femaleAdultUttLen <dbl>, maleAdultUttLen <dbl>,
#> #   femaleAdultNonSpeechLen <dbl>, maleAdultNonSpeechLen <dbl>,
#> #   childUttCnt <int>, childUttLen <dbl>, childCryVfxLen <dbl>, TVF <dbl>,
#> #   FAN <dbl>, OLN <dbl>, SIL <dbl>, NOF <dbl>, CXF <dbl>, OLF <dbl>,
#> #   CHF <dbl>, MAF <dbl>, TVN <dbl>, NON <dbl>, CXN <dbl>, CHN <dbl>,
#> #   MAN <dbl>, FAF <dbl>
```

-   Plot male and female adult word counts.

``` r
library(tidyr)

# Create long data-frame of word counts
word_counts <- conversations %>% 
  select(conversation_nr = blkTypeId,
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

library(ggplot2)
word_counts %>%
  ggplot(aes(time, count, color = speaker)) + 
    geom_point() + 
    labs(title = "Adult Word Count per Conversation",
         x = "Time (sec since start of recording)",
         y = "Words")
```

![](man/figures/README-conversation-demo-1.png)

``` r

word_counts %>%
  ggplot(aes(time, y = count_acc, color = speaker)) + 
    geom_line() + 
    labs(title = "Accumulated Adult Word Count throughout Recording",
         x = "Time (sec since start of recording)",
         y = "Words (Accumulated)")
```

![](man/figures/README-conversation-demo-2.png)
