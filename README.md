# LiveChat

## Running the app

Clone the repository

`$ git clone https://github.com/msimonborg/live_chat.git`

`$ cd live_chat`

Install Erlang 24.3.2 and Elixir 1.13.3 (the latest versions at the time of writing).
I recommend using `asdf`.

If you do not have ASDF installed, follow the `Install ASDF` section of this guide:
[Installing Elixir and Erlang With ASDF](https://www.pluralsight.com/guides/installing-elixir-erlang-with-asdf)

From the `live_chat` project root directory and with ASDF installed:

```shell
$ asdf plugin add erlang
$ asdf plugin add elixir
$ asdf install
```

The command `asdf install` will look inside the `.tool_versions` file in this project
and install the correct versions of Erlang and Elixir.

Follow the rest of the guide if you wish to install other versions of Erlang/Elixir for
other projects, and/or set global versions on your system.

To start your Phoenix server:

  * Setup your app by installing dependencies, creating and migrating the database
  with `$ mix ecto.setup`
  * Run tests with `$ mix test`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check the Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more about Phoenix

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
