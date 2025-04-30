defmodule IgIntranetWeb.ErrorJSONTest do
  use IgIntranetWeb.ConnCase, async: true

  test "renders 404" do
    assert IgIntranetWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert IgIntranetWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
