module Mutations
  class CreateDog < BaseMutation
    null true

    argument :dog, Types::DogInput, required: true

    field :dog, Types::DogType, null: true

    def resolve(dog:)
      boot_unauthenticated_user

      new_dog = Dog.create!(
        user: context[:current_user],
        name: dog[:name],
        activity_level: dog[:activity_level],
        weight: dog[:weight],
        breed: dog[:breed],
        birthdate: dog[:birthdate],
        short_desc: dog[:short_desc],
        long_desc: dog[:long_desc]
      )

      { dog: new_dog }
    end
  end
end
