defmodule IgIntranetWeb.Plugs.Locale do
  @moduledoc """
  blbl
  """
  import Plug.Conn

  @locales Gettext.known_locales(IgIntranetWeb.Gettext)
  def init(_opts), do: nil

  def call(%Plug.Conn{params: %{"locale" => locale}} = conn, _opts) when locale in @locales do
    Gettext.put_locale(IgIntranetWeb.Gettext, locale)
    conn |> put_session(:locale, locale)
  end

  def call(conn, _opts) do
    locale = conn |> get_session(:locale)
    Gettext.put_locale(IgIntranetWeb.Gettext, locale || "fr")
    conn
  end
end

defmodule IgIntranetWeb.LiveLocale do
  @locales Gettext.known_locales(IgIntranetWeb.Gettext)

  def on_mount(:default, %{"locale" => locale}, _session, socket) when locale in @locales do
    Gettext.put_locale(IgIntranetWeb.Gettext, locale)
    {:cont, socket}
  end

  # catch-all case
  def on_mount(:default, _params, session, socket) do
    # on récupère l'éventuel choix de langue précédent
    Gettext.put_locale(IgIntranetWeb.Gettext, session["locale"])
    {:cont, socket}
  end
end
