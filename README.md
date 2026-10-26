# Play New ASMR

## Dependencies

- Alfred 5 and Powerpack
- jq
- curl
- htmlq

## Usage

For keywords and instructions inside Alfred, see the [workflow README](alfred_workflow/README.md).

Fetch a forum page and parse its thread list:

```bash
export SOUTH_WINDUSER='your winduser Cookie value'
./play-new-asmr-cli get-html | ./play-new-asmr-cli parse-thread-list --output-format json
```

`get-html --url URL` writes HTML to stdout. It uses a browser User-Agent;
`SOUTH_USER_AGENT` overrides it. Set `SOUTH_COOKIE_FILE` to use a Netscape-format
Cookie file instead of `SOUTH_WINDUSER`.

`parse-thread-list` reads HTML from stdin. Its default output is tab-separated
text; `--output-format json` produces a JSON array with `title`,
`published_date`, `thread_type` (`normal` or `pinned`), `pin_level`, and `url`.
Dates have day precision. Use `--base-url URL` for links on another domain.

```bash
./play-new-asmr-cli get-html > page.html
./play-new-asmr-cli parse-thread-list --output-format json < page.html > threads.json
```

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
