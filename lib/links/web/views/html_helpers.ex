defmodule Links.Web.HtmlHelpers do
  use Phoenix.HTML

  def info_message(%{"error" => msg}), do: message_html("negative", msg)
  def info_message(%{"info" => msg}), do: message_html("positive", msg)
  def info_message(%{}), do: ~E""

  defp message_html(type, message) do
    """
    <div class="ui #{type} message">
      <i class="close icon"></i>
      <div class="header">#{message}</div>
    </div>
    """ |> raw
  end

  def bool_to_string(value) do
    case value do
      true    -> "Yes"
      false   -> "No"
      "true"  -> "Yes"
      "false" -> "No"
      _       -> "All"
    end

  end

end
