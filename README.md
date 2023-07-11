# Docker and Jekyll

Template for setup of Docker and jeykll

Inspired by [Bill Raymond](https://github.com/BillRaymond) thank you!

## About

A personal project to explore the use case of Docker and `.devcontainer` environment for using jekyll!

## Prerequisites

- Docker
- Docker Desktop
- Docker and Dev Containers extension for VSCode

## Steps:

- This is a template repo, you will need to use the template and clone to your local machine
- `open folder in container` from command pallette will get you started `ctrl+shift+p`
- Run

```shell
sh init-jekyll.sh
```

- Next run

```shell
sh load-theme.sh
```

- This will set up you jekyll site and allow you edit all the theme files if you chose to start with the default theme
- run the site with

```shell
bundle exec jekyll serve --livereload
```
