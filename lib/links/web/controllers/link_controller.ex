defmodule Links.Web.LinkController do
  use Links.Web, :controller

  alias Links.Entries

  def index(%Plug.Conn{assigns: %{filters: filters}} = conn, _params) when filters == %{} do
    links = Entries.list_links()
    render(conn, "index.html", links: links, filters: nil)
  end
  def index(%Plug.Conn{assigns: %{filters: filters}} = conn, _params) do
    links = Entries.list_links(filters)
    render(conn, "index.html", %{links: links, filters: filters})
  end

  def clear_filters(conn, _params) do
    conn
    |> put_session(:filters, "{}")
    |> redirect(to: link_path(conn, :index))
  end

  def new(conn, _params) do
    changeset = Entries.change_link(%Links.Entries.Link{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"link" => link_params}) do
    case Entries.create_link(link_params) do
      {:ok, _link} ->
        conn
        |> put_flash(:info, "Link created successfully.")
        |> redirect(to: link_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    link = Entries.get_link!(id)
    changeset = Entries.change_link(link)
    render(conn, "edit.html", link: link, changeset: changeset)
  end

  def update(conn, %{"id" => id, "link" => link_params}) do
    link = Entries.get_link!(id)

    case Entries.update_link(link, link_params) do
      {:ok, _link} ->
        conn
        |> put_flash(:info, "Link updated successfully.")
        |> redirect(to: link_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", link: link, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    link = Entries.get_link!(id)
    {:ok, _link} = Entries.delete_link(link)

    conn
    |> put_flash(:info, "Link deleted successfully.")
    |> redirect(to: link_path(conn, :index))
  end
end
