module Helpers
  class DogsQueryFilterer
    def initialize(filters, current_user)
      @activity_level_range = filters[:activity_level_range]
      @age_range = filters[:age_range]
      @breed = filters[:breed]
      @max_distance = filters[:max_distance]
      @weight_range = filters[:weight_range]
      @current_user = current_user
    end

    def results
      validate_input
      if @current_user && @current_user.location
        dogs = Dog.sorted_by_distance(@current_user).where(filters)
        dogs = dogs_within_max_distance(dogs) if @max_distance
      else
        dogs = Dog.order(:id).where(filters)
      end
      dogs
    end

    private

    def validate_input
      raise Errors::ActivityLevelRangeError if @activity_level_range && @activity_level_range.count != 2
      raise Errors::WeightRangeError if @weight_range && @weight_range.count != 2
      raise Errors::AgeRangeError if @age_range && @age_range.count != 2
    end

    def filters
      filters = {}
      filters[:activity_level] = activity_level_range if @activity_level_range
      filters[:birthdate] = birthdate_range if @age_range
      filters[:weight] = weight_range if @weight_range
      filters[:breed] = @breed if @breed
      filters
    end

    def activity_level_range
      [ @activity_level_range.min..@activity_level_range.max ]
    end

    def birthdate_range
      one_year = 1.year.seconds
      beginning_date = Time.zone.now - (@age_range.max * one_year) - one_year
      end_date = Time.zone.now - (@age_range.min * one_year)
      [ beginning_date..end_date ]
    end

    def weight_range
      [ @weight_range.min..@weight_range.max ]
    end

    def dogs_within_max_distance(dogs)
      dogs.find_all do |dog|
        dog.distance <= @max_distance
      end
    end
  end
end
