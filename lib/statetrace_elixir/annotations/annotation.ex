defmodule StatetraceElixir.Annotations.Annotation do
  @moduledoc """
  Schema to Annotation
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: true}

  schema "statetrace_annotations" do
    field(:timestamp, :utc_datetime_usec)
    field(:id, :integer)

    field(:kind, :string)
    field(:meta, :map)
    field(:parent_id, :integer)
    field(:parent_timestamp, :utc_datetime_usec)

    field(:action_url, :string)

    field(:session_actor_id, :string)
    field(:session_actor_full_name, :string)
    field(:session_actor_avatar, :string)
  end

  @doc false
  def changeset(annotation, attrs) do
    annotation
    |> cast(attrs, [
      :timestamp,
      :id,
      :kind,
      :meta,
      :parent_id,
      :parent_timestamp,
      :action_url,
      :session_actor_id,
      :session_actor_full_name,
      :session_actor_avatar
    ])
    |> validate_required([:timestamp, :id, :kind])
  end
end
