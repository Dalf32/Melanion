# frozen_string_literal: true

require_relative 'has_links'
require_relative 'run'

module Melanion
  class Leaderboard
    include HasLinks

    attr_reader :weblink, :game, :category, :level, :platform, :runs

    def initialize(weblink:, game:, category:, level:, platform:, runs:, links:,
                   **_other)
      @weblink = weblink
      @game = game
      @category = category
      @level = level
      @platform = platform
      @runs = runs.map { |run| Run.new(place: run[:place], **run[:run]) }
      @links = links
    end

    def game_api
      find_link('game')
    end

    def category_api
      find_link('category')
    end
  end
end
