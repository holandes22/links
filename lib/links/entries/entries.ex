defmodule Links.Entries do
  @moduledoc """
  The boundary for the Entries system.
  """

  import Ecto.{Query, Changeset}, warn: false

  alias Links.Repo
  alias Links.Entries.{Link, Tag}
  alias Links.Web.Validator

  @filter_names ~w(archived)
  @filter_types %{archived: :boolean, tags: :string}


  defp filters(query, params, :fields) do
    changeset = cast({%{}, @filter_types}, params, [:archived])

    if changeset.valid? do
      filters =
        params
        |> Enum.filter(fn({key, value}) -> Enum.member?(@filter_names, key) && value != "" end)
        |> Enum.map(fn({key, value}) -> {String.to_existing_atom(key), value} end)
      from(q in query, where: ^filters)
    else
      query
    end
  end
  defp filters(query, params, :tags) do
    changeset =
      {%{}, @filter_types}
      |> cast(params, [:tags])
      |> validate_required([:tags])

    if changeset.valid? do
      tags = parse_tags(params, "tags")
      from q in query,
        join: tag in assoc(q, :tags),
        where: tag.name in ^tags
    else
      query
    end
  end

  defp link_query(params) do
    from(link in Link, distinct: link.id, preload: [:tags])
    |> filters(params, :fields)
    |> filters(params, :tags)
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
      |> cast(attrs, [:archived, :notes, :link])
      |> validate_required([:archived, :link])
      |> Validator.validate_url(:link)

    tags = parse_tags(attrs)

    case Enum.all?(tags, &valid_tag?/1) do
      true ->
        changeset
        |> put_assoc(:tags, insert_and_get_all(tags))
        |> validate_length(:tags, max: 10)

      false ->
        add_error(changeset, :tags, "should only contain valid slugs (not exceeding %{count} chars)", [count: 30])
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
