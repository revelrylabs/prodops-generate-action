Mix.install([
  {:prodops_ex, "~> 0.1.0"}
])

prodops_api_key = System.get_env("INPUT_PRODOPS-API-KEY")
prompt_template_id = "INPUT_PROMPT-TEMPLATE-ID" |> System.get_env() |> String.to_integer()
project_id = "INPUT_PROJECT-ID" |> System.get_env() |> String.to_integer()
artifact_type_slug = System.get_env("INPUT_ARTIFACT-TYPE-SLUG")
input_count = "INPUT_INPUT-COUNT" |> System.get_env() |> String.to_integer()

parse_inputs = fn count ->
  0..count
  |> Enum.to_list()
  |> tl()
  |> Enum.map(fn index ->
    %{
      name: System.get_env("INPUT_INPUT-#{index}-NAME"),
      value: System.get_env("INPUT_INPUT-#{index}-VALUE")
    }
  end)
end

params = %{
  prompt_template_id: prompt_template_id,
  artifact_slug: artifact_type_slug,
  inputs: parse_inputs.(input_count),
  project_id: project_id
}

# TODO: make the URL an option we can pass to the action
Application.put_env(:prodops_ex, :api_key, prodops_api_key)
Application.put_env(:prodops_ex, :api_url, "https://beta.prodops.ai")

{:ok, %{response: %{"artifact" => %{"id" => artifact_id}, "url" => artifact_url}}} =
  ProdopsEx.Artifact.create(params)

IO.inspect(artifact_id, label: "artifact_id")
IO.inspect(artifact_url, label: "url")
