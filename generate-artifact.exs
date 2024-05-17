Mix.install([
  {:prodops_ex, "~> 0.1.0"}
])

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

params = %{
  prompt_template_id: prompt_template_id,
  artifact_slug: artifact_type_slug,
  inputs: parse_inputs.(input_count),
  project_id: project_id
}

Application.put_env(:prodops_ex, :api_key, prodops_api_key)
Application.put_env(:prodops_ex, :api_url, prodops_api_url)

{:ok, %{response: %{"artifact" => %{"id" => artifact_id}, "url" => artifact_url}}} =
  ProdopsEx.Artifact.create(params)

IO.inspect(artifact_id, label: "artifact_id")
IO.inspect(artifact_url, label: "url")
