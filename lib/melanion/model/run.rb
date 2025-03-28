# frozen_string_literal: true

module Melanion
  class Run
    attr_reader :place, :id, :weblink, :game, :level, :category, :comment,
                :players, :date

    def initialize(place: nil, id:, weblink:, game:, level:, category:, videos:,
                   comment:, players:, date:, times:, **_other)
      @place = place
      @id = id
      @weblink = weblink
      @game = game
      @level = level
      @category = category
      @videos = videos
      @comment = comment
      @players = players.map { |player| player[:id] }
      @date = date
      @times = times
    end

    def video
      @videos.dig(:links, 0, :uri)
    end

    def time
      @times[:primary]
    end
  end
end
