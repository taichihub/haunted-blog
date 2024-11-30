# frozen_string_literal: true

module BlogsHelper
  def format_content(blog)
    sanitize(h(blog.content).gsub("\r\n|\r|\n/", '<br>'), tags: %w[br], attributes: [])
  end
end
