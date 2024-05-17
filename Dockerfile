FROM hexpm/elixir:1.16.2-erlang-26.0.2-debian-bookworm-20240513-slim 

COPY generate-artifact.exs /generate-artifact.exs

ENTRYPOINT ["elixir", "/generate-artifact.exs"]
