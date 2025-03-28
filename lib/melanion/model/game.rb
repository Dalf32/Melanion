# frozen_string_literal: true

require_relative 'has_links'

module Melanion
  class Game
    include HasLinks

    attr_reader :id, :abbreviation, :weblink, :released, :release_date,
                :platforms, :developers, :publishers

    def initialize(id:, names:, abbreviation:, weblink:, released:,
                   release_date:, platforms:, developers:, publishers:,
                   assets:, links:, **_other)
      @id = id
      @names = names
      @abbreviation = abbreviation
      @weblink = weblink
      @released = released
      @release_date = release_date
      @platforms = platforms
      @developers = developers
      @publishers = publishers
      @assets = assets
      @links = links
    end

    def name
      @names[:international]
    end

    def logo
      @assets.dig(:logo, :uri)
    end

    def self_api
      find_link('self')
    end

    def categories_api
      find_link('categories')
    end

    def records_api
      find_link('records')
    end
  end
end
