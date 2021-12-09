# Astesting

Testing x86_64 macOS and aarch64 Linux by Apple Silicon Mac with Rosetta 2 and Docker Desktop for Mac, or x86_64 macOS and Linux by Intel x86_64 Mac and Docker Desktop for Mac.

## Installation

In order to use `Astesting`, you will need Elixir installed. Then create an Elixir project via the `mix` build tool:

```
$ mix new my_app
```

Then you can add `Astesting` as dependency in your `mix.exs`:

```elixir
def deps do
  [
    {:astesting, "~> 0.1", runtime: false}
  ]
end
```

## Usage

To conduct testing using `Astesting`, let's type the following command:

```
$ mix test.astesting
```

## License

Copyright (c) 2021 Susumu Yamazaki

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
