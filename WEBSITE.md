# Building the sAMRat Website

This document explains how to build and maintain the sAMRat website using pkgdown.

## Overview

The sAMRat website is automatically generated using [pkgdown](https://pkgdown.r-lib.org/), an R package that builds beautiful static websites from R package documentation.

## Automatic Deployment

The website is automatically built and deployed to GitHub Pages whenever:

- Code is pushed to the `main` or `master` branch
- A pull request is created or updated
- A new release is published
- The workflow is manually triggered

The deployment is handled by the GitHub Actions workflow located at `.github/workflows/pkgdown.yaml`.

## Website Structure

The website includes the following sections:

### 1. Home Page
- Location: `index.md`
- Content: Overview, features, installation instructions, and quick start guide

### 2. Function Reference
- Auto-generated from roxygen2 documentation in `R/` files
- Configuration: `_pkgdown.yml` (reference section)

### 3. Articles/Vignettes
Located in `vignettes/` directory:

- **Getting Started** (`getting-started.Rmd`): Tutorial for new users
- **Architecture** (`architecture.Rmd`): Technical overview of the package structure
- **Contributing** (`contributing.Rmd`): Guidelines for contributors (links to CONTRIBUTING.md)

### 4. Changelog
- Location: `NEWS.md`
- Auto-generated page showing version history and changes

## Building Locally

To build the website on your local machine:

### Prerequisites

```r
# Install pkgdown and dependencies
install.packages(c("pkgdown", "knitr", "rmarkdown"))
```

### Build Commands

```r
# Build the complete website
pkgdown::build_site()

# Preview the website
pkgdown::preview_site()

# Build only specific components
pkgdown::build_home()           # Home page
pkgdown::build_reference()      # Function reference
pkgdown::build_articles()       # Vignettes/articles
pkgdown::build_news()            # Changelog
```

### Quick Preview

```r
# Build and automatically open in browser
pkgdown::build_site(preview = TRUE)
```

The generated website will be in the `docs/` directory (which is git-ignored).

## Customization

### Theme and Appearance

Edit `_pkgdown.yml` to customize:

- **Bootstrap version**: Currently using Bootstrap 5
- **Bootswatch theme**: Currently using "flatly" theme
- **Colors**: Primary, secondary, and accent colors
- **Fonts**: Google Fonts for base, heading, and code

```yaml
template:
  bootstrap: 5
  bootswatch: flatly
  bslib:
    primary: "#0054AD"
    base_font:
      google: "Roboto"
```

### Navigation Bar

Configure the navbar in `_pkgdown.yml`:

```yaml
navbar:
  structure:
    left:  [intro, reference, articles, news]
    right: [search, github]
```

### Adding New Articles

1. Create a new `.Rmd` file in `vignettes/`
2. Add YAML header with vignette metadata:

```yaml
---
title: "Your Article Title"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Your Article Title}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---
```

3. Add the article to `_pkgdown.yml`:

```yaml
articles:
- title: Your Section
  navbar: ~
  contents:
  - your-article-name
```

4. Rebuild the site: `pkgdown::build_articles()`

### Organizing Function Reference

Group functions by category in `_pkgdown.yml`:

```yaml
reference:
- title: Category Name
  desc: Description of this category
- contents:
  - function_name_1
  - function_name_2
```

## Troubleshooting

### Common Issues

**Issue**: Build fails with missing packages
```r
# Solution: Install all dependencies
devtools::install_deps(dependencies = TRUE)
```

**Issue**: Vignettes not rendering
```r
# Solution: Install knitr and rmarkdown
install.packages(c("knitr", "rmarkdown"))
```

**Issue**: Site looks different locally vs. deployed
- Ensure your pkgdown version matches the one in GitHub Actions
- Clear the `docs/` folder and rebuild: `pkgdown::clean_site(); pkgdown::build_site()`

### Checking the Build

```r
# Check package documentation
devtools::document()

# Check package for issues
devtools::check()

# Build and check vignettes
devtools::build_vignettes()
```

## GitHub Pages Configuration

### First-Time Setup

1. Go to your repository on GitHub
2. Navigate to Settings → Pages
3. Under "Source", select:
   - Branch: `gh-pages`
   - Folder: `/ (root)`
4. Click "Save"

The site will be available at: `https://gero1999.github.io/sAMRat/`

### Updating the URL

If your GitHub username or repository name changes:

1. Update the URL in `_pkgdown.yml`:
```yaml
url: https://your-username.github.io/repository-name/
```

2. Update links in `DESCRIPTION` and `README.md`

## Maintenance

### Regular Updates

When making changes to the package:

1. **Update documentation**: Run `devtools::document()` after changing roxygen comments
2. **Update NEWS.md**: Add entries for new features, bug fixes, or changes
3. **Rebuild site locally**: Test that everything looks good
4. **Commit and push**: The site will auto-deploy via GitHub Actions

### Versioning

When releasing a new version:

1. Update version in `DESCRIPTION`
2. Add a new section to `NEWS.md`
3. Create a git tag: `git tag -a v0.2.0 -m "Release v0.2.0"`
4. Push the tag: `git push origin v0.2.0`
5. Create a GitHub release

The pkgdown site will automatically show version history.

## Resources

- [pkgdown documentation](https://pkgdown.r-lib.org/)
- [pkgdown customization guide](https://pkgdown.r-lib.org/articles/customise.html)
- [Bootstrap themes](https://bootswatch.com/)
- [GitHub Pages documentation](https://docs.github.com/en/pages)

## Getting Help

If you encounter issues with the website:

1. Check the [pkgdown documentation](https://pkgdown.r-lib.org/)
2. Look at the GitHub Actions logs for deployment errors
3. Open an issue on the sAMRat repository
4. Ask on the [pkgdown discussions](https://github.com/r-lib/pkgdown/discussions)
