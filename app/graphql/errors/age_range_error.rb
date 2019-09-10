module Errors
  class AgeRangeError < BaseGraphqlError
    def initialize(message = 'Please provide an array with two integers or floating point numbers for ageRange.')
      super
    end
  end
end
