defmodule IgIntranetWeb.Plugs.Locale do
  @moduledoc """
  blbl
  """
  import Plug.Conn

  @locales Gettext.known_locales(IgIntranetWeb.Gettext)
  def init(_opts), do: nil

  def call(%Plug.Conn{params: %{"locale" => locale}} = conn, _opts) when locale in @locales do
    Gettext.put_locale(IgIntranetWeb.Gettext, locale)
    conn
  end

  def call(conn, _opts), do: conn
end
