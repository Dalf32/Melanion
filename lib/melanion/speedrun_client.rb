# frozen_string_literal: true

require 'json'
require 'open-uri'
require_relative 'model/api_result'
require_relative 'model/category'
require_relative 'model/game'
require_relative 'model/leaderboard'
require_relative 'model/run'
require_relative 'model/user'

module Melanion
  class SpeedrunClient
    def initialize(base_uri)
      @base_uri = base_uri
      @base_uri += '/' unless @base_uri.end_with?('/')
    end

    ##
    # Retrieves a Game by ID or from an existing Game object
    ##
    def game(game)
      game_url = game.is_a?(Game) ? game.self_api : "games/#{game}"
      game_hash = retrieve_data(build_url(game_url))

      ApiResult.success(Game.new(**game_hash[:data]))
    rescue StandardError => e
      ApiResult.error(e)
    end

    ##
    # Retrieves a Game by name, returning the best match found, if any
    ##
    def find_game(name)
      games_hash = retrieve_data(build_url('games', name: name))
      return EmptyApiResult if games_hash[:data].empty?

      ApiResult.success(Game.new(**games_hash[:data].first))
    rescue StandardError => e
      ApiResult.error(e)
    end

    ##
    # Retrieves a Category by ID or from an existing Category object
    ##
    def category(category)
      category_url = category.is_a?(Category) ? category.self_api : "categories/#{category}"
      category_hash = retrieve_data(build_url(category_url))

      ApiResult.success(Category.new(**category_hash[:data]))
    rescue StandardError => e
      ApiResult.error(e)
    end

    ##
    # Retrieves the list of Categories for the given Game object or ID,
    # optionally including miscellaneous Categories
    ##
    def categories(game, include_misc: false)
      categories_url = game.is_a?(Game) ? game.categories_api : "games/#{game}/categories"
      categories_hash = retrieve_data(
        build_url(categories_url, miscellaneous: include_misc ? 'yes' : 'no')
      )
      return EmptyApiResult if categories_hash[:data].empty?

      category_objs = categories_hash[:data]
                      .map { |cat_hash| Category.new(**cat_hash) }
      ApiResult.success(category_objs)
    rescue StandardError => e
      ApiResult.error(e)
    end

    ##
    # Retrieves a Category for the given Game object or ID by name, returning
    # an exact match if found
    ##
    def find_category(game, name)
      category_result = categories(game, include_misc: false)
      return category_result if category_result.error?

      all_categories = category_result.value
      category_result = categories(game, include_misc: true)
      return category_result if category_result.error?

      all_categories += category_result.value
      found_category = all_categories.find { |cat| cat.name.casecmp?(name) }
      return EmptyApiResult if found_category.nil?

      ApiResult.success(found_category)
    end

    ##
    # Retrieves the main Category for the given Game object or ID, optionally
    # restricting to full game Categories only
    ##
    def main_category(game, full_game: true)
      category_result = categories(game, include_misc: false)
      return category_result unless category_result.value?

      found_category = full_game ? category_result.value.find(&:full_game?) : category_result.value.first
      ApiResult.success(found_category)
    end

    ##
    # Retrieves the podium Runs for the given Category object or ID, returned
    # within a Leaderboard object
    ##
    def category_records(category)
      records_url = category.is_a?(Category) ? category.records_api : "categories/#{category}/records"
      records_hash = retrieve_data(build_url(records_url))
      return EmptyApiResult if records_hash[:data].empty?

      records_objs = records_hash[:data]
                     .map { |rec_hash| Leaderboard.new(**rec_hash) }
      ApiResult.success(records_objs)
    rescue StandardError => e
      ApiResult.error(e)
    end

    ##
    # Retrieves a User by ID or from an existing User object
    ##
    def user(user)
      user_url = user.is_a?(User) ? user.self_api : "users/#{user}"
      user_hash = retrieve_data(build_url(user_url))

      ApiResult.success(User.new(**user_hash[:data]))
    rescue StandardError => e
      ApiResult.error(e)
    end

    ##
    # Retrieves the posted Runs for a given User object or ID
    ##
    def user_runs(user)
      runs_url = user.is_a?(User) ? build_url(user.runs_api) : build_url('runs', user: user)
      runs_hash = retrieve_data(runs_url)
      return EmptyApiResult if runs_hash[:data].empty?

      runs_objs = runs_hash[:data].map { |run_hash| Run.new(**run_hash) }
      ApiResult.success(runs_objs)
    rescue StandardError => e
      ApiResult.error(e)
    end

    ##
    # Retrieves the personal best Runs for a given User object or ID
    ##
    def user_pbs(user)
      pbs_url = user.is_a?(User) ? user.pbs_api : "users/#{user}/personal-bests"
      runs_hash = retrieve_data(build_url(pbs_url))
      return EmptyApiResult if runs_hash[:data].empty?

      runs_objs = runs_hash[:data]
                  .map { |run_hash| Run.new(place: run_hash[:place], **run_hash[:run]) }
      ApiResult.success(runs_objs)
    rescue StandardError => e
      ApiResult.error(e)
    end

    private

    def build_url(path, **query_params)
      query_param_text = query_params.map { |k, v| "#{k}=#{v}" }.join('&')

      url = path.start_with?(@base_uri) ? path : @base_uri + path.delete_prefix('/')
      url += "?#{query_param_text}" unless query_param_text.empty?
      url
    end

    def retrieve_data(request_url)
      data_raw = URI.open(request_url)
      symbolize_keys(JSON.parse(data_raw.readlines.join))
    end

    def symbolize_keys(hash)
      case hash
        when Hash
          hash.each_with_object({}) { |(k, v), h| h[k.gsub('-', '_').to_sym] = symbolize_keys(v) }
        when Array
          hash.map { |v| symbolize_keys(v) }
        else
          hash
      end
    end
  end
end
