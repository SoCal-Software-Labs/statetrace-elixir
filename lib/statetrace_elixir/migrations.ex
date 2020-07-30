defmodule StatetraceElixir.Migrations do
  @moduledoc false

  use Ecto.Migration

  @initial_version 1
  @current_version 1
  @default_prefix "public"

  def up(opts \\ []) when is_list(opts) do
    prefix = Keyword.get(opts, :prefix, @default_prefix)
    version = Keyword.get(opts, :version, @current_version)
    initial = min(migrated_version(repo(), prefix) + 1, @current_version)

    if initial <= version, do: change(prefix, initial..version, :up)
  end

  def down(opts \\ []) when is_list(opts) do
    prefix = Keyword.get(opts, :prefix, @default_prefix)
    version = Keyword.get(opts, :version, @initial_version)
    initial = max(migrated_version(repo(), prefix), @initial_version)

    if initial >= version, do: change(prefix, initial..version, :down)
  end

  def initial_version, do: @initial_version

  def current_version, do: @current_version

  def migrated_version(repo, prefix) do
    query = """
    SELECT description
    FROM pg_class
    LEFT JOIN pg_description ON pg_description.objoid = pg_class.oid
    LEFT JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
    WHERE pg_class.relname = 'statetrace_annotations'
    AND pg_namespace.nspname = '#{prefix}'
    """

    case repo.query(query) do
      {:ok, %{rows: [[version]]}} when is_binary(version) -> String.to_integer(version)
      _ -> 0
    end
  end

  defp change(prefix, range, direction) do
    for index <- range do
      [__MODULE__, "V#{index}"]
      |> Module.concat()
      |> apply(direction, [prefix])
    end
  end

  defmodule Helper do
    @moduledoc false

    defmacro now do
      quote do
        fragment("timezone('UTC', now())")
      end
    end

    def record_version(prefix, version) do
      execute("COMMENT ON TABLE #{prefix}.statetrace_annotations IS '#{version}'")
    end
  end

  defmodule V1 do
    @moduledoc false

    use Ecto.Migration

    import StatetraceElixir.Migrations.Helper

    def up(prefix) do
      if prefix != "public", do: execute("CREATE SCHEMA IF NOT EXISTS #{prefix}")

      create table(:statetrace_annotations, primary_key: false) do
        add(:uuid, :uuid, primary_key: true)
        add(:id, :integer)
        add(:timestamp, :utc_datetime_usec)
        add(:kind, :string)
        add(:meta, :json)
        add(:parent_id, :integer)
        add(:parent_timestamp, :utc_datetime_usec)
        add(:action_url, :string)
        add(:session_actor_id, :string)
        add(:session_actor_full_name, :string)
        add(:session_actor_avatar, :string)
      end

      record_version(prefix, 1)
    end

    def down(prefix) do
      drop_if_exists(table(:statetrace_annotations, prefix: prefix))
    end
  end
end
