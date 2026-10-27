# Play New ASMR

## Dependencies

- Alfred 5 and Powerpack
- jq
- curl
- htmlq

## Usage

For keywords and instructions inside Alfred, see the [workflow README](alfred_workflow/README.md).

## Development

### Bashly CLI

Install [Bashly](https://bashly.dev/) to generate the CLI while developing. You also need the runtime dependencies listed above:

```bash
brew install bashly
```

And generate the CLI to `alfred_workflow/`.

```bash
./script/sync-cli.sh
```

`forum view --output-format alfred-json` returns an `alfredworkflow` object.
On success, `arg` is an array of URL-tab-title strings (or `[]` for an empty
forum), and `variables` contains `success: true` and `error_msg: ""`.
Business errors return `arg: ""`, `success: false`, and an error message in
`variables.error_msg`, with exit status 1. Diagnostics remain on stderr.
Argument validation and dependency errors retain Bashly's usual error output.
The Alfred entry script forwards the CLI output and exit status unchanged.

After generating the CLI, run the local regression checks without network access
or real cookies:

```bash
python3 -m unittest discover -s tests
```

### Alfred Workflow

Install the `alfred_workflow` folder as an Alfred workflow using whichever method you prefer.

#### README

Follow the [Alfred Gallery Workflow Style Guide](https://alfred.app/submit/styleguide/) when writing  [alfred_workflow/README.md](alfred_workflow/README.md). Sync it into the workflow's `info.plist` after editing:

```bash
./script/sync-readme.sh
```

#### Export Package

Run `./script/package.sh` to create an `alfredworkflow` file.

## References

_Add any references or resources here._

[Alfred Script Filter JSON Format](https://www.alfredapp.com/help/workflows/inputs/script-filter/json/)

[Bashly](https://bashly.dev/)
