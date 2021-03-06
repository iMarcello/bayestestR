context("p_direction")

test_that("p_direction", {
  set.seed(333)
  p_direction <- bayestestR::p_direction(bayestestR::rnorm_perfect(10000, 1, 1))
  testthat::expect_equal(as.numeric(p_direction), 84.2, tolerance = 0.1)
  testthat::expect_is(p_direction, "p_direction")
  testthat::expect_equal(tail(capture.output(print(p_direction)), 1), "pd = 84.14%")
})
