defmodule Links.EntriesTest do
  use Links.DataCase

  alias Links.Entries
  alias Links.Entries.Link

  @create_attrs %{archived: true, link: "some link", notes: "some notes"}
  @update_attrs %{archived: false, link: "some updated link", notes: "some updated notes"}
  @invalid_attrs %{archived: nil, link: nil, notes: nil}

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

  describe "list_links/1 with filters" do
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
    assert link.link == "some link"
    assert link.notes == "some notes"
  end

  test "create_link/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Entries.create_link(@invalid_attrs)
  end

  test "update_link/2 with valid data updates the link" do
    link = fixture(:link)
    assert {:ok, link} = Entries.update_link(link, @update_attrs)
    assert %Link{} = link

    assert link.archived == false
    assert link.link == "some updated link"
    assert link.notes == "some updated notes"
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