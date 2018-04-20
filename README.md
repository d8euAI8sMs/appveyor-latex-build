# appveyor-latex-build

Simple build script for basic one-document pdflatex projects

## Usage

The script searches for the `.latex.build` config file recursively starting from the current working directory.

`.latex.build` files describes a particular build:

```
latex-build-command = < build command >
latex-work-dir      = < build working directory >
latex-input-doc     = < build source >
```

We will denote the location of the `.latex.build` file as `CFG_DIR`.

If no build command specified, the `LATEX_BUILD_COMMAND` environment variable will be used. Build command may also refer to environment variables.

Build source option is relative to `CFG_DIR`. If no build source specified, the first `*.tex` file found starting from `CFG_DIR` is used. If the `LATEX_INPUT_DOC` environment variable is present, it will be tried first.

Working directory is also relative to `CFG_DIR`. If no working directory specified, `CFG_DIR` is used instead. If the `LATEX_WORK_DIR` environment variable is present, it will be tried first.

The minimal configuration is empty `.latex.build` file and the `LATEX_BUILD_COMMAND` environment variable set.

Whether the build script should fail the build is controlled via the `FAIL_BUILD_ON_ERROR` environment variable (possible values are `true` or `yes`, case insensitive).
