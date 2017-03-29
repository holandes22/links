defmodule Links.Entries do
  import Ecto.{Query, Changeset}, warn: false

  alias Links.Repo
  alias Links.Entries.{Link, Tag, User}
  alias Links.Web.Validator

  @filter_types %{archived: :boolean, favorite: :boolean, tags: :string}


  defp filters(query, params, :tags) do
    tags = parse_tags(params, "tags")

    from link in query,
      join: tag in assoc(link, :tags),
      group_by: link.id,
      having: fragment("? <@ array_agg(?)", ^tags, tag.name)
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

  defp link_query(filters) do
    from(link in Link, distinct: link.id, preload: [:tags]) |> filters(filters)
  end

  def list_links(), do: list_links([filters: %{}])
  def list_links([filters: filters]), do: filters |> link_query() |> Repo.all()
  def list_links(user_id, opts \\ []) do
    filters = Keyword.get(opts, :filters, %{})
    from(link in link_query(filters), where: [user_id: ^user_id]) |> Repo.all()
  end

  def get_link!(id, user_id) do
    from(link in Link, where: [user_id: ^user_id])
    |> Repo.get!(id)
    |> Repo.preload(:tags)
  end

  def create_link(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:links)
    |> link_changeset(attrs)
    |> Repo.insert()
  end

  def update_link(%Link{} = link, attrs) do
    link
    |> link_changeset(attrs)
    |> Repo.update()
  end

  def delete_link(%Link{} = link) do
    Repo.delete(link)
  end

  def get_or_create_user(attrs) do
    filters = [email: attrs["email"] || attrs.email]
    query = from user in User, where: ^filters
    Repo.one(query) || create_user!(attrs)
  end

  def create_user(attrs) do
    %User{}
    |> user_changeset(attrs)
    |> Repo.insert()
  end
  def create_user!(attrs) do
    {:ok, user} = create_user(attrs)
    user
  end

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

  defp user_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
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
