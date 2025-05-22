defmodule IgIntranet.Chats do
  @moduledoc """
  The Chats context.
  """

  import Ecto.Query, warn: false
  alias IgIntranet.Repo

  alias IgIntranet.Chats.IntranetConversation
  alias IgIntranet.Chats

  @doc """
  Returns the list of intranet_conversations.

  ## Examples

      iex> list_intranet_conversations()
      [%IntranetConversation{}, ...]

  """
  def list_intranet_conversations do
    Repo.all(IntranetConversation)
  end

  @doc """
  Returns the list of intranet_conversations with the intranet_messages associated.
  ## Examples
      iex> intranet_conversation_with_preload()
      [%intranet_conversation{...intranet_message{}}, ...]
  """
  def list_intranet_conversation_with_preload do
    IntranetConversation
    |> order_by([conv], asc: conv.inserted_at)
    |> Repo.all()
    |> Repo.preload(:intranet_messages)
  end

  def list_intranet_conversation_filter_with_preload(filter) do
    filter = "#{filter}%"

    IntranetConversation
    |> where([conv], ilike(conv.conversation_topic, ^filter))
    |> order_by([conv], desc: conv.inserted_at)
    |> Repo.all()
    |> Repo.preload(:intranet_messages)
  end

  def list_conversations_with_flop(params) do
    IntranetConversation
    |> join(:left, [ic], im in assoc(ic, :intranet_messages), as: :intranet_messages)
    |> preload([intranet_messages: im], intranet_messages: im)
    |> Flop.validate_and_run(params,
      for: IntranetConversation,
      replace_invalid_params: true
    )
  end

  @doc """
  Gets a single intranet_conversation.

  Raises `Ecto.NoResultsError` if the Intranet conversation does not exist.

  ## Examples

      iex> get_intranet_conversation!(123)
      %IntranetConversation{}

      iex> get_intranet_conversation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_intranet_conversation!(id), do: Repo.get!(IntranetConversation, id)

  def get_intranet_conversation_with_preload!(id),
    do:
      Repo.get!(IntranetConversation, id)
      |> Repo.preload(:intranet_messages)

  @doc """
  Creates a intranet_conversation.

  ## Examples

      iex> create_intranet_conversation(%{field: value})
      {:ok, %IntranetConversation{}}

      iex> create_intranet_conversation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_intranet_conversation(attrs \\ %{}) do
    %IntranetConversation{}
    |> IntranetConversation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a intranet_conversation.

  ## Examples

      iex> update_intranet_conversation(intranet_conversation, %{field: new_value})
      {:ok, %IntranetConversation{}}

      iex> update_intranet_conversation(intranet_conversation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_intranet_conversation(%IntranetConversation{} = intranet_conversation, attrs) do
    intranet_conversation
    |> IntranetConversation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a intranet_conversation.

  ## Examples

      iex> delete_intranet_conversation(intranet_conversation)
      {:ok, %IntranetConversation{}}

      iex> delete_intranet_conversation(intranet_conversation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_intranet_conversation(%IntranetConversation{} = intranet_conversation) do
    Repo.delete(intranet_conversation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking intranet_conversation changes.

  ## Examples

      iex> change_intranet_conversation(intranet_conversation)
      %Ecto.Changeset{data: %IntranetConversation{}}

  """
  def change_intranet_conversation(%IntranetConversation{} = intranet_conversation, attrs \\ %{}) do
    IntranetConversation.changeset(intranet_conversation, attrs)
  end

  def preload_intranet_messages(intranet_conversation) do
    Repo.preload(intranet_conversation, :intranet_messages)
  end

  alias IgIntranet.Chats.IntranetMessage

  @doc """
  Returns the list of intranet_messages.

  ## Examples

      iex> list_intranet_messages()
      [%IntranetMessage{}, ...]

  """
  def list_intranet_messages do
    Repo.all(IntranetMessage)
  end

  @doc """
  Returns the list of intranet_messages with the intranet_conversation associated.
  ## Examples
      iex> list_intranet_message_with_preload()
      [%list_intranet_message{...intranet_message{}}, ...]
  """
  def list_intranet_message_with_preload do
    IntranetMessage
    |> order_by([message], desc: message.inserted_at)
    |> Repo.all()
    |> Repo.preload(:intranet_conversation)
    |> Repo.preload(:sender)
    |> Repo.preload(:recipient)
  end

  def list_intranet_message_by_conversation_id(id) do
    IntranetMessage
    |> where([m], m.intranet_conversation_id == ^id)
    |> order_by([m], desc: m.inserted_at)
    |> Repo.all()
  end

  def list_messages_with_flop(params) do
    IntranetMessage
    |> join(:left, [im], ic in assoc(im, :intranet_conversation), as: :intranet_conversations)
    |> preload([intranet_conversations: ic], intranet_conversation: ic)
    |> order_by([message], desc: message.inserted_at)
    |> Flop.validate_and_run(params,
      for: IntranetMessage,
      replace_invalid_params: true
    )
  end

  @doc """
  Gets a single intranet_message.

  Raises `Ecto.NoResultsError` if the Intranet message does not exist.

  ## Examples

      iex> get_intranet_message!(123)
      %IntranetMessage{}

      iex> get_intranet_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_intranet_message!(id), do: Repo.get!(IntranetMessage, id)

  def get_intranet_message_with_preload!(id),
    do:
      Repo.get!(IntranetMessage, id)
      |> Repo.preload(:intranet_conversation)

  @doc """
  Creates a intranet_message.

  ## Examples

      iex> create_intranet_message(%{field: value})
      {:ok, %IntranetMessage{}}

      iex> create_intranet_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_intranet_message(attrs \\ %{}) do
    %IntranetMessage{}
    |> IntranetMessage.changeset(attrs)
    |> Repo.insert()
    |> Chats.broadcast(:message_created)
  end

  @doc """
  Updates a intranet_message.

  ## Examples

      iex> update_intranet_message(intranet_message, %{field: new_value})
      {:ok, %IntranetMessage{}}

      iex> update_intranet_message(intranet_message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_intranet_message(%IntranetMessage{} = intranet_message, attrs) do
    intranet_message
    |> IntranetMessage.changeset(attrs)
    |> Repo.update()
    |> Chats.broadcast(:message_updated)
  end

  @doc """
  Deletes a intranet_message.

  ## Examples

      iex> delete_intranet_message(intranet_message)
      {:ok, %IntranetMessage{}}

      iex> delete_intranet_message(intranet_message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_intranet_message(%IntranetMessage{} = intranet_message) do
    Repo.delete(intranet_message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking intranet_message changes.

  ## Examples

      iex> change_intranet_message(intranet_message)
      %Ecto.Changeset{data: %IntranetMessage{}}

  """
  def change_intranet_message(%IntranetMessage{} = intranet_message, attrs \\ %{}) do
    IntranetMessage.changeset(intranet_message, attrs)
  end

  def preload_intranet_conversation(intranet_message) do
    Repo.preload(intranet_message, :intranet_conversation)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(IgIntranet.PubSub, "messages")
  end

  def broadcast({:error, _reason} = error, _event), do: error

  def broadcast({:ok, message}, event) do
    Phoenix.PubSub.broadcast(IgIntranet.PubSub, "messages", {event, message})
    {:ok, message}
  end
end
