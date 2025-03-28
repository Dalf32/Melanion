# frozen_string_literal: true

module Melanion
  class ApiResult
    attr_reader :value, :error

    def initialize(value: nil, error: nil)
      @value = value
      @error = error
    end

    def success?
      @error.nil?
    end

    def error?
      !success?
    end

    def empty?
      success? && @value.nil?
    end

    def value?
      success? && !@value.nil?
    end

    def self.success(val)
      ApiResult.new(value: val)
    end

    def self.error(err)
      err.is_a?(StandardError) ? ApiResult.new(error: err.message) : ApiResult.new(error: err)
    end
  end

  EmptyApiResult = ApiResult.new
end
