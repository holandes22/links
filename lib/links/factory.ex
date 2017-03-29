defmodule Links.Factory do
  use ExMachina.Ecto, repo: Links.Repo

  alias Links.Entries.{Link,Tag,User}

  def link_factory do
    %Link{
      link: sequence(:link, &"http://a#{&1}.com"),
      tags: build_list(3, :tag),
      user: build(:user)
    }
  end

  def tag_factory do
    %Tag{
      name: sequence("tag")
    }
  end

  def user_factory do
    %User{
      email: sequence(:email, &"user#{&1}@email.com")
    }
  end
end
