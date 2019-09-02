module Types
  class QueryType < Types::BaseObject
    # User Queries
    field :users, [Types::UserType], null: false,
      description: "Return all users"

    def users
      User.all
    end

    field :user, Types::UserType, null: false,
      description: "Find a user by id" do
      argument :id, ID, required: true
    end

    def user(id:)
      User.find(id)
    end

    # Dog Queries
    field :dogs, [Types::DogType], null: false,
      description: "Return all dogs"

    def dogs
      Dog.all
    end

    field :dog, Types::DogType, null: false,
      description: "Find a dog by id" do
      argument :id, ID, required: true
    end

    def dog(id:)
      Dog.find(id)
    end
  end
end
