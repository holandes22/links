defmodule Links.ValidatorTest do
  use ExUnit.Case, async: true

  import Ecto.Changeset
  import Links.Web.Validator

  @valid_urls [
    "http://a.com",
    "http://a.b.com:80",
    "https://1.0.0.1:80",
    "http://www.my-domain.co.il/api/vvv-aa"
  ]
  @invalid_urls [
    "http://a:80.com",
    "htt://a.com"
  ]

  describe "validate_url" do

    test "with valid urls" do
      for url <- @valid_urls do
        changeset = cast({%{}, %{link: :string}}, %{"link" => url}, ~w(link))
        assert validate_url(changeset, :link).valid?
      end
    end

    test "with invalid urls" do
      for url <- @invalid_urls do
        changeset = cast({%{}, %{link: :string}}, %{"link" => url}, ~w(link))
        refute validate_url(changeset, :link).valid?
      end
    end

  end

end
