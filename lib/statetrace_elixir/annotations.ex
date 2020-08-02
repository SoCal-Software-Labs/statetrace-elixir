defmodule StatetraceElixir.Annotations do
  @moduledoc """
  Schema for annotating database transactions for Statetrace.

  Statetrace treats values written to statetrace_annotations in a special way,
  allowing you to annotate the row-level transaction information. This should not be used
  directly, instead you should use `StatetraceElixir.Annotations`

  For information about integration see `process_conn/2`
  """
  defmodule CurrentUser do
    defstruct [:id, :full_name, :avatar]
  end

  import Ecto.Query
  import Phoenix.Controller
  import Plug.Conn

  alias StatetraceElixir.Annotations.Annotation

  @doc """
  Generate the numerical portion of the frame's ID.
  """
  def new_id do
    rem(abs(System.monotonic_time(:nanosecond)), 2_147_483_647)
  end

  @doc """
  Annotate session information into the current database transaction.
  """
  def log_session!(repo, session_actor_id, session_actor_full_name, session_actor_avatar) do
    %Annotation{
      id: new_id(),
      kind: "_st.app.sess",
      timestamp: DateTime.utc_now(),
      session_actor_id: "#{session_actor_id}",
      session_actor_full_name: session_actor_full_name,
      session_actor_avatar: session_actor_avatar
    }
    |> repo.insert!()
  end

  @doc """
  Annotate action information into the current database transaction.
  """
  def log_action!(repo, parent_timestamp, parent_id, action_url) do
    %Annotation{
      id: new_id(),
      kind: "_st.app.act",
      timestamp: DateTime.utc_now(),
      parent_id: parent_id,
      parent_timestamp: parent_timestamp,
      action_url: action_url
    }
    |> repo.insert!()
  end

  @doc """
  Processes a `Plug.Conn` to annotate the current transaction with request details.

  This should be called inside of a transaction for example:

  ```
    defmodule MyAppWeb.SomeController do
      use MyAppWeb, :controller
      alias StatetraceElixir.Annotations

      def action(conn, _) do
        args = [conn, conn.params]

        with {_, response} <-
               MyApp.Repo.transaction(fn ->
                 Annotations.process_conn(conn,
                   get_actor: fn conn -> conn.assigns.current_actor end,
                   repo: MyApp.Repo
                 )

                 apply(__MODULE__, action_name(conn), args)
               end) do
          response
        end
      end
    end
  ```
  """
  def process_conn(conn, options) do
    repo = Keyword.fetch!(options, :repo)
    get_actor = Keyword.get(options, :get_actor, &get_nil/1)
    get_action_url = Keyword.get(options, :get_action_url, &get_current_url/1)

    conn
    |> process_session!(repo, get_actor)
    |> process_action!(repo, get_action_url)
  end

  @doc """
  Annotates session information as part of `process_conn/2` 

  This function is exposed to give finer grained control over those who need it. In general it is recommended to use `process_conn/2` 
  """
  def process_session!(
        conn,
        repo,
        get_actor \\ &get_nil/1
      ) do
    case get_session(conn, :statetrace_session) do
      nil ->
        annotation =
          case get_actor.(conn) do
            nil ->
              log_session!(repo, nil, nil, nil)

            %{id: id, full_name: full_name, avatar: avatar} ->
              log_session!(repo, id, full_name, avatar)
          end

        put_session(
          conn,
          :statetrace_session,
          Jason.encode!([annotation.timestamp, annotation.id])
        )

      session ->
        conn
    end
  end

  @doc """
  Annotates action information as part of `process_conn/2` 

  This function is exposed to give finer grained control over those who need it. In general it is recommended to use `process_conn/2` 
  """
  def process_action!(
        conn,
        repo,
        get_action_url \\ &get_current_url/1
      ) do
    [parent_timestamp_str, parent_id] = Jason.decode!(get_session(conn, :statetrace_session))
    {:ok, parent_timestamp, 0} = DateTime.from_iso8601(parent_timestamp_str)
    url = get_action_url.(conn)

    log_action!(repo, parent_timestamp, parent_id, url)

    conn
  end

  defp get_nil(_conn), do: nil
  defp get_current_url(conn), do: current_url(conn)
end
