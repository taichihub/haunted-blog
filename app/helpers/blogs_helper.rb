# frozen_string_literal: true

module BlogsHelper
  def format_content(blog)
    sanitize(h(blog.content).gsub("\n", '<br>'), tags: %w[br], attributes: [])
  end
end
