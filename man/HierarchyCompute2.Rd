% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/HierarchyCompute2.R
\name{HierarchyCompute2}
\alias{HierarchyCompute2}
\title{Extended Hierarchical Computations}
\usage{
HierarchyCompute2(
  data,
  hierarchies,
  valueVar,
  colVar,
  rowSelect = NULL,
  colSelect = NULL,
  select = NULL,
  output = "data.frame",
  ...
)
}
\arguments{
\item{data}{The input data frame}

\item{hierarchies}{A named list with hierarchies}

\item{valueVar}{Name of the variable(s) to be aggregated}

\item{colVar}{Name of the column variable(s)}

\item{rowSelect}{Data frame specifying variable combinations for output}

\item{colSelect}{Data frame specifying variable combinations for output}

\item{select}{Data frame specifying variable combinations for output}

\item{output}{One of "data.frame" (default), "outputMatrix", "matrixComponents".}

\item{...}{Further parameters sent to \code{\link{HierarchyCompute}}}
}
\value{
As specified by the parameter \code{output}
}
\description{
Extended variant of \code{\link{HierarchyCompute}} with several column variables (not just \code{"colFactor"}).
Parameter colVar splits the hierarchy variables in two groups and this variable overrides the difference between \code{"rowFactor"} and \code{"colFactor"}.
}
\details{
Within this function, \code{HierarchyCompute} is called two times.
By specifying output as \code{"matrixComponents"},
output from the two runs are retuned as a list with elements \code{hcRow} and \code{hcCol}.
The matrix multiplication in HierarchyCompute is extended to
\code{outputMatrix} \code{=} \code{hcRow$dataDummyHierarchy}
\code{\%*\%} \code{hcRow$valueMatrix}
\code{\%*\%} \code{t(hcCol$dataDummyHierarchy)}.
This is modified in cases with more than a single \code{valueVar}.
}
\note{
There is no need to call \code{HierarchyCompute2} directly.
The main function \code{\link{HierarchyCompute}}  can be used instead.
}
\examples{
x <- SSBtoolsData("sprt_emp")
geoHier <- SSBtoolsData("sprt_emp_geoHier")
ageHier <- SSBtoolsData("sprt_emp_ageHier")

HierarchyCompute(x, list(age = ageHier, geo = geoHier, year = "rowFactor"), "ths_per", 
                 colVar = c("age", "year"))
HierarchyCompute(x, list(age = ageHier, geo = geoHier, year = "rowFactor"), "ths_per",
                 colVar = c("age", "geo"))
HierarchyCompute(x, list(age = ageHier, geo = geoHier, year = "rowFactor"), "ths_per", 
                 colVar = c("age", "year"), output = "matrixComponents")
HierarchyCompute(x, list(age = ageHier, geo = geoHier, year = "rowFactor"), "ths_per", 
                 colVar = c("age", "geo"), output = "matrixComponents")

}
\seealso{
\code{\link{Hierarchies2ModelMatrix}}, \code{\link{AutoHierarchies}}.
}
\author{
Øyvind Langsrud
}
