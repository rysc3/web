class Link < ApplicationRecord
  validates :title, presence: true
  validates :description, presence: true

  def parsed_body
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(body).html_safe
  end
end
