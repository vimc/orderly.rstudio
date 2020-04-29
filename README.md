## orderly.rstudio

<!-- badges: start -->
[![Project Status: Concept – Minimal or no implementation has been done yet, or the repository is only intended to be a limited example, demo, or proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![Build Status](https://travis-ci.com/vimc/orderly.rstudio.svg?branch=master)](https://travis-ci.com/vimc/orderly.rstudio)
[![codecov.io](https://codecov.io/github/vimc/orderly.rstudio/coverage.svg?branch=master)](https://codecov.io/github/vimc/orderly.rstudio?branch=master)
<!-- badges: end -->

RStudio addins for [orderly](https://github.com/vimc/orderly)

## Testing

There are some minimal tests here but generally no tests for the shiny side of stuff. That is because it is hard to test and the application themselves are quite simple.

To create an environment to check addins manually run

```
dir <- orderly::orderly_example("demo", run_demo = TRUE)
setwd(dir)
```

This will create a temp dir with an orderly example repo setup for checking addins.

