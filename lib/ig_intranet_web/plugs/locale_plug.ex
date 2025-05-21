defmodule IgIntranetWeb.Plugs.Locale do
  @moduledoc """
  Custom plug to deal with locale for static page.

  """
  import Plug.Conn

  @locales Gettext.known_locales(IgIntranetWeb.Gettext)

  def init(_opts), do: nil

  def call(%Plug.Conn{params: %{"locale" => locale}} = conn, _opts) when locale in @locales do
    conn |> get_session(:locale)
    Gettext.put_locale(IgIntranetWeb.Gettext, locale)

    # le put_session sert à persister le choix de la langue au changement de page
    conn |> put_session(:locale, locale)
  end

  def call(conn, _opts) do
    # on récupère l'éventuel choix de langue précédent
    locale = conn |> get_session(:locale) || "en"
    Gettext.put_locale(IgIntranetWeb.Gettext, locale)
    conn
  end
end

defmodule IgIntranetWeb.LiveLocale do
  @moduledoc """
  Custom plug to deal with locale for live page.

  """
  def on_mount(:default, %{"locale" => locale}, _session, socket) do
    Gettext.put_locale(IgIntranetWeb.Gettext, locale)
    {:cont, socket}
  end

  # catch-all case
  def on_mount(:default, _params, session, socket) do
    # on récupère l'éventuel choix de langue précédent
    Gettext.put_locale(IgIntranetWeb.Gettext, session["locale"] || "en")
    {:cont, socket}
  end
end
