% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/SSBtoolsData.R
\name{SSBtoolsData}
\alias{SSBtoolsData}
\title{Function that returns a dataset}
\usage{
SSBtoolsData(dataset)
}
\arguments{
\item{dataset}{Name of data set within the SSBtools package}
}
\value{
data frame
}
\description{
Function that returns a dataset
}
\details{
\strong{FIFA2018ABCD:} A hierarchy table based on
countries within groups A-D in the football championship, 2018 FIFA World Cup.

\strong{sprt_emp:} Employment in sport in thousand persons. Data from Eurostat database.

\strong{sprt_emp_geoHier:}  Country hierarchy for the employment in sport data.

\strong{sprt_emp_ageHier:}  Age hierarchy for the employment in sport data.

\strong{sprt_emp_withEU:} The data set sprt_emp extended with a EU variable.

\strong{sp_emp_withEU:} As \code{sprt_emp_withEU}, but coded differently.

\strong{example1} Example data similar to \code{sp_emp_withEU}.

\strong{magnitude1:} Example data for magnitude tabulation. Same countries as above.

\strong{my_km2:} Fictitious grid data.

\strong{mun_accidents:} Fictitious traffic accident by municipality data.

\strong{sosialFiktiv, z1, z1w, z2, z2w, z3, z3w, z3wb:} See \code{\link{sosialFiktiv}}.

\strong{d4, d1, d1w, d2, d2w, d3, d3w, d3wb:} English translation of the datasets above.

\strong{d2s, d2ws:} \code{d2} and \code{d2w} modified to smaller/easier data.

\strong{power10to1, power10to2, \eqn{\ldots}:} \code{power10to}\eqn{i} is hierarchical data with \eqn{10^i} rows and \eqn{2*i} columns.
Tip: Try \code{FindDimLists(SSBtoolsData("power10to3"))}
}
\examples{
SSBtoolsData("FIFA2018ABCD")
SSBtoolsData("sprt_emp")
SSBtoolsData("sprt_emp_geoHier")
SSBtoolsData("sprt_emp_ageHier")
SSBtoolsData("sprt_emp_withEU")
SSBtoolsData("d1w")
}
\author{
Øyvind Langsrud and Daniel Lupp
}
