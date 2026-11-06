# Inventory executable entry points and the partial local archive cache.
# Static package mentions are an aid to review, not the recursive dependency lock.
.libPaths(c(".local_library",.libPaths()))
paths <- sort(c(list.files("scripts",full.names=TRUE),list.files("tests",full.names=TRUE)))
paths <- paths[grepl("\\.(R|py|mjs|ps1)$",paths)]
inventory <- lapply(paths,function(path) {
  code <- paste(readLines(path,warn=FALSE),collapse="\n")
  namespace_hits <- regmatches(code,gregexpr("[A-Za-z][A-Za-z0-9.]*::",code))[[1]]
  library_hits <- regmatches(code,gregexpr("library\\([A-Za-z][A-Za-z0-9.]*",code))[[1]]
  packages <- sort(unique(c(sub("::$","",namespace_hits),sub("library\\(","",library_hits))))
  data.frame(path=path,language=tools::file_ext(path),
    explicit_r_package_mentions=paste(packages,collapse=";"),
    sha256=digest::digest(readBin(path,"raw",n=file.info(path)$size),algo="sha256",serialize=FALSE))
})
write.csv(do.call(rbind,inventory),"config/environment_entry_points.csv",row.names=FALSE)
cache_root <- "C:/Users/John/Documents/R-Positron/Cache"
archives <- list.files(cache_root,pattern="\\.(zip|tar\\.gz)$",recursive=TRUE,full.names=TRUE)
archive_inventory <- data.frame(archive=substring(archives,nchar(cache_root)+2L),
  bytes=file.info(archives)$size,
  sha256=vapply(archives,function(path) digest::digest(readBin(path,"raw",n=file.info(path)$size),
    algo="sha256",serialize=FALSE),character(1)))
write.csv(archive_inventory,"config/environment_available_archives.csv",row.names=FALSE)
message("Inventoried ",length(paths)," entry points and ",length(archives)," partial-cache archives.")
