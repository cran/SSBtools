% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/FactorLevCorr.R
\encoding{UTF8}
\name{FactorLevCorr}
\alias{FactorLevCorr}
\title{Factor level correlation}
\usage{
FactorLevCorr(x)
}
\arguments{
\item{x}{Input matrix or data frame containing the variables}
}
\value{
Output is a sort of correlation matrix.

        Here we refer to ni as the number of present levels of variable i (the number of unique elements) and we refer to mij as the number
        of present levels obtained by crossing variable i and variable j (the number unique rows of x[,c(i,j)]).

        The diagonal elements of the output matrix contains the number of present levels of each variable (=ni).

        The absolute values of off-diagonal elements:
        \item{0}{when mij = ni*nj}
        \item{1}{when mij = max(ni,nj)}
        \item{Other values}{Computed as (ni*nj-mij)/(ni*nj-max(ni,nj))}

        So 0 means that all possible level combinations exist in the data and 1 means that the two variables are
        hierarchically related.

        The sign of off-diagonal elements:
        \item{positive}{when ni<nj}
        \item{negative}{when ni>nj}

        In cases where ni=nj elements will be positive above the diagonal and negative below.
}
\description{
A sort of correlation matrix useful to detect (hierarchical) relationships between the levels of factor variables.
}
\examples{
 x <- rep(c("A","B","C"),3)
 y <- rep(c(11,22,11),3)
 z <- c(1,1,1,2,2,2,3,3,3)
 zy <- paste(z,y,sep="")
 m <- cbind(x,y,z,zy)
 FactorLevCorr(m)

}
\author{
Øyvind Langsrud
}
