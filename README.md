# StatetraceElixir

Elixir integration for https://statetrace.com


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `statetrace_elixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:statetrace_elixir, "~> 0.1.0"}
  ]
end
```

After the packages are installed you must create a database migration to add the `statetrace_annotations` table to your database:

```bash
mix ecto.gen.migration add_statetrace_annotations_table
```

Open the generated migration in your editor and call the `up` and `down` functions on `StatetraceElixir.Migrations`:

```elixir
defmodule MyApp.Repo.Migrations.AddStatetraceAnnotationsTable do
  use Ecto.Migration

  def up do
    StatetraceElixir.Migrations.up()
  end

  # We specify `version: 1` in `down`, ensuring that we'll roll all the way back down if
  # necessary, regardless of which version we've migrated `up` to.
  def down do
    StatetraceElixir.Migrations.down(version: 1)
  end
end
```


New versions may require additional migrations, however, migrations will never change between versions and they are always idempotent.

Now, run the migration to create the table:

```bash
mix ecto.migrate
```


Next we need to annotate your http requests' transactions. Wrap &action/2 in your controllers in a transaction and annotate it.

Its easiest to add this to `<YourProject>Web`

```elixir
defmodule <YourProject>Web do
  def controller do
    quote do
      use Phoenix.Controller, namespace: <YourProject>Web

      import Plug.Conn
      import <YourProject>Web.Gettext
      alias <YourProject>Web.Router.Helpers, as: Routes

      defp current_actor(conn) do
        conn.assigns.current_user # Should return %{id: String.t | nil, full_name: String.t | nil, avatar: String.t | nil}
      end

      def action(conn, _) do
        args = [conn, conn.params]

        with {_, response} <-
               StatetraceLicensing.Repo.transaction(fn ->
                 StatetraceElixir.Annotations.process_conn(conn,
                   get_actor: &current_actor/1,
                   repo: <YourProject>.Repo
                 )

                 apply(__MODULE__, action_name(conn), args)
               end) do
          response
        end
      end
    end
  end
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/statetrace_elixir](https://hexdocs.pm/statetrace_elixir).

