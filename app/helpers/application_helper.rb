# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def title(name = "首页登录")
    tl = name.gsub("'", "\\\\'")
    content_for(:title){"#{tl} - "}
  end
end
