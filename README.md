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
