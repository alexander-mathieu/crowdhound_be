module Types
  class QueryType < Types::BaseObject
    # User Queries
    field :users, [Types::UserType], null: false,
      description: 'Return all users'

    def users
      User.order(:id)
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
      description: 'Get information for the current user (based on the token in the params)' do
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
        argument :max_distance, Int, required: false
      end

    def dogs(**filters)
      Helpers::DogsQueryFilterer.new(filters, current_user).results
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
