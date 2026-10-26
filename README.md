# Alfred Bashly Template

A minimal template that connects a Bashly CLI to an Alfred Script Filter. Type `hello` in Alfred to see **Hello Alfred**.

## Initial setup

After creating a repository from this template, use **case-sensitive Replace All** in your editor for each name below. For example, to name the workflow “My Workflow”:

| Capitalization | Find | Replace with |
| --- | --- | --- |
| Lowercase repository slug | `alfred-workflow-template-sh` | `my-workflow` |
| Lowercase CLI name | `template-cli` | `my-workflow-cli` |
| Title case display name | `Alfred Bashly Template` | `My Workflow` |
| Bundle ID | `com.example.alfred-bashly-template` | `com.example.my-workflow` |

The CLI name appears in `src/bashly.yml`, both sync and package scripts, the Alfred entry script, `.gitignore`, and this README. The display name appears in both READMEs, `alfred_workflow/info.plist`, and the package script. Choose a unique bundle ID for your workflow. Rename the repository directory separately.

If you add other forms of the CLI name, replace each capitalization separately: `TEMPLATE_CLI` → `MY_WORKFLOW_CLI` (all uppercase), `template_cli` → `my_workflow_cli` (all lowercase), `Template-cli` → `My-workflow-cli` (first letter uppercase), and `TemplateCli` → `MyWorkflowCli` (Pascal case). These forms are examples; the current scripts use `template-cli`.

After replacing the names, follow the development steps below to generate the renamed CLI and update the workflow.

## Dependencies

- Alfred 5 and Powerpack
- jq

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
