# appveyor-latex-build

Simple build script for basic one-document pdflatex projects

## Usage

The script searchs for the `.latex.build` config file recursively starting from the current working directory.

`.latex.build` files describes a particular build:

```
latex-build-command = < build command >
latex-build-dir     = < build working directory >
latex-build-doc     = < build source >
```

If no build command specified, `LATEX_BUILD_COMMAND` environment variable is used. Build command may contain environment variables.

Build source option is relative to build directory. If no build source specified, the first `*.tex` file found starting from the given build directory is used.

Build directory may be set relative to the current working directory. If no build directory specified, the parent directory of the given build source is used. If neither build source nor build directory specified, the first `*.tex` file found starting from the current working directory is used and build directory is set to its parent directory.

The minimal configuration is empty `.latex.build` file and `LATEX_BUILD_COMMAND` environment variable set.
