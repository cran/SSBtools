% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dummy_aggregate.R
\name{dummy_aggregate}
\alias{dummy_aggregate}
\title{\code{aggregate_multiple_fun} using a dummy matrix}
\usage{
dummy_aggregate(
  data,
  x,
  vars,
  fun = NULL,
  dummy = TRUE,
  when_non_dummy = warning,
  keep_names = TRUE,
  ...
)
}
\arguments{
\item{data}{A data frame containing data to be aggregated}

\item{x}{A (sparse) dummy matrix}

\item{vars}{A named vector or list of variable names in \code{data}. The elements are named by the names of \code{fun}.
All the pairs of variable names and function names thus define all the result variables to be generated.
\itemize{
\item Parameter \code{vars} will converted to an internal standard by the function \code{\link{fix_vars_amf}}.
Thus, function names and also output variable names can be coded in different ways.
Multiple output variable names can be coded using \code{multi_sep}.
See examples and examples in \code{\link{fix_vars_amf}}. Indices instead of variable names are allowed.
\item Omission of (some) names is possible since names can be omitted for one function (see \code{fun} below).
\item A special possible feature is the combination of a single unnamed variable and all functions named.
In this case, all functions are run and output variable names will be identical to the function names.
}}

\item{fun}{A named list of functions. These names will be used as suffixes in output variable names. Name can be omitted for one function.
A vector of function as strings is also possible. When unnamed, these function names will be used directly.
See the examples of \code{\link{fix_fun_amf}}, which is the function used to convert \code{fun}.
Without specifying \code{fun}, the functions, as strings, are taken from the function names coded in \code{vars}.}

\item{dummy}{When \code{TRUE}, only 0s and 1s are assumed in \code{x}.
When \code{FALSE}, non-0s in \code{x} are passed as an additional first input parameter to the \code{fun} functions.
Thus, the same result as matrix multiplication is achieved with \code{fun = function(x, y) sum(x * y)}.
In this case, the data will not be subjected to \code{unlist}. See \code{\link{aggregate_multiple_fun}}.}

\item{when_non_dummy}{Function to be called when \code{dummy} is \code{TRUE} and when \code{x} is non-dummy.  Supply \code{NULL} to do nothing.}

\item{keep_names}{When \code{TRUE}, output row names are inherited from column names in \code{x}.}

\item{...}{Further arguments passed to \code{aggregate_multiple_fun}}
}
\value{
data frame
}
\description{
Wrapper to \code{\link{aggregate_multiple_fun}}
that uses a dummy matrix instead of the \code{by} parameter.
Functionality for non-dummy  matrices as well.
}
\details{
Internally this function make use of the \code{ind} parameter to \code{aggregate_multiple_fun}
}
\examples{

# Code that generates output similar to the 
# last example in aggregate_multiple_fun

d2 <- SSBtoolsData("d2")
set.seed(12)
d2$y <- round(rnorm(nrow(d2)), 2)
d <- d2[sample.int(nrow(d2), size = 20), ]

x <- ModelMatrix(d, formula = ~main_income:k_group - 1)

# with specified output variable names
my_range <- function(x) c(min = min(x), max = max(x))
dummy_aggregate(
   data = d, 
   x = x, 
   vars = list("freq", "y", 
               `freqmin,freqmax` = list(ra = "freq"), 
                yWmean  = list(wmean  = c("y", "freq"))),
   fun = c(sum, ra = my_range, wmean = weighted.mean))


# Make a non-dummy matrix 
x2 <- x
x2[17, 2:5] <- c(-1, 3, 0, 10)
x2[, 4] <- 0

# Now warning 
# Result is not same as t(x2) \%*\% d[["freq"]]
dummy_aggregate(data = d, x = x2, vars = "freq", fun = sum)

# Now same as t(x2) \%*\% d[["freq"]]
dummy_aggregate(data = d, x = x2, 
                vars = "freq", dummy = FALSE,
                fun = function(x, y) sum(x * y))


# Same as t(x2) \%*\% d[["freq"]]  + t(x2^2) \%*\% d[["y"]] 
dummy_aggregate(data = d, x = x2, 
                vars = list(c("freq", "y")), dummy = FALSE,
                fun = function(x, y1, y2) {sum(x * y1) + sum(x^2 * y2)})
                
}
\seealso{
\code{\link{aggregate_multiple_fun}}
}
