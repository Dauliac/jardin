# Contributing

![getting-started](../gif/getting-started.gif)

## Index
<!-- toc -->
[[_TOC_]]

## Requirements

* `nix`
* `libvirt`
* `direnv` (optional)

## Setup development environment

Setup development stack With `direnv`:

```bash
direnv allow
```

Setup development stack With pure nix flake `nix develop`:

```bash
nix develop
```

Jardin uses [`task`](https://github.com/go-task/task/) as a task runner.

To see all available tasks, run:

<!-- FIXME: use fixed cmdrun version to run `task` command here -->
```bash
task
```
