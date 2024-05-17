Mix.install([
  {:prodops_ex, "~> 0.1.0"}
])

# parse the inputs
prodops_api_key = System.get_env("INPUT_PRODOPS_API_KEY")
prodops_api_url = System.get_env("INPUT_PRODOPS_API_URL")

prodops_api_url =
  if prodops_api_url in [nil, ""], do: "https://app.prodops.ai", else: prodops_api_url

prompt_template_id = "INPUT_PROMPT_TEMPLATE_ID" |> System.get_env() |> String.to_integer()
project_id = "INPUT_PROJECT_ID" |> System.get_env() |> String.to_integer()
artifact_type_slug = System.get_env("INPUT_ARTIFACT_TYPE_SLUG")
input_count = "INPUT_INPUT_COUNT" |> System.get_env() |> String.to_integer()

parse_inputs = fn count ->
  0..count
  |> Enum.to_list()
  |> tl()
  |> Enum.map(fn index ->
    %{
      name: System.get_env("INPUT_INPUT_#{index}_NAME"),
      value: System.get_env("INPUT_INPUT_#{index}_VALUE")
    }
  end)
end

# configure the ProdOps SDK with our settings
Application.put_env(:prodops_ex, :api_key, prodops_api_key)
Application.put_env(:prodops_ex, :api_url, prodops_api_url)

# create the artifact
params = %{
  prompt_template_id: prompt_template_id,
  artifact_slug: artifact_type_slug,
  inputs: parse_inputs.(input_count),
  project_id: project_id
}

{:ok, %{response: %{"artifact" => %{"content" => content}, "url" => artifact_url}}} =
  ProdopsEx.Artifact.create(params)

# write the outputs
output_file = System.get_env("GITHUB_OUTPUT")
{:ok, handle} = File.open(output_file, [:append])
IO.write(handle, "artifact_url=#{artifact_url}")

IO.write(handle, """
artifact_content<<ARTIFACT_EOF
#{content}
ARTIFACT_EOF
""")

File.close(handle)
