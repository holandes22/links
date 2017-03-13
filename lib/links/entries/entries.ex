defmodule Links.Entries do
  @moduledoc """
  The boundary for the Entries system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Links.Repo

  alias Links.Entries.{Link, Tag}

  @doc """
  Returns the list of links.

  ## Examples

      iex> list_links()
      [%Link{}, ...]

  """
  @filter_names ~w(archived)
  @filter_types %{archived: :boolean}

  def params_to_filters(params) do
    params
      |> Enum.filter(fn({key, value}) -> Enum.member?(@filter_names, key) && value != "" end)
      |> Enum.map(fn({key, value}) -> {String.to_existing_atom(key), value} end)
  end

  def link_query(params) do
    changeset =
      {%{}, @filter_types}
      |> cast(params, [:archived])

    case changeset.valid? do
      true ->
        filters = params_to_filters(params)
        from link in Link,
          where: ^filters,
          select: link,
          preload: [:tags]

      false ->
        from link in Link,
          preload: [:tags]
    end
  end

  def list_links(params \\ %{}) do
    params
      |> link_query()
      |> Repo.all()
  end

  @doc """
  Gets a single link.

  Raises `Ecto.NoResultsError` if the Link does not exist.

  ## Examples

      iex> get_link!(123)
      %Link{}

      iex> get_link!(456)
      ** (Ecto.NoResultsError)

  """
  def get_link!(id) do
    Link
    |> Repo.get!(id)
    |> Repo.preload(:tags)
  end

  @doc """
  Creates a link.

  ## Examples

      iex> create_link(link, %{field: value})
      {:ok, %Link{}}

      iex> create_link(link, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_link(attrs \\ %{}) do
    %Link{}
    |> link_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a link.

  ## Examples

      iex> update_link(link, %{field: new_value})
      {:ok, %Link{}}

      iex> update_link(link, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_link(%Link{} = link, attrs) do
    link
    |> link_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Link.

  ## Examples

      iex> delete_link(link)
      {:ok, %Link{}}

      iex> delete_link(link)
      {:error, %Ecto.Changeset{}}

  """
  def delete_link(%Link{} = link) do
    Repo.delete(link)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking link changes.

  ## Examples

      iex> change_link(link)
      %Ecto.Changeset{source: %Link{}}

  """
  def change_link(%Link{} = link) do
    link_changeset(link, %{})
  end

  defp link_changeset(%Link{} = link, attrs) do
    link
    |> Repo.preload(:tags)
    |> cast(attrs, [:archived, :notes, :link])
    |> put_assoc(:tags, parse_tags(attrs))
    |> validate_required([:archived, :link])
  end

  defp parse_tags(attrs) do
    (attrs[:tags] || attrs["tags"] || "")
    |> String.split(",")
    |> Enum.map(&normalize_tag/1)
    |> Enum.reject(& &1 == "")
    |> insert_and_get_all()
  end

  defp normalize_tag(tag) do
    tag
    |> String.trim()
    |> String.downcase()
  end

  defp insert_and_get_all([]), do: []
  defp insert_and_get_all(names) do
    maps = Enum.map(names, &%{name: &1})
    Repo.insert_all Tag, maps, on_conflict: :nothing
    Repo.all from t in Tag, where: t.name in ^names
  end

end
