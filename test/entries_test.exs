defmodule Links.EntriesTest do
  use Links.DataCase

  alias Links.Entries
  alias Links.Entries.Link

  @create_attrs %{archived: true, link: "http://a.com", notes: "some notes", csv_tags: "a-a,b-1,c"}
  @update_attrs %{archived: false, link: "http://b.com", notes: "some updated notes", csv_tags: "2,e"}
  @invalid_attrs %{archived: nil, link: nil, notes: nil, csv_tags: nil}
  @invalid_tags  [".a", "a-", "a_b", "#aa", "a.b", "a!", "a--b", "very-long-tag-about-functional-programming"]


  def fixture(:link, attrs \\ @create_attrs) do
    {:ok, link} = Entries.create_link(attrs)
    link
  end

  def filter_fixtures(_) do
    archived = fixture(:link, Map.merge(@create_attrs, %{archived: true}))
    unarchived = fixture(:link, Map.merge(@create_attrs, %{archived: false}))
    %{fixtures: [archived, unarchived]}
  end

  test "list_links/1 returns all links" do
    link = fixture(:link)
    assert Entries.list_links() == [link]
  end

  describe "list_links/1 filtering by archived" do
    setup [:filter_fixtures]

    for value <- [1, "aaa", "11", ""] do
      @value value

      test "list_links/1 returns all links if filter #{value}", %{fixtures: fixtures} do
        assert Entries.list_links(%{"archived" => @value}) == fixtures
      end
    end

    test "list_links/1 returns all links if params have invalid filter", %{fixtures: fixtures} do
      assert Entries.list_links(%{"fake" => "1"}) == fixtures
    end

    test "list_links/1 filtering by archive=true", %{fixtures: [archived | _tl]} do
      assert Entries.list_links(%{"archived" => "true", "aa" => 2}) == [archived]
    end

    test "list_links/1 filtering by archive=false", %{fixtures: [_hd | unarchived]} do
      assert Entries.list_links(%{"archived" => false}) == unarchived
    end

  end

  test "get_link! returns the link with given id" do
    link = fixture(:link)
    assert Entries.get_link!(link.id) == link
  end

  test "create_link/1 with valid data creates a link" do
    assert {:ok, %Link{} = link} = Entries.create_link(@create_attrs)

    assert link.archived == true
    assert link.link == @create_attrs.link
    assert link.notes == "some notes"
    assert Enum.map(link.tags, (& &1.name)) == ~w(a-a b-1 c)
  end

  test "create_link/1 with invalid urls returns error changeset" do
    invalid_urls = ["http://a:80.com", "htt://a.com"]

    for url <- invalid_urls do
      params =  Map.merge(@create_attrs, %{link: url})
      assert {:error, %Ecto.Changeset{} = changeset} = Entries.create_link(params)
      refute changeset.valid?
      assert [link: {"is an invalid URL", []}] = changeset.errors
    end

  end

  describe "create_link/1 with invalid tags returns error changeset" do
    for tag <- @invalid_tags do
      @invalid_tag tag

      test "if tag is #{tag}" do
        params =  Map.merge(@create_attrs, %{csv_tags: @invalid_tag})
        assert {:error, %Ecto.Changeset{errors: [tags: {msg, _}]}} = Entries.create_link(params)
        assert msg =~ "should only contain valid slugs"
      end
    end

    test "if more than 10 tags" do
      csv_tags = 1..11 |> Enum.map(&Integer.to_string/1) |> Enum.join(",")
      params =  Map.merge(@create_attrs, %{csv_tags: csv_tags})
      assert {:error, %Ecto.Changeset{errors: [tags: {msg, _}]}} = Entries.create_link(params)
      assert msg =~ "should have at most"
    end
  end

  test "create_link/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Entries.create_link(@invalid_attrs)
  end

  test "update_link/2 with valid data updates the link" do
    link = fixture(:link)
    assert {:ok, link} = Entries.update_link(link, @update_attrs)
    assert %Link{} = link

    assert link.archived == false
    assert link.link == @update_attrs.link
    assert link.notes == "some updated notes"
    assert Enum.map(link.tags, (& &1.name)) == ~w(2 e)
  end

  test "update_link/2 with invalid data returns error changeset" do
    link = fixture(:link)
    assert {:error, %Ecto.Changeset{}} = Entries.update_link(link, @invalid_attrs)
    assert link == Entries.get_link!(link.id)
  end

  test "delete_link/1 deletes the link" do
    link = fixture(:link)
    assert {:ok, %Link{}} = Entries.delete_link(link)
    assert_raise Ecto.NoResultsError, fn -> Entries.get_link!(link.id) end
  end

  test "change_link/1 returns a link changeset" do
    link = fixture(:link)
    assert %Ecto.Changeset{} = Entries.change_link(link)
  end
end
