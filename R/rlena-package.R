#' rlena: working with LENA .its files in R
#'
#' The *Language Environment ANalysis (LENA)* system makes automatic annotations
#' of audio recordings of children's sound environment. Its annotations can
#' be exported as \code{.its} files, that contain an \code{xml} structure.
#' The \code{rlena} package makes it easy to import and work with LENA
#' \code{.its} files in R. It does so by creating and producing tidy data
#' frames for further analysis.
#'
#' @section The \code{.its} file structure:
#' Each \code{.its} file corresponds to one audio file. A single file can
#' contain multiple *recordings*, each of which correspons to one uninterrupted
#' recording.
#' On the lowest level, the annotations are a continuous but non-overlapping
#' sequence of *labels* that indicate different types of speakers or sounds.
#' They labels grouped in larger, non-overlapping blocks of pauses and
#' conversations.
#'
#' @name rlena
#' @docType package
NULL



