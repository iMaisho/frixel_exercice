defmodule IgIntranetWeb.Components.FlopConfig do
  @moduledoc """
  Flop Config component Module
  """
  def table_opts do
    [
      table_attrs: [class: "w-[40rem] mt-11 sm:w-full"],
      thead_th_attrs: [class: "text-sm text-left leading-6 text-zinc-500 font-normal"],
      tbody_attrs: [
        class:
          "relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700"
      ],
      tbody_td_attrs: [class: "relative p-0 hover:cursor-pointer"],
      tbody_tr_attrs: [class: "group hover:bg-zinc-50"]
    ]
  end

  def pagination_opts do
    [
      wrapper_attrs: [class: "flex justify-between"],
      pagination_list_attrs: [class: ["flex gap-4 order-2"]],
      previous_link_attrs: [class: "order-1 hero-chevron-left-mini"],
      next_link_attrs: [class: "order-3 hero-chevron-right-mini"],
      page_links: {:ellipsis, 5}
    ]
  end

  use Phoenix.Component
  use Gettext, backend: IgIntranetWeb.Gettext

  attr :fields, :list, required: true
  attr :meta, Flop.Meta, required: true
  attr :id, :string, default: nil
  attr :on_change, :string, default: "update-filter"
  attr :target, :string, default: nil

  def filter_form(%{meta: meta} = assigns) do
    assigns = assign(assigns, form: Phoenix.Component.to_form(meta), meta: nil)

    ~H"""
    <.form for={@form} id={@id} phx-target={@target} phx-change={@on_change} phx-submit={@on_change}>
      <Flop.Phoenix.filter_fields :let={i} form={@form} fields={@fields}>
        <IgIntranetWeb.CoreComponents.input
          field={i.field}
          label={i.label}
          type={i.type}
          phx-debounce={120}
          {i.rest}
        />
      </Flop.Phoenix.filter_fields>

      <button class="button" name="reset">reset</button>
    </.form>
    """
  end

  def filter_form_fields() do
    [
      message_body: [op: :ilike_and],
      inserted_at: [label: gettext("Inserted after"), op: :>],
      conversation_topic: [op: :ilike_and],
      conversation_type: [
        type: "select",
        prompt: "",
        options: Ecto.Enum.values(IgIntranet.Chats.IntranetConversation, :conversation_type)
      ]
    ]
  end

  def select_conversation() do
    [

      conversation_topic: [
        type: "select",
        prompt: "",
        options: @topic_options      ]
    ]
  end
end
