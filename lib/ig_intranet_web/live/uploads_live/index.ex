defmodule IgIntranetWeb.UploadLive do
  use IgIntranetWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <%= for err <- upload_errors(@uploads.file) do %>
      <span class="error">{error_to_string(err)}</span>
    <% end %>
    <form id="upload-form" phx-submit="save" phx-change="validate">
      <.live_file_input upload={@uploads.file} />
      <button type="submit">Upload</button>
    </form>
    <ul>
      <%= for entry <- @uploads.file.entries do %>
        <li>
          {entry.client_name}
          <button
            type="button"
            phx-click="cancel-upload"
            phx-value-ref={entry.ref}
            data-phx-upload-ref={entry.ref}
          >
            Cancel
          </button>
        </li>
      <% end %>
    </ul>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:file, accept: ~w(.jpg .jpeg .png), max_entries: 1)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :file, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    IO.inspect(socket.assigns)

    uploaded_files =
      consume_uploaded_entries(socket, :file, fn %{path: path}, _entry ->
        name = Path.basename(path)

        dest =
          Path.join(Application.app_dir(:ig_intranet, "priv/static/uploads"), name)

        # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
        case File.cp!(path, dest) do
          :ok ->
            IO.inspect(dest)
            attrs = %{name: name, path: dest}

            IgIntranet.Chats.create_upload(attrs)
            {:ok, ~p"/uploads/#{Path.basename(dest)}"}
        end
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
