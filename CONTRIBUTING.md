# Contributing to sAMRat

Thank you for your interest in contributing to sAMRat — a Shiny app for
antimicrobial resistance analysis. This file gives a brief, practical
guide to reporting issues, submitting changes, and running basic checks
locally.

## Quick start

- Fork the repository and create a branch named
  `X-feature/your-short-desc` or `X-fix/your-short-desc`. Replace `X`
  with the respective issue number.
- Make small, focused commits with clear messages.
- Open a pull request (PR) against the `main` branch. Describe the
  problem, your approach, and any testing you ran.

## Reporting issues

- Use the GitHub Issues page to report bugs or request features. Provide
  a minimal reproducible example and any error messages or screenshots.

## Development tips

- This is an R package and a Shiny app. Follow standard R package
  practices where possible.
- Keep changes small and well-scoped.

### Coding style

- Prefer the tidyverse style for R code (e.g., consistent indentation,
  use of pipes). Keep functions small and documented with roxygen2
  comments.

### Tests

- Tests live under `tests/testthat/`. Add tests for new behavior and
  ensure existing tests still pass.
- Run tests locally in your R console with:

``` r
devtools::test()
```

### Checks and documentation

- Run a package check before opening a PR:

``` r
devtools::check()
```

- If you modify exported functions or add new ones, update roxygen
  documentation and rebuild the NAMESPACE:

``` r
roxygen2::roxygenise()
```

## Pull request checklist

PR targets `main` branch (or follow repo-specific branch policy)

Adds or updates tests where applicable

Passes `devtools::check()` with no new NOTE/ERRORs if possible

Includes an entry in `NEWS.md` or the changelog if appropriate

## Code of conduct

Please follow the project’s code of conduct (be respectful and
constructive). If the project does not yet include a
`CODE_OF_CONDUCT.md`, follow GitHub’s default community guidelines.

## Questions or contact

For questions or help getting started, open an issue or email the
package maintainer listed in `DESCRIPTION`.

Thanks for helping improve sAMRat — contributions are welcome and
appreciated!
