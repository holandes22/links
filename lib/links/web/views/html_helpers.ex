defmodule Links.Web.HtmlHelpers do
  use Phoenix.HTML

  def info_message(%{"error" => msg}), do: message_html("error", msg)
  def info_message(%{"info" => msg}), do: message_html("info", msg)
  def info_message(%{}), do: ~E""

  defp message_html(type, message) do
    """
    <div class="ui #{type} message">
      <i class="close icon"></i>
      <p>#{message}</p>
    </div>
    """ |> raw
  end


end
