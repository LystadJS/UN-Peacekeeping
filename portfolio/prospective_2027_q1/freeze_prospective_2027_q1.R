# Freeze the existing model and empirical benchmark for a future target.
# No target outcomes are read; rerunning cannot overwrite issued predictions.
.libPaths(c(".local_library",.libPaths()))
library(readr)
library(dplyr)
library(glmmTMB)
root <- "outputs/prospective_2027_q1"
out <- "portfolio/prospective_2027_q1"
dir.create(out,recursive=TRUE,showWarnings=FALSE)
stopifnot(!file.exists(file.path(out,"frozen_forecasts.csv")))
audit <- read_csv(file.path(root,"source_date_summary.csv"),show_col_types=FALSE)
stopifnot(all(audit$invalid_tokens==0),all(audit$any_post_origin==0))
train <- read_csv(file.path(root,"2027-01-01","training_rows.csv"),show_col_types=FALSE) |>
 mutate(locality_id=factor(locality_id),province=factor(province),
 season=factor(source_quarter%%4+1,levels=1:4))
target <- read_csv(file.path(root,"2027-01-01","origin_features.csv"),show_col_types=FALSE) |>
 mutate(locality_id=factor(locality_id,levels=levels(train$locality_id)),
 province=factor(province,levels=levels(train$province)),season=factor(1,levels=1:4))
stopifnot(nrow(train)==817,nrow(target)==19,max(train$source_quarter)==8106,
 all(target$source_quarter==8108),all(is.na(target$immediate_count)),
 all(is.na(target$recorded_events)))
fit <- glmmTMB(recorded_events~lag2_active+log1p(lag2_recent_total)+province+
 time_index+season+(1|locality_id),data=train,family=nbinom2())
stopifnot(fit$fit$convergence==0,isTRUE(fit$sdr$pdHess))
mu <- as.numeric(predict(fit,newdata=target,type="response")); size <- sigma(fit)
stopifnot(all(is.finite(mu)&mu>0),is.finite(size),size>0)
threshold <- ceiling(pmax(target$lag2_recent_total/4+2,2*target$lag2_recent_total/4))
benchmark <- list(); masses <- list()
for(i in seq_len(nrow(target))) {
 local <- train$recorded_events[train$locality_id==target$locality_id[i]]
 global <- train$recorded_events
 support <- 0:max(global)
 probability <- (tabulate(local+1,nbins=length(support))+
   10*tabulate(global+1,nbins=length(support))/length(global))/(length(local)+10)
 stopifnot(abs(sum(probability)-1)<1e-10)
 benchmark[[i]] <- tibble(locality_id=as.character(target$locality_id[i]),
 benchmark_mean=sum(support*probability),
 benchmark_surge_probability=sum(probability[support>=threshold[i]]))
 masses[[i]] <- tibble(locality_id=as.character(target$locality_id[i]),
                      count=support,probability=probability)
}
forecasts <- target |> transmute(locality_id=as.character(locality_id),locality,
 target_quarter="2027 Q1",issue_date="2026-11-16",history_end="2026 Q3",
 recent_mean=lag2_recent_total/4,surge_threshold=threshold,
 nb_mean=mu,nb_size=size,nb_surge_probability=pnbinom(threshold-1,mu=mu,size=size,lower.tail=FALSE),
 nb_lower90=qnbinom(.05,mu=mu,size=size),nb_upper90=qnbinom(.95,mu=mu,size=size)) |>
 left_join(bind_rows(benchmark),by="locality_id")
write_csv(forecasts,file.path(out,"frozen_forecasts.csv"))
write_csv(bind_rows(masses),file.path(out,"frozen_benchmark_distribution.csv"))
saveRDS(fit,file.path(root,"frozen_fit.rds"))
write_csv(tibble(n=nobs(fit),aic=AIC(fit),bic=BIC(fit),dispersion=size,converged=TRUE,
 historical_reliability="Not established; prior performance mixed"),file.path(out,"fit_checks.csv"))
write_csv(as.data.frame(summary(fit)$coefficients$cond) |>
 tibble::rownames_to_column("term"),file.path(out,"fixed_parameters.csv"))
inputs <- c("data/interim/ucdp/GEDEvent_v26_1.csv",
 "data/raw/ucdp/candidate_availability_20261116/GEDEvent_v26_01_26_09.csv",
 "data/raw/boundaries/salb_2018.geojson","config/city_aggregation.csv",
 file.path(root,"2027-01-01","training_rows.csv"),
 file.path(root,"2027-01-01","origin_features.csv"),
 "docs/prospective_2027_q1_specification.md")
write_csv(tibble(path=inputs,sha256=vapply(inputs,function(p)digest::digest(file=p,algo="sha256"),character(1))),
 file.path(out,"input_hashes.csv"))
writeLines(capture.output(sessionInfo()),file.path(out,"session_info.txt"))
write_csv(tibble(created_at_utc=format(Sys.time(),tz="UTC",usetz=TRUE),
 external_registration="Not yet independently archived",
 future_outcomes_available=FALSE),file.path(out,"archive_status.csv"))
cat("Frozen forecasts:",nrow(forecasts)," Training rows:",nobs(fit),"\n")
