#' @rdname ProblemAlgorithm
#' @export
addAlgorithm = function(name, fun, reg = getDefaultRegistry())  {
  assertExperimentRegistry(reg, writeable = TRUE)
  assertString(name, min.chars = 1L)
  if (!stri_detect_regex(name, "^[[:alnum:]_.-]+$"))
    stopf("Illegal characters in problem name: %s", name)
  if (is.null(fun)) {
    fun = function(job, data, instance, ...) instance
  } else {
    assertFunction(fun, args = c("job", "data", "instance"))
  }

  algo = setClasses(list(fun = fun, name = name), "Algorithm")
  writeRDS(algo, file = file.path(reg$file.dir, "algorithms", sprintf("%s.rds", name)))
  reg$defs$algorithm = addlevel(reg$defs$algorithm, name)
  saveRegistry(reg)
  invisible(algo)
}

#' @export
#' @rdname ProblemAlgorithm
removeAlgorithm = function(name, reg = getDefaultRegistry()) {
  assertExperimentRegistry(reg, writeable = TRUE)
  assertString(name)
  assertSubset(name, levels(reg$defs$algorithm))

  fns = file.path(reg$file.dir, "algorithms", sprintf("%s.rds", name))
  def.ids = reg$defs[algorithm == name, "def.id", with = FALSE]
  job.ids = inner_join(reg$status, def.ids)[, "job.id", with = FALSE]

  if (nrow(.findOnSystem(job.ids, reg = reg)) > 0L)
    stop("Cannot remove Algorithm while jobs are running on the system")

  info("Removing Algorithm '%s' and %i corresponding jobs ...", name, nrow(job.ids))
  file.remove(fns)
  reg$defs = reg$defs[!def.ids]
  reg$status = reg$status[!job.ids]
  reg$defs$algorithm = droplevel(reg$defs$algorithm, name)
  saveRegistry(reg)
  invisible(TRUE)
}