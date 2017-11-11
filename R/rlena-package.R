#' rlena: Make Working with LENA '.its' files easy
#'
#' The \emph{Language Environment ANalysis (LENA)} system makes automatic annotations
#' of audio recordings of children's sound environment. Its annotations can
#' be exported as \code{.its} files, that contain an \code{xml} structure.
#' The \code{rlena} package makes it easy to import and work with LENA
#' \code{.its} files in R. It does so by creating and producing tidy data
#' frames for further analysis.
#'
#' Each \code{.its} file corresponds to one audio file and contains a
#' hierarchical structure of annotations:
#' Short \strong{segments} are labeled by speaker type and grouped into
#' \strong{vocalization activity blocks} (pauses or conversations).
#' These blocks are again grouped into \strong{recordings} (uninterrupted
#' recording sessions).
#'
#' @section Recordings:
#' A single file can contain multiple \strong{recordings}.
#' A recording corresponds to one \emph{uninterrupted} recording session.
#' When the "Pause" button on the recorder is pressed during a LENA
#' recording session, this will create a new recording in the \code{.its} file.
#' The \code{\link{gather_recordings}} function extracts the recording
#' information from the file, including their start time, end time and timezone
#' information.
#'
#' @section Segments:
#' On the lowest level, the annotations that LENA makes are a continuous,
#' non-overlapping sequence of labeled \strong{segments}.
#' Each segment corresponds to a different type of speakers or sound.
#' Each segment has one of 10 labels:
#' \itemize{
#'   \item \code{CHN} - Key Child
#'   \item \code{CXN} - Other Child
#'   \item \code{FAN} - Female Adult
#'   \item \code{MAN} - Male Adult
#'   \item \code{OLN} - Overlapping Vocals
#'   \item \code{TVN} - TV / Electronic Media
#'   \item \code{NON} - Noise
#'   \item \code{SIL} - Silence
#'   \item \code{FUZ} - Uncertain / Fuzzy
#' }
#' The \code{CHN} segments are processed further to provide estimates of the
#' number of child vocalizations.
#' The \code{FAN} and \code{MAN} segments are processed further to
#' provide estimates of the number of adult words.
#' Nonspeech vocalizations and vegetative sounds are excluded from both of
#' these counts.
#'
#' The segments can be obtained with the \code{\link{gather_segments}}
#' function. Among other things, it returns information on the start and end
#' time of each segment, the label, and (if applicable) the estimated number of
#' adult words and child utterances.
#'
#' @section Vocalization Activity Blocks:
#' In the \code{.its} file all segments are grouped into larger, non-overlapping
#' \strong{vocalization activity blocks}. There are two block types: pauses and
#' conversations. Conversations can have different types,
#' depending on which type of speaker initiates the converation and which types
#' of speakers participate:
#'
#' \strong{Blocks initiated by the key child}
#' \itemize{
#'   \item \code{CM} - Key Child Monologue
#'   \item \code{CIC} - Key Child with Adult
#'   \item \code{CIOCX} - Key Child with Other Child
#'   \item \code{CIOCAX} - Key Child with Adult and Other Child
#' }
#' \strong{Blocks initiated by a female adult}
#' \itemize{
#'   \item \code{AMF} - Female Ault Monologue
#'   \item \code{AICF} - Female Adult with Key Child
#'   \item \code{AIOCF} - Female Adult with Other Child
#'   \item \code{AIOCCXF} - Female Adult with Key Child and Other Child
#' }
#' \strong{Blocks initiated by a male adult}
#' \itemize{
#'   \item \code{AMM} - Male Ault Monologue
#'   \item \code{AICM} - Male Adult with Key Child
#'   \item \code{AIOCM} - Male Adult with Other Child
#'   \item \code{AIOCCXM} - Male Adult with Key Child and Other Child
#' }
#' \strong{Blocks initiated by other child}
#' \itemize{
#'   \item \code{XM} - Other Child Monologue
#'   \item \code{XIOCC} - Other Child with Key Child
#'   \item \code{XIOCA} - Other Child with Adult
#'   \item \code{XIC} - Other Child with Key Child and Adult (Turns)
#'   \item \code{XIOCAC} - Other Child with Key Child and Adult (No Turns)
#' }
#'
#' The blocks can be obtained with \code{\link{gather_blocks}}.
#' To get just the pause blocks, one can use \code{\link{gather_pauses}}.
#' The get just the conversation blocks, one can use
#' \code{\link{gather_conversations}}.
#'
#' @section Turn Taking Information:
#' Some segments within Vocalization Activity Blocks have special functions
#' related to turn taking and are marked acordingly.
#' For example, vocalizations in a conversation can be of different types:
#' \itemize{
#'   \item \code{FI} - Floor Initiation (speaker is speaking for the first time
#'   in this block)
#'   \item \code{FH} - Floor Holding (speaker has spoken before)
#' }
#'
#' When the speaker changes from one segment to the other, this will (under
#' certain circumstances) be counted as a \strong{strong} conversational turn.
#' Conversational turns can be of different types, too:
#' \itemize{
#'   \item \code{TIFI/TIMI} - Turn Initiation with Female / Male Adult
#'   \item \code{TIFR/TIMR} - Turn Response with Female / Male Adult
#'   \item \code{TIFE/TIME} - Turn End with Female / Male Adult
#'   \item \code{NT} - Other Child with Key Child and Adult (Turns)
#' }
#'
#' For more information see the "Quick Reference Sheet". It is accessible from
#' the help menu in the ADEX software.
#'
#' @name rlena
#' @docType package
#' @importFrom rlang .data
NULL
