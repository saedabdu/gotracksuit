# SRE Take-Home Test (TypeScript)

This is a template for a take-home test. See the [Instructions][Instructions] for details
on the activity.

**Set Up Your Repository**

1. On the top right corner of this page, click the "Use this template" button
2. Select "Create Your Own Repository" from the dropdown
3. Give the repository a name under your Github account, and click "Create a new repository"
4. Follow the below instructions to complete the exercise

**Submit Your Work**

Once you’ve completed the task, please add the `tracksuit-technical-test` Github
user as a collaborator, and share the repo link with the talent manager.

<!-- Link definitions -->

[DenoInstall]: https://docs.deno.com/runtime/getting_started/installation/
[mise.toml]: ./mise.toml
[Instructions]: ./Instructions.md

## Setup

Install Deno 2.4 using your preferred method--typically this would be your
system's package manager. See [Deno's installation instructions][DenoInstall] to find the
command that's right for you.

<!-- deno-fmt-ignore-start -->

> [!Tip]
> If you happen to use Mise for version management, this repo's got you.
>
> ```sh
> mise trust && mise install
> ```

<!-- deno-fmt-ignore-end -->

This repo was developed against Deno 2.4.2.

## Common tasks

Most of the commands you'll need are provided by the Deno toolchain. You can run
tasks either from the repo root or within each package

### Building the server

```sh
cd server
deno task build
```

This is set up to output an x86_64 Linux ELF at `server/build/server`. You can
override the target architecture if necessary by setting the `ARCH` environment
variable; [see the docs here](https://docs.deno.com/runtime/reference/cli/compile/#supported-targets) for possible values.

### Building the frontend

While you don't have to worry too much about it for this exercise, you might
want to try building the frontend:

```sh
cd client
deno task build
```

### Typechecking

```sh
deno check .
```
