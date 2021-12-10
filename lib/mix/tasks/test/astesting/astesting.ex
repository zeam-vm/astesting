defmodule Mix.Tasks.Test.Astesting do
  use Mix.Task

  @moduledoc """
  `mix test.astesting`: Runs the tests for a project with Rossetta 2 and Docker.

  Similar to `mix test`
  but the tests run on multiple environments, as follows:

  * When runing on Mac with Apple Silicon, run on x86_64 macOS when Rosetta 2 is installed,
  and run on aarch64 Linux when Docker is installed and launched.
  * When runnint on Mac with Intel CPU, run on x86_64 Linux when Docker is installed and launched.
  """

  @doc false
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
            :crypto.rand_seed()
            working_dir = "/tmp/astesting#{:rand.uniform(10000)}"
            System.cmd("rm", ["-rf", working_dir], into: IO.stream())
            System.cmd("cp", ["-r", ".", working_dir], into: IO.stream())
            System.cmd("env", ["/usr/bin/arch", "-x86_64", "mix", "test"] ++ args, cd: working_dir, into: IO.stream)
            System.cmd("rm", ["-rf", working_dir], into: IO.stream())
            :ok

          _ ->
            :ok
        end
    end
  end

  @doc false
  def call_test_by_docker(args) do
    case System.find_executable("docker") do
      nil ->
        :ok

      _ ->
        case System.cmd("docker", ["ps"], stderr_to_stdout: true) do
          {_, 1} ->
            :ok

          _ ->
            :crypto.rand_seed()

            astesting = "#{Mix.Project.app_path() |> Path.dirname()}/astesting"

            case File.read("#{astesting}/priv/Dockerfile.template") do
              {:error, :enoent} ->
                IO.puts("Dockerfile.template is lost.")

              {:error, reason} ->
                IO.puts(:file.format_error(reason))

              {:ok, binary} ->
                binary = String.replace(binary, "@version", "#{System.version()}", global: false)

                dockerfile = "#{astesting}/priv/Dockerfile#{:rand.uniform(1000)}"

                case File.write(dockerfile, binary) do
                  {:error, reason} ->
                    IO.puts(:file.format_error(reason))

                  :ok ->
                    IO.puts("testing on Docker")

                    name = "astesting#{:rand.uniform(1000)}"

                    System.cmd(
                      "bash",
                      [
                        "-c",
                        """
                        docker build -t #{name} -f #{dockerfile} . &&
                        docker run --name #{name} --rm -v #{File.cwd!()}:/work_tmp -w /work #{name} ash -c "cp -r /work_tmp/* . && rm -rf _build deps && mix deps.get && mix test #{args}" &&
                        docker rmi #{name}
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

  @doc false
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
