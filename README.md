<!-- README.md is generated from README.Rmd. Please edit that file -->
DarcleITS
=========

[![Project Status: Concept - Minimal or no implementation has been done yet.](http://www.repostatus.org/badges/0.1.0/concept.svg)](http://www.repostatus.org/#concept)

An R package for parsing LENA's .ITS files.

Proof of Concept
----------------

There are just two functions at the moment: `load_its_file` which loads the ITS file in R as an XML document and `make_conversation_df` which collects the attributes of every `<Conversation>` node.

``` r
library("DarcleITS")
library("dplyr")
#> 
#> Attaching package: 'dplyr'
#> 
#> The following object is masked from 'package:stats':
#> 
#>     filter
#> 
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
conversations <- "tests/testthat/data/file-for-testing.its" %>% 
  load_its_file %>% 
  make_conversation_df
conversations
#> Source: local data frame [1,985 x 40]
#> 
#>    num  type average_dB peak_dB turnTaking femaleAdultInitiation
#> 1    1 XIOCA     -21.88   -7.73          0                     0
#> 2    2  AICF     -18.99   -8.38          1                     1
#> 3    3  AICF     -21.59   -9.95          2                     1
#> 4    4   CIC     -23.36  -10.99          1                     0
#> 5    5    XM     -33.57  -18.29          0                     0
#> 6    6   CIC     -20.70   -9.36          4                     2
#> 7    7    CM     -18.04   -8.86          0                     0
#> 8    8  AICF     -22.23   -9.33          1                     1
#> 9    9   CIC     -22.82   -8.11          2                     0
#> 10  10  AICF     -28.76   -9.14          1                     1
#> .. ...   ...        ...     ...        ...                   ...
#> Variables not shown: maleAdultInitiation (int), childResponse (int),
#>   childInitiation (int), femaleAdultResponse (int), maleAdultResponse
#>   (int), adultWordCnt (dbl), femaleAdultWordCnt (dbl), maleAdultWordCnt
#>   (dbl), femaleAdultUttCnt (int), maleAdultUttCnt (int), femaleAdultUttLen
#>   (chr), maleAdultUttLen (chr), femaleAdultNonSpeechLen (chr),
#>   maleAdultNonSpeechLen (chr), childUttCnt (int), childUttLen (chr),
#>   childCryVfxLen (chr), TVF (chr), FAN (chr), OLN (chr), SIL (chr), NOF
#>   (chr), CXF (chr), OLF (chr), CHF (chr), MAF (chr), TVN (chr), NON (chr),
#>   CXN (chr), CHN (chr), MAN (chr), FAF (chr), startTime (dbl), endTime
#>   (dbl)
```

Now, we can start mining this data-frame of conversations.

``` r
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

![](README-unnamed-chunk-3-1.png)
