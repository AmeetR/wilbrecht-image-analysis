\name{cloudfor}
\alias{cloudfor}
\title{
Techila R cloudfor
}
\description{
Cloudfor is used to run for loops with Techila.
}
\usage{
result <- cloudfor (...,
                      .variables = NULL
                      .estimateTarget = 20,
                      .estimateMinimum = 1,
                      .<peach_param>=<value>) \%t\% { code }
}
\arguments{

\item{...}{looping parameter}

\item{.variables}{A list of parameters to be exported to the workers, if
this is not defined the list is automatically generated.}

\item{.estimateTarget}{Attempt to set steps parameter so that each job
will take the given amount of seconds to run.}

\item{.estimateMinimum}{Minimum time (seconds) to run estimation loop
before computing steps value.}

\item{.peach_param}{All Peach parameters with "." prefix, not all
parameters can be applied reasonably (e.g. funcname, files). See peach
documentation.}

}

\value{A list of values returned by the inner code block.}

\examples{
results <- cloudfor(i = 1:10) \%t\% \{
  i + 10
\}

results <- cloudfor(i = 1:10, .stream=TRUE) \%t\% \{
  i + 10
\}

results <- cloudfor(i = 1:10) \%to\%
  cloudfor(j = 1:20) \%t\% \{
    i * j
  \}
}

\author{
Maintainer: Techila <info@techila.fi>
}
\keyword{ techila cloudfor }
