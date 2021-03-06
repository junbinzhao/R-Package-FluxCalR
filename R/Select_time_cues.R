#' @title Select the time cues
#'
#' @description This is a function to manually select and extract the start or the end time of each measurement as time cues by
#' clicking the corresponding start or end measurement points on the interactive graphs generated by the function.
#' The data frame returned from this function can be assigned to the argument \code{df_cue} in the \code{\link{FluxCal}} function.
#' Note that the time cue data frame can also be prepared by the user independent of this function following the format of
#' "_1.csv" and "_2.csv" at https://github.com/junbinzhao/FluxCalR/tree/master/inst/extdata).
#'
#' @param data A dataframe generated by the function \code{\link{LoadLGR}} or \code{\link{LoadOther}}.
#'
#' @param flux A string, either "CO2" (default) or "CH4", indicates that either CO2 or CH4 concentration
#' should be plotted for selecting the time cues.
#'
#' @param cue A string, either "End" (default) or "Start", indicates whether the end or the start time of each measurement is
#' to be selected. "End" is recommended is here, since the end of each measurement is more identifiable, which
#' usually coincides with a sudden drop/rise in the gas concentrations due to the removal of chamber at the end of the measurement.
#'
#' @param spt An integer indicates the number of sections to split the CO2/CH4 time series into when plotting (default: 1).
#' Cutting CO2/CH4 time series into several sections will aid the visualization and selection of the time cues when the dataset
#'  is too long.
#'
#' @param ylim A numeric vector of length 2, giving the y-axis scale range for CO2/CH4 concentrations (ppm).
#' If not specified (default), it will be set based on the CO2/CH4 range of the entire dataset.
#'
#' @param save A string includes output directory and file name (.csv) to export the extracted time cue data frame.
#' Default: a file named "Time_cue.csv" with the extracted time cues will be created under the current work directory.
#' The file created can be loaded and re-used in the flux calculation to get reproducible results.
#' FALSE, do not export the file.
#'
#' @return A data frame that includes two columns:
#' "Num", the number of each measurement;
#' "Start" or "End", the time selected as the start or end of each measurement (HH:MM:SS)
#'
#' @importFrom grDevices dev.new dev.off
#' @importFrom graphics abline axis.POSIXct lines par plot text
#'
#' @examples
#' \dontrun{
#' library(FluxCalR)
#' #### data from LGR
#' # get the directory of the example LGR raw data
#' example_data1 <- system.file("extdata", "Flux_example_1_LGR.txt", package = "FluxCalR")
#' # load the data
#' Flux_lgr <- LoadLGR(example_data1)
#' # select cues
#' Cues <- SelCue(Flux_lgr, save = FALSE)
#' Cues
#' }
#'
#' @export
## function to manually select the time cues --------
SelCue <- function(data,
                   flux = "CO2",
                   cue = "End",
                   spt = 1,
                   ylim = NULL,
                   save = "Time_cue.csv"){
  # argument check
  flux <- match.arg(flux,c("CO2","CH4"))
  cue <- match.arg(cue,c("End","Start"))
  # define the pipe from the package "magrittr"
  `%>%` <- magrittr::`%>%`
  # creating a index for spiliting the window
  nr <- nrow(data) # number of rows
  # add one column as row index, one as time (HH:MM:SS) and one as the flux to be ploted (either "CO2" or "CH4")
  data <- cbind(Row=row(data)[,1],data) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(flux_plot=ifelse(flux=="CO2",X.CO2.d_ppm,X.CH4.d_ppm))

  ######## select the points to separate the measurements
  # define the ylab and ylim
  ylab <- paste0(ifelse(flux=="CO2","CO2","CH4"),
                 " in ppm")
  if (is.null(ylim)){
    ylim <- range(data$flux_plot)
  } else {
    ylim <- ylim
  }

  # define the instructions
  exp1 <- paste0("1. Select time cues by left-clicking on the points at the ",cue," of each measurement;")
  exp2 <- "2. After finishing selecting, click 'Stop -> Stop locator' in the up-left corner of the window (Mac users press 'Esc'.)."

  # plot flux vs time for locating the peaks and valleys
  In <- c() # create a variable as Index
  for (i in 1:spt){
    dev.new(width = 16,height = 10,noRStudioGD=TRUE)
    with(data[c(((i-1)*nr/spt)+1):c(i*nr/spt),],
         plot(Time,flux_plot,
              ylab = ylab,
              main = bquote(atop(.(exp1),.(exp2))), # add instruction
              cex.main=1.5, col.main="blue",
              ylim = ylim, cex = 0.8, xaxt="n"
         ))
    # add time interval ticks
    a <- lubridate::pretty_dates(data$Time[c(((i-1)*nr/spt)+1):c(i*nr/spt)],10)
    # which(minute(data$Time) %in% c(0,15,30,45) & floor(second(data$Time)) %in% c(0,1))
    axis.POSIXct(1, at= a,format = "%H:%M")
    abline(v=a, lty="dotted",col="grey")
    In_t <- with(data[c(((i-1)*nr/spt)+1):c(i*nr/spt),],identify(Time,flux_plot))
    In_t <- In_t + ((i-1)*nr/spt) # get the actual location in the whole dataset
    In <- c(In,In_t)
    dev.off()
  }

  # sort the "In" in ascending order in case of click in the wrong order
  In <- sort(In)
  # create the output data frame
  Time_q <- data.frame(seq(1,length(In)), # number of measurements
                       strftime(data$Time[In],format="%H:%M:%S","UTC")) # the time HMS of the cues
  # name the output file according to the selected critieria
  names(Time_q) <- c("Num",cue)

  # output the time cues if necessary
  if (assertthat::is.string(save)){
    utils::write.csv(Time_q,file = save,row.names = F)
  }
  return(Time_q)
}
