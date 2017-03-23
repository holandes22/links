defmodule Links.Entries do
  @moduledoc """
  The boundary for the Entries system.
  """

  import Ecto.{Query, Changeset}, warn: false

  alias Links.Repo
  alias Links.Entries.{Link, Tag}
  alias Links.Web.Validator

  @filter_types %{archived: :boolean, favorite: :boolean, tags: :string}


  defp filters(query, params, :tags) do
    tags = parse_tags(params, "tags")

    squery =
      from link in query,
        join: tag in assoc(link, :tags),
        group_by: link.id,
        select: %{id: link.id, tag_names: fragment("array_agg(?)", tag.name)}

    from sq in subquery(squery),
      join: link in Link, on: link.id == sq.id,
      where: fragment("? <@ ?", ^tags, sq.tag_names),
      select: link
  end
  defp filters(query, params, field_name) do
    case params[Atom.to_string(field_name)] do
      nil ->
        query
      value ->
        filters =  [{field_name, value}]
        from(link in query, where: ^filters)
    end
  end
  defp filters(query, params) do
    struct = {%{}, @filter_types}
    changesets = [
      {:archived, cast(struct, params, [:archived]) |> validate_required(:archived)},
      {:favorite, cast(struct, params, [:favorite]) |> validate_required(:favorite)},
      {:tags, cast(struct, params, [:tags]) |> validate_required([:tags])}
    ]

    Enum.reduce(changesets, query, fn({field_name, changeset}, query) ->
      if changeset.valid? do
        filters(query, params, field_name)
      else
        query
      end
    end)
  end

  defp link_query(params) do
    q = from(link in Link) |> filters(params)
    from(link in subquery(q), distinct: link.id, preload: [:tags])
  end

  @doc """
  Returns the list of links.

  ## Examples

      iex> list_links()
      [%Link{}, ...]

  """
  def list_links(params \\ %{}) do
    params |> link_query() |> Repo.all()
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
    changeset =
      link
      |> cast(attrs, [:archived, :favorite, :notes, :link])
      |> validate_required([:link])
      |> Validator.validate_url(:link)

    tags = parse_tags(attrs)

    case Enum.all?(tags, &valid_tag?/1) do
      true ->
        changeset
        |> put_assoc(:tags, insert_and_get_all(tags))
        |> validate_length(:tags, max: 10)
        |> put_csv_tags()

      false ->
        add_error(changeset, :tags, "should only contain valid slugs (not exceeding %{count} chars)", [count: 30])
    end

  end

  defp put_csv_tags(changeset) do
    case changeset.data.tags do
      %Ecto.Association.NotLoaded{} ->
        changeset
      tags ->
        csv_tags = Enum.map(tags, & &1.name) |> Enum.join(",")
        put_change(changeset, :csv_tags, csv_tags)
    end
  end

  defp valid_tag?(tag) do
    String.length(tag) <= 30 && Regex.match?(~r/^[a-z0-9]+(?:-[a-z0-9]+)*$/, tag)
  end

  defp parse_tags(attrs, key \\ "csv_tags") do
    (attrs[key] || attrs[String.to_existing_atom(key)] || "")
    |> String.split(",")
    |> Enum.map(&normalize_tag/1)
    |> Enum.reject(& &1 == "")
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
