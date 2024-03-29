% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/FindCommonCells.R
\encoding{UTF8}
\name{FindCommonCells}
\alias{FindCommonCells}
\title{Finding commonCells}
\usage{
FindCommonCells(dimList1, dimList2)
}
\arguments{
\item{dimList1}{As input parameter dimList to the function makeProblem in package sdcTable.}

\item{dimList2}{Another dimList with the same names and using the same level names.}
}
\value{
Output is a list according to the specifications in sdcTable.
}
\description{
Finding lists defining common cells as needed for the input parameter
commonCells to the function protectLinkedTables in package sdcTable.
The function handles two tables based on the same main variables
but possibly different aggregating variables.
}
\examples{
 x <- rep(c('A','B','C'),3)
 y <- rep(c(11,22,11),3)
 z <- c(1,1,1,2,2,2,3,3,3)
 zy <- paste(z,y,sep='')
 m <- cbind(x,y,z,zy)
 fg <- FindTableGroup(m,findLinked=TRUE)
 dimLists <- FindDimLists(m,fg$groupVarInd)
 # Using table1 and table2 in this example cause error,
 # but in other cases this may work well
 try(FindCommonCells(dimLists[fg$table$table1],dimLists[fg$table$table2]))
 FindCommonCells(dimLists[c(1,2)],dimLists[c(1,3)])
}
\author{
Øyvind Langsrud
}
