testthat::test_that("create_amr_obj: basic transformation and metadata", {
	testthat::skip_if_not_installed("AMR")

	df <- data.frame(
		mo = c("Escherichia coli", "Staphylococcus aureus"),
		AMP = c("R", "S"),
		date = c("2020-01-01", "2020-01-02"),
		id = c("p1", "p2"),
		stringsAsFactors = FALSE
	)

	expect_silent({
		amr_obj <- create_amr_obj(df, mo_col = "mo", sir_cols = "AMP", date_col = "date", subject_col = "id")
	})

	testthat::expect_type(amr_obj, "list")
	testthat::expect_true(is.data.frame(amr_obj$data))
	testthat::expect_true("SUBJID" %in% names(amr_obj$data))
	testthat::expect_true(is.factor(amr_obj$data$SUBJID))
	testthat::expect_s3_class(amr_obj$data[["date"]], "Date")

	testthat::expect_true(is.list(amr_obj$mo))
	testthat::expect_true(all(c("naming", "traits", "taxonomy", "details") %in% names(amr_obj$mo)))

	testthat::expect_true(is.list(amr_obj$ab))
	testthat::expect_true("group" %in% names(amr_obj$ab))
	testthat::expect_true("col" %in% names(amr_obj$ab$group))
	testthat::expect_true("AMP" %in% amr_obj$ab$group$col)
})


testthat::test_that("create_amr_obj handles missing optional columns gracefully", {
	testthat::skip_if_not_installed("AMR")

	df <- data.frame(a = 1:3, b = letters[1:3], stringsAsFactors = FALSE)
	amr_obj <- create_amr_obj(df)

	testthat::expect_type(amr_obj, "list")
	testthat::expect_true(is.data.frame(amr_obj$data))
	testthat::expect_equal(amr_obj$data, df)
})


testthat::test_that("create_amr_obj coerces common date formats to Date", {
	testthat::skip_if_not_installed("AMR")

	df <- data.frame(
		mo = "Escherichia coli",
		AMP = "S",
		date1 = "2020-01-05",
		date2 = "05/01/2020",
		id = "p1",
		stringsAsFactors = FALSE
	)

	amr1 <- create_amr_obj(df, mo_col = "mo", sir_cols = "AMP", date_col = "date1", subject_col = "id")
	amr2 <- create_amr_obj(df, mo_col = "mo", sir_cols = "AMP", date_col = "date2", subject_col = "id")

	testthat::expect_s3_class(amr1$data[["date1"]], "Date")
	testthat::expect_s3_class(amr2$data[["date2"]], "Date")
})

