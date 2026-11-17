.libPaths(c(".local_library",.libPaths()))
library(readr)
x <- read_csv("portfolio/prospective_2027_q1/frozen_forecasts.csv",show_col_types=FALSE)
b <- read_csv("portfolio/prospective_2027_q1/frozen_benchmark_distribution.csv",show_col_types=FALSE)
stopifnot(nrow(x)==19,!anyDuplicated(x$locality_id),all(x$target_quarter=="2027 Q1"))
stopifnot(all(x$surge_threshold==ceiling(pmax(x$recent_mean+2,2*x$recent_mean))))
expected <- pnbinom(x$surge_threshold-1,mu=x$nb_mean,size=x$nb_size,lower.tail=FALSE)
stopifnot(all(abs(x$nb_surge_probability-expected)<1e-12))
for(i in 1:19) {
 z <- b[b$locality_id==x$locality_id[i],]
 stopifnot(abs(sum(z$probability)-1)<1e-10)
 stopifnot(abs(sum(z$probability[z$count>=x$surge_threshold[i]])-x$benchmark_surge_probability[i])<1e-10)
}
cat("19 frozen probability forecasts and benchmark distributions verified\n")
