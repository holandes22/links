defmodule Links.Web.Validator do
  import Ecto.Changeset

  def validate_url(changeset, field, _options \\ []) do
    validate_change changeset, field, fn(_, url) ->
      case url |> String.to_char_list |> :http_uri.parse do
        {:ok, _} -> []
        {:error, _message} -> [{field, "is an invalid URL"}]
      end
    end
  end

end
