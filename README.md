# prodops-generate-action
A GitHub action to generate an artifact using ProdOps. You can use this in your own GitHub Workflows to perform code reviews on Pull Requests, complexity scores or implementation help for Issues, generate Release Notes, or other AI-powered automation.

## Requirements
- First, you need a ProdOps account. Head over to https://prodops.ai/ to start your journey
- Once you have access to ProdOps, you'll need to get your API key from the team details page for your team, only accessible to Team Admins. Save this as a Repository Secret (`PRODOPS_API_KEY`) in your GitHub repo.
- You'll need the ID of the ProdOps [Project](https://help.prodops.ai/docs/projects/create-a-project) you want to generate artifacts into.
- You'll also need to create an [Artifact Type](https://help.prodops.ai/docs/artifacts/artifact_types) and a [Prompt Template](https://help.prodops.ai/docs/prompts/building-a-prompt).

## Inputs

| Name                 | Description                                                                                                      | Required |
|----------------------|------------------------------------------------------------------------------------------------------------------|----------|
| `prodops_api_key`     | Your ProdOps API key                                                                                             | true     |
| `prodops_api_url`    | The ProdOps API endpoint to use. Defaults to https://app.prodops.ai                                              | false    |
| `project_id`         | The ID of the ProdOps project to generate your artifact in                                                       | true     |
| `artifact_type_slug` | The slug for the artifact type you want to generate, visible if you edit the artifact type in the ProdOps web UI | true     |
| `prompt_template_id` | The ID of the prompt template to use when generating. Must match the artifact type                               | true     |
| `input_count`        | The number of inputs required by your prompt template, visible in the prompt template editing UI                 | true     |
| `input_1_name`       | If `input_count` is >= 1, the name of the first input                                                            | false    |
| `input_1_value`      | If `input_count` is >= 1, the value to use in the first input                                                    | false    |
| `input_2_name`       | If `input_count` is >= 2, the name of the second input                                                           | false    |
| `input_2_value`      | If `input_count` is >= 2, the value to use in the second input                                                   | false    |
| `input_3_name`       | If `input_count` is >= 3, the name of the third input                                                            | false    |
| `input_3_value`      | If `input_count` is >= 3, the value to use in the third input                                                    | false    |
| `input_4_name`       | If `input_count` is >= 4, the name of the fourth input                                                           | false    |
| `input_4_value`      | If `input_count` is >= 4, the value to use in the fourth input                                                   | false    |
| `input_5_name`       | If `input_count` is >= 5, the name of the fifth input                                                            | false    |
| `input_5_value`      | If `input_count` is >= 5, the value to use in the fifth input                                                    | false    |


## Outputs
| Name               | Description                           |
|--------------------|---------------------------------------|
| `artifact_content` | The content of the generated artifact |
| `artifact_url`     | The URL of the generated artifact     |


## Example

You can incorporate the ProdOps action into your own GitHub Workflows in any way you like. This example workflow will generate a `code_review` artifact (into project `456` using prompt template `123`) every time a new pull request is created:

```
name: Automated Code Review
on:
  pull_request:
    - opened
jobs:
  review:
    runs-on: ubuntu-22.04
    name: ProdOps Code Review
    steps:
      # clone with full history so we can diff against the base branch
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      # grab the diff against the base branch and put it into an output for later
      - id: git_diff
        run: |
          {
            echo 'diff<<EOF'
            git diff origin/${{ github.base_ref }}
            echo EOF
          } >> "$GITHUB_OUTPUT"
      # generate the artifact
      - uses: revelrylabs/prodops-generate-action@main
        name: "Automated Code Review"
        id: review
        with:
          prompt_template_id: 123
          project_id: 456
          artifact_type_slug: code_review
          prodops_api_key: ${{secrets.PRODOPS_API_KEY}}
          input_count: 1
          input_1_name: Code Changes
          input_1_value: ${{ steps.git_diff.outputs.diff }}
      # use the artifact in a subsequent step. in this case, just echo
      - env:
          URL: ${{ steps.clarity.outputs.artifact_url }}
          CONTENT: ${{ steps.clarity.outputs.artifact_content }}
        run: echo "The Artifact URL is $URL and the Artifact body is $CONTENT"
```
