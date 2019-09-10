module Errors
  class WeightRangeError < BaseGraphqlError
    def initialize(message = 'Please provide an array with two integers for weightRange.')
      super
    end
  end
end
