# frozen_string_literal: true

require_relative 'has_links'

module Melanion
  class Category
    include HasLinks

    INDIVIDUAL_LEVEL_TYPE = 'per-level'
    FULL_GAME_TYPE = 'per-game'

    attr_reader :id, :name, :weblink, :type, :rules

    def initialize(id:, name:, weblink:, type:, rules:, links:, **_other)
      @id = id
      @name = name
      @weblink = weblink
      @type = type
      @rules = rules
      @links = links
    end

    def individual_level?
      @type == INDIVIDUAL_LEVEL_TYPE
    end
    alias il? individual_level?

    def full_game?
      @type == FULL_GAME_TYPE
    end

    def self_api
      find_link('self')
    end

    def game_api
      find_link('game')
    end

    def records_api
      find_link('records')
    end
  end
end
