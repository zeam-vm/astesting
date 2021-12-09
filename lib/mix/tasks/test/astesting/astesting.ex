defmodule Mix.Tasks.Test.Astesting do
  use Mix.Task

  @moduledoc """
  `mix test.astesting`: Runs the tests for a project with Rossetta 2 and Docker.

  Similar to `mix test`
  but the tests run on x86_64 when on Apple Silicon and Rosetta 2 is installed,
  and run on Docker on aarch64 and x86_64 when Docker is installed.
  """

  def call_test_by_x86_64(args) do
    case System.find_executable("pkgutil") do
      nil ->
        :ok

      _ ->
        case System.cmd("pkgutil", ["--files", "com.apple.pkg.RosettaUpdateAuto"]) do
          {"", 0} ->
            :ok

          {_, 0} ->
            IO.puts("testing on x86_64")

            {_result, 0} =
              System.cmd("env", ["/usr/bin/arch", "-x86_64", "mix", "test"] ++ args,
                into: IO.stream()
              )

          _ ->
            :ok
        end
    end
  end

  def call_test_by_docker(args) do
    case System.find_executable("docker") do
      nil ->
        :ok

      _ ->
        case System.cmd("docker", ["ps"], stderr_to_stdout: true) do
          {_, 1} ->
            :ok

          _ ->
            astesting = "#{Mix.Project.app_path() |> Path.dirname()}/astesting"

            case File.read("#{astesting}/priv/Dockerfile.template") do
              {:error, :enoent} ->
                IO.puts("Dockerfile.template is lost.")

              {:error, reason} ->
                IO.puts(:file.format_error(reason))

              {:ok, binary} ->
                binary =
                  String.replace(binary, "@version", "#{System.version()}", global: false)

                dockerfile = "#{astesting}/priv/Dockerfile"

                case File.write(dockerfile, binary) do
                  {:error, reason} ->
                    IO.puts(:file.format_error(reason))

                  :ok ->
                    IO.puts("testing on Docker")

                    System.cmd(
                      "bash",
                      [
                        "-c",
                        """
                        docker build -t astesting -f #{dockerfile} . &&
                        docker run --name astesting --rm -v #{File.cwd!()}:/work_tmp -w /work astesting ash -c "cp -r /work_tmp/* . && rm -rf _build deps && mix deps.get && mix test #{args}" &&
                        docker rmi astesting
                        """
                      ],
                      into: IO.stream()
                    )

                    :ok
                end
            end
        end
    end
  end

  def arch_name() do
    :erlang.system_info(:system_architecture)
    |> List.to_string()
    |> String.split("-")
    |> hd
  end

  @impl true
  def run(args) do
    case System.find_executable("mix") do
      nil ->
        Mix.raise("Not found mix")

      _ ->
        {_result, 0} = System.cmd("mix", ["test"] ++ args, into: IO.stream())

        case :os.type() do
          {:unix, :darwin} ->
            case arch_name() do
              "aarch64" ->
                call_test_by_x86_64(args)
                call_test_by_docker(args)

              "x86_64" ->
                call_test_by_docker(args)

              _ ->
                :ok
            end

          _ ->
            :ok
        end
    end
  end
end
