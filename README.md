
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rlena

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![R-CMD-check](https://github.com/HomeBankCode/rlena/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/HomeBankCode/rlena/actions/workflows/R-CMD-check.yaml)

## Overview

The rlena package makes it easy to work with LENA `.its` files in R.

The *Language Environment ANalysis (LENA)* system produces automatic
annotations for audio recordings. Its annotations can be exported as
`.its` files, that contain an `xml` structure. The rlena package helps
with importing and preparing `.its` files for further analysis in R.

The `read_its_file()` function takes the path to an `.its` file and
returns an XML object. All other functions work with this object to
extract information. They return tidy data frames that can easily be
manipulated with the usual tools from the tidyverse:

- `gather_recordings()` - Returns all `<Recording>` nodes
- `gather_blocks()` - Returns all `<Conversation>` and `<Pause>` nodes
- `gather_conversations()`- Returns all `<Conversation>` nodes
- `gather_pauses()` - Returns all `<Pause>` nodes
- `gather_segments()` - Returns all `<Segment>` nodes
- `gather_ava_info()` - Returns AVA (Automatic Vocalization Assessment)
  info
- `gather_child_info()` - Returns child info (e.g. birth data, age,
  gender)

:warning: ***Warning:** This package is early work in progress and
subject to potentially code-breaking change.*

## Installation

``` r
install.packages("remotes")
remotes::install_github("HomeBankCode/rlena")
```

## Usage

- Load an `.its` file. For this example we download a file from
  [HomeBankCode/lena-its-tools](https://github.com/HomeBankCode/lena-its-tools).

``` r
library(rlena)
library(dplyr, warn.conflicts = FALSE)

# Download the example ITS file
url <- "https://raw.githubusercontent.com/HomeBankCode/lena-its-tools/master/Example/e20160420_165405_010572.its"
tmp <- tempfile(fileext = ".its")
download.file(url, tmp, mode = "wb")
its <- read_its_file(tmp)
```

- Extract child info and results of the Automatic Vocalization
  Assessment (an index of the child’s language development).

``` r
gather_child_info(its)
#> # A tibble: 1 × 6
#>   itsId                  Birthdate  Gender ChronologicalAge AVAModelAge VCVModelAge
#>   <chr>                  <date>     <chr>  <chr>            <chr>       <chr>
#> 1 20160420_165405_010572 2015-11-19 M      P4M              P4M         P4M

gather_ava_info(its)
#> # A tibble: 1 × 5
#>   itsId                  AVA_Raw AVA_Stnd AVA_EstMLU AVA_EstDevAge
#>   <chr>                    <dbl>    <dbl> <chr>      <chr>
#> 1 20160420_165405_010572   0.715     111. ORL        P5M
```

- Extract the recording information.

``` r
# Each row corresponds to an uninterrupted recording. There is a long pause
# inbetween the two recordings. This means, that the LENA recorder was paused.
recordings <- gather_recordings(its)
recordings
#> # A tibble: 2 × 9
#>   itsId           recId startTime endTime startClockTime      endClockTime        timeZone
#>   <chr>           <dbl>     <dbl>   <dbl> <dttm>              <dttm>              <chr>
#> 1 20160420_16540…     1        0    4037. 2016-04-02 17:20:30 2016-04-02 18:27:47 Etc/GMT…
#> 2 20160420_16540…     2     4037.  22575. 2016-04-02 21:48:07 2016-04-03 02:57:05 Etc/GMT…
#> # ℹ 2 more variables: startClockTimeLocal <dttm>, endClockTimeLocal <dttm>
```

- Extract all conversations.

``` r
# Each row of the returned data frame corresponds to
# one conversation node in the `.its` file. The columns contain the node's
# attributes, such as the number of adult words and child vocalizations.
conversations <- gather_conversations(its)
conversations
#> # A tibble: 655 × 48
#>    itsId               recId blkId blkTypeId blkType startTime endTime startClockTime
#>    <chr>               <dbl> <dbl>     <dbl> <chr>       <dbl>   <dbl> <dttm>
#>  1 20160420_165405_01…     1     2         1 Conver…      12.3    15.8 2016-04-02 17:20:42
#>  2 20160420_165405_01…     1     4         2 Conver…      21.2    27.8 2016-04-02 17:20:51
#>  3 20160420_165405_01…     1     6         3 Conver…      34.2    50.0 2016-04-02 17:21:04
#>  4 20160420_165405_01…     1     8         4 Conver…      71.7    79.8 2016-04-02 17:21:41
#>  5 20160420_165405_01…     1    10         5 Conver…      93.5   101.  2016-04-02 17:22:03
#>  6 20160420_165405_01…     1    12         6 Conver…     111.    124.  2016-04-02 17:22:20
#>  7 20160420_165405_01…     1    14         7 Conver…     132.    140.  2016-04-02 17:22:42
#>  8 20160420_165405_01…     1    16         8 Conver…     151.    162.  2016-04-02 17:23:00
#>  9 20160420_165405_01…     1    18         9 Conver…     177.    192.  2016-04-02 17:23:26
#> 10 20160420_165405_01…     1    20        10 Conver…     198.    199.  2016-04-02 17:23:48
#> # ℹ 645 more rows
#> # ℹ 40 more variables: endClockTime <dttm>, startClockTimeLocal <dttm>,
#> #   endClockTimeLocal <dttm>, type <chr>, average_dB <dbl>, peak_dB <dbl>,
#> #   turnTaking <dbl>, femaleAdultInitiation <dbl>, maleAdultInitiation <dbl>,
#> #   childResponse <dbl>, childInitiation <dbl>, femaleAdultResponse <dbl>,
#> #   maleAdultResponse <dbl>, adultWordCnt <dbl>, femaleAdultWordCnt <dbl>,
#> #   maleAdultWordCnt <dbl>, femaleAdultUttCnt <dbl>, maleAdultUttCnt <dbl>, …
```

- Plot male and female adult word counts.

``` r
library(tidyr)
library(ggplot2)

# Create long data-frame of word counts
word_counts <- conversations %>%
  select(conversation_nr = blkTypeId,
         time = startClockTimeLocal,
         female = femaleAdultWordCnt,
         male = maleAdultWordCnt) %>%
  gather(key = speaker, value = count, female, male) %>%
  filter(count != 0)

# Add acumulated word count
word_counts <- word_counts %>%
  group_by(speaker) %>%
  arrange(conversation_nr) %>%
  mutate(count_acc = cumsum(count))

# Plot word counts per conversations
word_counts %>%
  ggplot(aes(conversation_nr, count, color = speaker)) +
    geom_point() +
    labs(title = "Adult Word Count per Conversation",
         x = "Conversation Number",
         y = "Words")
```

![](man/figures/README-conversation-demo-1.png)<!-- -->

``` r
# Plot accumulating word count over time
word_counts %>%
  ggplot(aes(time, y = count_acc, color = speaker)) +
    geom_rect(data = recordings, inherit.aes = FALSE,
              aes(xmin = startClockTimeLocal, xmax = endClockTimeLocal,
                  ymin=0, ymax = max(word_counts$count_acc), group = recId,
                  fill = "recorder on"), alpha=0.2) +
    scale_fill_manual(NULL, values = 'skyblue')  +
    geom_line() +
    labs(title = "Accumulated Adult Word Count throughout Recording",
         x = "Time",
         y = "Words (Accumulated)")
```

![](man/figures/README-conversation-demo-2.png)<!-- -->

- What happened between 3pm and 4.30pm? We can have a closer look at the
  segments to see what happened.

``` r
library(lubridate)
#>
#> Attaching package: 'lubridate'
#> The following objects are masked from 'package:base':
#>
#>     date, intersect, setdiff, union

# extract segments
segments <- gather_segments(its) %>%
  filter(startClockTimeLocal >= ymd_hms("2016-04-02 15:00:00"),
         startClockTimeLocal <= ymd_hms("2016-04-02 16:30:00"))

segments
#> # A tibble: 837 × 55
#>    itsId   recId blkId blkTypeId segId blkType spkr  startTime endTime startClockTime
#>    <chr>   <dbl> <dbl>     <dbl> <dbl> <chr>   <chr>     <dbl>   <dbl> <dttm>
#>  1 201604…     2   592       297  5842 Pause   CHF       8383.   8383. 2016-04-02 23:00:32
#>  2 201604…     2   592       297  5843 Pause   SIL       8383.   8384. 2016-04-02 23:00:33
#>  3 201604…     2   592       297  5844 Pause   SIL       8384.   8385. 2016-04-02 23:00:34
#>  4 201604…     2   592       297  5845 Pause   SIL       8385.   8386. 2016-04-02 23:00:35
#>  5 201604…     2   592       297  5846 Pause   NOF       8386.   8388. 2016-04-02 23:00:36
#>  6 201604…     2   592       297  5847 Pause   SIL       8388.   8390. 2016-04-02 23:00:37
#>  7 201604…     2   592       297  5848 Pause   TVF       8390.   8392. 2016-04-02 23:00:40
#>  8 201604…     2   592       297  5849 Pause   NOF       8392.   8393. 2016-04-02 23:00:42
#>  9 201604…     2   592       297  5850 Pause   SIL       8393.   8394. 2016-04-02 23:00:42
#> 10 201604…     2   592       297  5851 Pause   NOF       8394.   8395. 2016-04-02 23:00:43
#> # ℹ 827 more rows
#> # ℹ 45 more variables: endClockTime <dttm>, startClockTimeLocal <dttm>,
#> #   endClockTimeLocal <dttm>, average_dB <dbl>, peak_dB <dbl>, recordingInfo <chr>,
#> #   conversationInfo <chr>, convStatus <chr>, convCount <int>, convTurnCount <int>,
#> #   convResponseCount <int>, convType <chr>, convTurnType <chr>, convFloorType <chr>,
#> #   femaleAdultWordCnt <dbl>, femaleAdultNonSpeechLen <dbl>, femaleAdultUttCnt <dbl>,
#> #   femaleAdultUttLen <dbl>, childUttCnt <dbl>, childUttLen <dbl>, startUtt1 <chr>, …
```

``` r
segments %>%
  mutate(duration = endTime - startTime,
         Label = forcats::fct_collapse(
           spkr,
           KeyChild = c("CHN", "CHF"),
           Speech   = c("FAN", "MAN", "CXN", "FAF", "MAF", "CXF"),
           TV       = c("TVN", "TVF"),
           Noise    = c("NOF", "NON", "OLF", "OLN"),
           Silence  = c("SIL")))  %>%
  group_by(Label) %>%
  summarize(duration = sum(duration)) %>%
  ggplot(aes(Label, duration / 60, fill = Label)) +
    geom_col(show.legend = FALSE) +
    labs(title = "The sound Environment between 3pm and 4.30pm",
         y = "Duration (minutes)", x = NULL)
```

![](man/figures/README-segment-demo-1.png)<!-- -->
