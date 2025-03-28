# frozen_string_literal: true

require_relative 'has_links'

module Melanion
  class User
    include HasLinks

    attr_reader :id, :pronouns, :weblink

    def initialize(id:, names:, pronouns:, weblink:, location:, twitch:,
                   youtube:, twitter:, assets:, links:, **_other)
      @id = id
      @names = names
      @pronouns = pronouns
      @weblink = weblink
      @location = location
      @twitch = twitch
      @youtube = youtube
      @twitter = twitter
      @assets = assets
      @links = links
    end

    def name
      @names[:international]
    end

    def country
      @location.dig(:country, :names, :international)
    end

    def twitch
      @twitch&.dig(:uri)
    end

    def youtube
      @youtube&.dig(:uri)
    end

    def twitter
      @twitter&.dig(:uri)
    end

    def icon
      @assets.dig(:icon, :uri)
    end

    def self_api
      find_link('self')
    end

    def runs_api
      find_link('runs')
    end

    def pbs_api
      find_link('personal-bests')
    end
  end
end
