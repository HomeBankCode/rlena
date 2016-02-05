Data from a LENA analysis is dumped inside of the `.its` file (ITS: Interpreted Time Segment). This file is a gigantic xml file, meaning that it stores data in a hierarchical tree. This is an inconvenient format, so let's convert the data into the comparatively simpler YAML format, where everything is a list of key-value pairs.

``` r
knitr::opts_knit$set(root.dir = "../")
knitr::opts_chunk$set(comment = "#>", collapse = TRUE)
```

Here's what the ExportData node in the its file looks like in XML:

``` xml
<ExportData ProductRegistration="555-000000">
    <Child id="X555" EnrollDate="2001-01-01" ChildKey="2130A13191454FB7" DOB="1997-07-01" Gender="X" />
    <Group id="" name="" />
</ExportData>
```

We can use the XML package to parse the its-file into an R list.

``` r
library("XML")
its_lines <- readr::read_lines("./tests/testthat/data/file-for-testing.its")
its_parse <- xmlTreeParse(its_lines) 
its_list <- xmlToList(its_parse)
str(its_list$ExportData)
#> List of 3
#>  $ Child : Named chr [1:5] "X555" "2001-01-01" "2130A13191454FB7" "1997-07-01" ...
#>   ..- attr(*, "names")= chr [1:5] "id" "EnrollDate" "ChildKey" "DOB" ...
#>  $ Group : Named chr [1:2] "" ""
#>   ..- attr(*, "names")= chr [1:2] "id" "name"
#>  $ .attrs: Named chr "555-000000"
#>   ..- attr(*, "names")= chr "ProductRegistration"
```

And then use the yaml package to get the yaml format:

``` r
library("yaml")
cat(as.yaml(its_list$ExportData))
#> Child:
#> - X555
#> - '2001-01-01'
#> - 2130A13191454FB7
#> - '1997-07-01'
#> - X
#> Group:
#> - ''
#> - ''
#> .attrs: 555-000000
```

But we've lost the names of the XML attributes in the sub-lists and in the `.attrs` list. We should convert attributes into lists so every value as a name. I wrote some functions to recursively update the list.

``` r
library("purrr")
source("./R/recurse.R")

# First wrap it up in a list. Next recursively convert items into lists and
# promote the values store in .attrs
export_data <- list(ExportData = its_list$ExportData)
yaml_export <- export_data  %>% 
  descend(promote_attributes) %>% 
  as.yaml
```

Finally, we have all the data for this node in a sensible format.

``` r
yaml_export %>% cat
#> ExportData:
#>   ProductRegistration:
#>   - 555-000000
#>   Child:
#>     id: X555
#>     EnrollDate: '2001-01-01'
#>     ChildKey: 2130A13191454FB7
#>     DOB: '1997-07-01'
#>     Gender: X
#>   Group:
#>     id: ''
#>     name: ''
```

Now we can generalize this approach to other parts of the document.

``` r
ava <- list(AVA = its_list$ProcessingUnit$AVA)
ava %>% 
  descend(promote_attributes) %>% 
  as.yaml %>% 
  cat
#> AVA:
#>   rawScore: '-0.285'
#>   standardScore: '95.727'
#>   estimatedMLU: '3.286'
#>   estimatedDevAge: P43M
#>   vocalizationCnt: ORH
#>   vocalizationLen: ORH
#>   MLV: ORH
```

``` xml
<AVA rawScore="-0.285" standardScore="95.727" estimatedMLU="3.286" estimatedDevAge="P43M" vocalizationCnt="ORH" vocalizationLen="ORH" MLV="ORH" />
```

``` r
hour <- list(Bar = its_list$ProcessingUnit$Bar$BarSummary)
hour %>% 
  descend(promote_attributes) %>% 
  as.yaml %>% 
  cat
#> Bar:
#>   average_dB: '-24.10'
#>   peak_dB: '-7.73'
#>   adultWordCnt: '791.00'
#>   turnTaking: '48'
#>   childUttCnt: '168'
#>   childUttLen: P147.02S
#>   TVF: P197.67S
#>   FAN: P171.01S
#>   OLN: P689.08S
#>   SIL: P10.53S
#>   NOF: P208.94S
#>   CXF: P37.92S
#>   OLF: P422.14S
#>   CHF: P3.00S
#>   MAF: P5.25S
#>   TVN: P533.50S
#>   NON: P106.48S
#>   CXN: P130.32S
#>   CHN: P163.08S
#>   MAN: P19.28S
#>   FAF: P18.80S
#>   totalRecordingTime: P2717.00S
#>   leftBoundaryClockTime: '2000-12-28T13:14:43Z'
#>   rightBoundaryClockTime: '2000-12-28T14:00:00Z'
#>   pauseTime: P0.00S
```

``` xml
<BarSummary average_dB="-24.10" peak_dB="-7.73" adultWordCnt="791.00" turnTaking="48" childUttCnt="168" childUttLen="P147.02S" TVF="P197.67S" FAN="P171.01S" OLN="P689.08S" SIL="P10.53S" NOF="P208.94S" CXF="P37.92S" OLF="P422.14S" CHF="P3.00S" MAF="P5.25S" TVN="P533.50S" NON="P106.48S" CXN="P130.32S" CHN="P163.08S" MAN="P19.28S" FAF="P18.80S" totalRecordingTime="P2717.00S" leftBoundaryClockTime="2000-12-28T13:14:43Z" rightBoundaryClockTime="2000-12-28T14:00:00Z" pauseTime="P0.00S" />
```
