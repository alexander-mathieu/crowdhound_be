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
      User.find(id)
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
        raise 'Please provide an array with two integers or floating point numbers.' unless filters[:age_range].count == 2
        filters[:birthdate] = (Time.zone.now - (filters[:age_range].max * 1.year.seconds) - 1.years.seconds)..(Time.zone.now - (filters[:age_range].min * 1.year.seconds))
        filters.except!(:age_range)
      end

      if filters[:activity_level_range]
        raise 'Please provide an array with two integers.' unless filters[:activity_level_range].count == 2
        filters[:activity_level] = filters[:activity_level_range].min..filters[:activity_level_range].max
        filters.except!(:activity_level_range)
      end

      if filters[:weight_range]
        raise 'Please provide an array with two integers.' unless filters[:weight_range].count == 2
        filters[:weight] = filters[:weight_range].min..filters[:weight_range].max
        filters.except!(:weight_range)
      end

      Dog.where(filters)
    end

    field :dog, Types::DogType, null: false,
      description: 'Find a dog by ID' do
      argument :id, ID, required: true
    end

    def dog(id:)
      Dog.find(id)
    end
  end
end
