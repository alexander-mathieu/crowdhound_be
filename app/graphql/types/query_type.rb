module Types
  class QueryType < Types::BaseObject
    # User Queries
    field :users, [Types::UserType], null: false,
      description: 'Return all users'

    def users
      User.all
    end

    field :user, Types::UserType, null: false,
      description: 'Find a user by ID' do
      argument :id, ID, required: true
    end

    def user(id:)
      begin
        User.find(id)
      rescue ActiveRecord::RecordNotFound => e
        raise GraphQL::ExecutionError, e.message
      end
    end

    field :current_user, Types::CurrentUserType, null: true,
      description: 'Get information for the current user (based on the googleToken in the params)' do
    end

    def current_user
      context[:current_user]
    end

    # Dog Queries
    field :dogs, [Types::DogType], null: false,
      description: 'Return all dogs, or all dogs filtered by attribute' do
        argument :activity_level_range, [Int], required: false
        argument :age_range, [Float], required: false
        argument :breed, [String], required: false
        argument :weight_range, [Int], required: false
      end

    def dogs(**filters)
      if filters[:age_range]
        raise GraphQL::ExecutionError, 'Please provide an array with two integers or floating point numbers for ageRange.' unless filters[:age_range].count == 2

        one_year = 1.year.seconds
        beginning_date = Time.zone.now - (filters[:age_range].max * one_year) - one_year
        end_date = Time.zone.now - (filters[:age_range].min * one_year)

        filters[:birthdate] = beginning_date..end_date
        filters.delete(:age_range)
      end

      if filters[:activity_level_range]
        raise GraphQL::ExecutionError, 'Please provide an array with two integers for activityLevelRange.' unless filters[:activity_level_range].count == 2
        filters[:activity_level] = filters[:activity_level_range].min..filters[:activity_level_range].max
        filters.delete(:activity_level_range)
      end

      if filters[:weight_range]
        raise GraphQL::ExecutionError, 'Please provide an array with two integers for weightRange.' unless filters[:weight_range].count == 2
        filters[:weight] = filters[:weight_range].min..filters[:weight_range].max
        filters.delete(:weight_range)
      end

      dogs = if current_user && current_user.location
               Dog.sorted_by_distance
             else
               Dog.all
             end

      dogs.where(filters)
    end

    field :dog, Types::DogType, null: false,
      description: 'Find a dog by ID' do
      argument :id, ID, required: true
    end

    def dog(id:)
      begin
        Dog.find(id)
      rescue ActiveRecord::RecordNotFound => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
