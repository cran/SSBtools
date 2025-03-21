% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Reduce0exact.R
\name{Reduce0exact}
\alias{Reduce0exact}
\title{Reducing a non-negative regression problem}
\usage{
Reduce0exact(
  x,
  z = NULL,
  reduceByColSums = FALSE,
  reduceByLeverage = FALSE,
  leverageLimit = 0.999999,
  digitsRoundWhole = 9,
  y = NULL,
  yStart = NULL,
  printInc = FALSE
)
}
\arguments{
\item{x}{A matrix}

\item{z}{A single column matrix}

\item{reduceByColSums}{See Details}

\item{reduceByLeverage}{See Details}

\item{leverageLimit}{Limit to determine perfect fit}

\item{digitsRoundWhole}{\code{\link{RoundWhole}} parameter for fitted values (when \code{leverageLimit} and \code{y} not in input)}

\item{y}{A single column matrix. With \code{y} in input, \code{z} in input can be omitted and estimating \code{y} (when \code{leverageLimit}) is avoided.}

\item{yStart}{A starting estimate when this function is combined with iterative proportional fitting. Zeros in yStart will be used to reduce the problem.}

\item{printInc}{Printing iteration information to console when TRUE}
}
\value{
A list of five elements:
\itemize{
\item \code{x}: A reduced version of input \code{x}
\item \code{z}: Corresponding reduced \code{z}
\item \code{yKnown}: Logical, specifying known values of \code{y}
\item \code{y}: A version of \code{y} with known values correct and others zero
\item \code{zSkipped}: Logical, specifying omitted columns of \code{x}
}
}
\description{
The linear equation problem, \code{z = t(x) \%*\% y} with y non-negative and x as a design (dummy) matrix,
is reduced to a smaller problem by identifying elements of \code{y} that can be found exactly from \code{x} and \code{z}.
}
\details{
Exact elements can be identified in three ways in an iterative manner:
\enumerate{
\item By zeros in \code{z}. This is always done.
\item By columns in x with a singe nonzero value. Done when \code{reduceByColSums} or \code{reduceByLeverage} is \code{TRUE}.
\item By exact linear regression fit (when leverage is one). Done when \code{reduceByLeverage} is \code{TRUE}.
The leverages are computed by \code{hat(as.matrix(x), intercept = FALSE)}, which can be very time and memory consuming.
Furthermore, without \code{y} in input, known values will be computed by \code{\link[MASS]{ginv}}.
}
}
\examples{
# Make a special data set
d <- SSBtoolsData("sprt_emp")
d$ths_per <- round(d$ths_per)
d <- rbind(d, d)
d$year <- as.character(rep(2014:2019, each = 6))
to0 <- rep(TRUE, 36)
to0[c(6, 14, 17, 18, 25, 27, 30, 34, 36)] <- FALSE
d$ths_per[to0] <- 0

# Values as a single column matrix
y <- Matrix::Matrix(d$ths_per, ncol = 1)

# A model matrix using a special year hierarchy
x <- Hierarchies2ModelMatrix(d, hierarchies = list(geo = "", age = "", year = 
    c("y1418 = 2014+2015+2016+2017+2018", "y1519 = 2015+2016+2017+2018+2019", 
      "y151719 = 2015+2017+2019", "yTotal = 2014+2015+2016+2017+2018+2019")), 
      inputInOutput = FALSE)

# Aggregates 
z <- Matrix::t(x) \%*\% y
sum(z == 0)  # 5 zeros

# From zeros in z
a <- Reduce0exact(x, z)
sum(a$yKnown)   # 17 zeros in y is known
dim(a$x)        # Reduced x, without known y and z with zeros 
dim(a$z)        # Corresponding reduced z 
sum(a$zSkipped) # 5 elements skipped 
Matrix::t(a$y)          # Just zeros (known are 0 and unknown set to 0) 

# It seems that three additional y-values can be found directly from z
sum(Matrix::colSums(a$x) == 1)

# But it is the same element of y (row 18)
a$x[18, Matrix::colSums(a$x) == 1]

# Make use of ones in colSums
a2 <- Reduce0exact(x, z, reduceByColSums = TRUE)
sum(a2$yKnown)          # 18 values in y is known
dim(a2$x)               # Reduced x
dim(a2$z)               # Corresponding reduced z
a2$y[which(a2$yKnown)]  # The known values of y (unknown set to 0)

# Six ones in leverage values 
# Thus six extra elements in y can be found by linear estimation
hat(as.matrix(a2$x), intercept = FALSE)

# Make use of ones in leverages (hat-values)
a3 <- Reduce0exact(x, z, reduceByLeverage = TRUE)
sum(a3$yKnown)          # 26 values in y is known (more than 6 extra)
dim(a3$x)               # Reduced x
dim(a3$z)               # Corresponding reduced z
a3$y[which(a3$yKnown)]  # The known values of y (unknown set to 0)

# More than 6 extra is caused by iteration 
# Extra checking of zeros in z after reduction by leverages 
# Similar checking performed also after reduction by colSums

}
\author{
Øyvind Langsrud
}
