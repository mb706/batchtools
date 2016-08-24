context("convertIds helper")

test_that("convertIds", {
  reg = makeRegistry(file.dir = NA, make.default = FALSE)
  batchMap(identity, 1:10, reg = reg)
  reg$status = reg$status[-3, ]

  tab = convertIds(reg, NULL)
  expect_equal(tab, NULL)

  tab = convertIds(reg, 1:10)
  expect_data_table(tab, ncol = 1, nrow = 9, key = "job.id")
  expect_copied(tab, reg$status)

  tab = convertIds(reg, findJobs(reg = reg))
  expect_data_table(tab, ncol = 1, nrow = 9, key = "job.id")
  expect_copied(tab, reg$status)

  tab = convertIds(reg, data.table(job.id = 3:4, key = "job.id"))
  expect_data_table(tab, ncol = 1, nrow = 1, key = "job.id")

  tab = convertIds(reg, as.data.frame(findJobs(reg = reg)))
  expect_data_table(tab, ncol = 1, key = "job.id")
  expect_copied(tab, reg$status)

  tab = convertIds(reg, 10:8)
  expect_data_table(tab, ncol = 1, nrow = 3, key = "job.id")
  expect_equal(tab$job.id, 8:10)
  expect_copied(tab, reg$status)

  expect_error(convertIds(reg, c(2, 2)), "Duplicated ids")

  tab = convertIds(reg, 10:8, keep.order = TRUE)
  expect_data_table(tab, ncol = 1, nrow = 3)
  expect_equal(tab$job.id, 10:8)

  expect_error(convertIds(reg, as.character(1:3)), "not recognized")
})