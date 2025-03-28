# frozen_string_literal: true

module Melanion
  module HasLinks
    def find_link(link_name)
      @links.find { |link| link[:rel] == link_name }[:uri]
    end
  end
end
