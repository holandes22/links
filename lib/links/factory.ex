defmodule Links.Factory do
  use ExMachina.Ecto, repo: Links.Repo

  alias Links.Entries.{Link, Tag}

  def link_factory do
    %Link{
      link: sequence(:link, &"http://a#{&1}.com"),
      tags: build_list(3, :tag)
    }
  end

  def tag_factory do
    %Tag{
      name: sequence("tag")
    }
  end
end
