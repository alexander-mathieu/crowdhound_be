module Errors
  class ActivityLevelRangeError < BaseGraphqlError
    def initialize(message = 'Please provide an array with two integers for activityLevelRange.')
      super
    end
  end
end
