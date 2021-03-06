% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Load.R
\name{LoadOther}
\alias{LoadOther}
\title{Load data from other analyzers}
\usage{
LoadOther(
  file,
  time,
  time_format = "mdy_HMS",
  date_ms = NULL,
  CO2 = NULL,
  CH4 = NULL,
  Ta = 25,
  skip = 0,
  sep = ",",
  ...
)
}
\arguments{
\item{file}{A string contains the directory path and file name of the raw data.}

\item{time}{A string indicates column name of the timestamps in the data file.}

\item{time_format}{A string indicates the format of timestamps. Default: "mdy_HMS".
Other format, "dmy_HMS" or "ymd_HMS", can also be taken, depending on the data timestamp from the analyzer.
In case that the date and time are recorded separately, "HMS" can be used here and add the date to the "date_ms" argument.}

\item{date_ms}{A string indicates date of the measurements in the format of \emph{"mm/dd/yyyy"}.
This argument is used only when "HMS" has assigned to the argument \code{time_format}.}

\item{CO2}{A string indicates column name of the CO2 concentrations in the data file. Default: no CO2 is measured.
Note that at least one of \code{CO2} and \code{CH4} argument has to be specified.}

\item{CH4}{A string indicates column name of the CH4 concentrations in the data file. Default: no CH4 is measured.
Note that at least one of \code{CO2} and \code{CH4} argument has to be specified.}

\item{Ta}{A string indicates column name of ambient air temperature in the data file. If not measured, a constant
value can be used. Default: 25 (unit: degree C).}

\item{skip}{A integer indicates rows to be skipped at the beginning of the data file. Default: 0, no rows will be skipped.}

\item{sep}{A string indicates delimiter that separates columns. Default: ",".}

\item{...}{Other arguments used in the function \code{\link[utils]{read.table}}.}
}
\value{
A dataframe with all data in the right format for functions \code{\link{SelCue}} and \code{\link{FluxCal}}.
}
\description{
Function used to load raw data output from other similar analyzers (e.g. LICOR-7810) to be called
in the functions \code{\link{SelCue}} and \code{\link{FluxCal}}. This function extract the data (i.e., CO2 and/or CH4 concentration and ambient
temperature) required to calculate the fluxes and converts the timestamps into POSIXct for further processing.
}
\examples{
library(FluxCalR)
# get the directory of the example data
example_data <- system.file("extdata", "Flux_example_2_other.csv", package = "FluxCalR")
# load the data
Flux <- LoadOther(file = example_data,
                  time = "Date_time",
                  time_format = "mdy_HMS",
                  CO2 = "CO2_PPM",
                  Ta = "Tem_C")

}
