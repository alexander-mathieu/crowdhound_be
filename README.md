# CrowdHound

## About

Welcome to _CrowdHound_!

The deployed site's endpoints can be consumed at:

https://crowdhound-be.herokuapp.com/

## Endpoints

_CrowdHound_ utilizes [GraphQL](https://graphql.org/). All queries are made to a single endpoint, `POST /graphql`. This endpoint will always return 200 (OK), even if there is an error. If there is an error, it will be present in an `errors` attribute of the response, and the `data` attribute will be `null`.

### Authentication

To make queries or mutations as a logged-in user, include that user's token as a `token` query param.

### Object Types

Object types are templates for resources in the database.  Each object type has a list of attributes that are available to return along with the object.

#### CurrentUserType Attributes

* id - ID (Int, required)
* firstName - String
* lastName - String
* email - String
* shortDesc - String
* longDesc - String
* dogs - [ DogType ]
* photos - [ PhotoType ]
* location - [ LocationType ]

#### DogType Attributes

* id - ID (Int, required)
* age - Float
* name - String
* breed - String
* birthdate - String
* weight - Int
* shortDesc - String
* longDesc - String
* activityLevel - Int
* distance - Float (in miles, null if the current user or queried dog's user does not have a location defined)
* user - UserType
* photos - [ PhotoType ]

#### LocationType Attributes

* id - ID (Int, required)
* streetAddress - String
* city - String
* state - String
* zipCode - String
* lat - Float
* long - Float

#### PhotoType Attributes

* id
* sourceUrl

#### UserType Attributes

* id - ID (Int, required)
* firstName - String
* shortDesc - String
* longDesc - String
* distance - Float (in miles, null if the current user or queried user does not have a location defined)
* dogs - [ DogType ]
* photos - [ PhotoType ]

#### AuthenticationInputType Attributes

* firstName - String (required)
* lastName - String (required)
* email - String (required)

#### DogInputType Attributes

* name - String (required)
* breed - String (required)
* birthdate - String (required)
* weight - Int (in lb, required)
* activityLevel - Int (0, 1, or 2, required)
* shortDesc - String
* longDesc - String

#### LocationInputType Attributes

* streetAddress - String
* city - String
* state - String
* zipCode - String (required)

#### UserInputType Attributes

* firstName - String
* lastName - String
* shortDesc - String
* longDesc - String

#### PhotoInputType Attributes

* photoableType - String ("User" or "Dog", required)
* photoableId - Integer (required)
* caption - String

### Queries

#### users

Returns an array of all users with requested attributes.

Example request body:
```
{
  users {
    id
    firstName
    shortDesc
    longDesc
    dogs {
      id
      name
      breed
      birthdate
      weight
      activityLevel
      shortDesc
      longDesc
    }
  }
}
```

Example of expected output:
```
{
  "data": {
    "users": [
      {
        "id": "11",
        "firstName": "Katheleen",
        "shortDesc": "Yr kogi street yuccie meditation offal venmo dreamcatcher blog roof heirloom sustainable paleo umami synth.",
        "longDesc": "Wolf kombucha pop-up cornhole venmo vinegar. Literally letterpress flexitarian listicle swag williamsburg. Disrupt asymmetrical cray waistcoat tacos ennui bitters. Letterpress try-hard small batch 8-bit diy flannel chia vegan. Drinking fashion axe chicharrones shoreditch cray literally poutine pbr&b. Twee pbr&b single-origin coffee waistcoat helvetica art party hashtag try-hard. Church-key poutine locavore trust fund. Occupy hoodie jean shorts godard. Polaroid ethical before they sold out aesthetic microdosing. Blog green juice leggings retro forage helvetica franzen craft beer.",
        "dogs": [
          {
            "id": "15",
            "name": "Illustrious Lizard",
            "breed": "Malamute",
            "birthdate": "2014-12-07",
            "weight": 110,
            "activityLevel": 1,
            "shortDesc": "Don't worry. As long as you hit that wire with the connecting hook at precisely 88 miles per hour, the instant the lightning strikes the tower... everything will be fine.",
            "longDesc": "Sint adipisci non. Esse iusto praesentium. Modi itaque sit. Sed doloremque suscipit. Vero sit debitis. Ut aperiam rerum. Incidunt id est. Voluptatem qui laborum."
          },
          {
            "id": "16",
            "name": "Gravity Claw",
            "breed": "Appenzeller",
            "birthdate": "1980-11-14",
            "weight": 59,
            "activityLevel": 0,
            "shortDesc": "If you put your mind to it, you can accomplish anything.",
            "longDesc": "Facilis illum eum. Ut et enim. Placeat nemo ut. Soluta molestias eligendi. Quidem et et. Culpa hic doloribus. Quo labore et. Nobis ab enim."
          }
        ]
      }
    ]
  }
}
```

#### user(id: <ID>)

Returns a single user having the specified ID. *ID argument is required.*

#### currentUser

Returns an authenticated user, based on the specified token. Returns null if no user has the specified token. Has additional information not available in the basic user query, such as lastName, email and location.

#### dogs(<filters>)

Returns a collection of dogs, with the option to filter by comma separated arguments. If the request is authenticated, the dogs are sorted by distance to the authenticated user.

Available arguments are:
* activityLevelRange: <Array with two integer values, denoting the minimum and maximum acceptable activity level>
  * _i.e. activityLevelRange: [0, 2]_
* ageRange: <Array with two integer or float values, denoting the minimum and maximum acceptable age in years>
  * _i.e. ageRange: [2, 4.5]_
* breed: <Array of comma separated strings, denoting the acceptable breeds>
  * _i.e. breed: ["Rat Terrier", "German Shepherd"]_
* maxDistance: <Int>
* weightRange: <Array with two integer values, denoting the minimum and maximum acceptable weight in pounds>
 * _i.e. weightRange: [20, 40]_

Filters may be used in any combination. For fields where only a single value is desired, enter the same value twice.
* _i.e. ageRange: [2, 2]_

#### dog(id: <ID>)

Returns a single dog having the specified ID. *id: argument is required.*

### Mutations

Mutations are requests to modify resources in the database.

#### authenticateUser(auth: <AuthenticationInputType>, apiKey: <String>)

Finds or creates a user in the database. Returns a CurrentUserType object, as well as a boolean attribute `new`, based on whether or not the user was found or created. Required arguments include:
* apiKey - String (used to ensure that requests only come from the Express app -- not random HTTP requests)
* auth - AuthenticationInputType

Example request:
```
mutation {
  authenticateUser(
    apiKey: <EXPRESS API KEY>,
    auth: {
      firstName: "Bob",
      lastName: "Smith III",
      email: "bobsmithiii@bs.com"
    }
  ) {
    currentUser {
      id
      firstName
      lastName
      email
    }
    new
    token
  }
}
```

Example of expected response:
```
{
  "data": {
    "authenticateUser": {
      "currentUser": {
        "id": "26",
        "firstName": "Bob",
        "lastName": "Smith III",
        "email": "bobsmithiii@bs.com"
      },
      "new": true
      "token": "6f5f36f48e637a04e428ba12b930f301"
    }
  }
}
```

#### logOutUser

Logs out a user based on the specified `token` query parameter. A successful request returns a `message` attribute.

Example request:
```
mutation {
  logOutUser
  {
    message
  }
}
```

Expected response:
```
{
  "data": {
    "logOutUser": {
      "message": "User has been logged out"
    }
  }
}
```

#### createLocation(location: <LocationInputType>)

Adds a location for the user with the `token` specified in the query parameter. Requires a LocationInputType argument. A successful response returns a LocationType object.

Example request:
```
mutation {
  createLocation(
    location: {
      streetAddress: "1331 17th Street",
      city: "Denver",
      state: "CO",
      zipCode: "80202"
    }
  ) {
    location {
      id
      streetAddress
      city
      state
      zipCode
    }
  }
}
```

Example of expected response:
```
{
  "data": {
    "createLocation": {
      "location": {
        "id": "10",
        "streetAddress": "1331 17th Street",
        "city": "Denver",
        "state": "CO",
        "zipCode": "80202"
      }
    }
  }
}
```

#### createDog(dog: <DogInputType>)

Creates a dog in the database for the current user (based on the `token` in the params). Requires a DogInputType argument. Returns a DogType object.

Example request:
```
mutation {
  createDog(
    dog: {
      name: "Lil Fluff",
      activityLevel: 2,
      breed: "Shih Tzu",
      weight: 12,
      birthdate: "2019-08-11"
    }
  ) {
    dog {
      id
      name
      age
    }
  }
}
```

Example of expected response:
```
{
  "data": {
    "createDog": {
      "dog": {
        "id": "36",
        "name": "Lil Fluff",
        "age": 0.0781648985211246
      }
    }
  }
}
```

#### createPhoto(photo: <PhotoInputType>)

Uploads the photo from the `file` query param to an AWS S3 bucket and creates a photo resource in the database for the current user or the current user's dog. Whitelisted image file types include: bmp, jpeg, jpg, tiff, png. Requires a PhotoInputType argument. Returns a PhotoType object.

Example request:
```
mutation {
  createPhoto(
    photo: {
      photoableType: "Dog",
      photoableId: 2,
      caption: "My little buddy"
    }
  ) {
    photo {
      id
      photoableId
      photoableType
      caption
      sourceUrl
    }
  }
}
```

Example of expected response:
```
{
  "data": {
    "createPhoto": {
      "photo": {
        "id": "20",
        "photoableId": 2,
        "photoableType": "Dog",
        "caption": "My little buddy",
        "sourceUrl": "https://crowdhound-photos.s3.us-east-2.amazonaws.com/28216d6906d1c2deb2bcc84669a7b8a3.jpg"
      }
    }
  }
}
```

#### destroyDog(dog_id: <ID>)

Deletes the dog associated with the ID passed in as an argument if the dog belongs to the user with the `token` in the query params. *ID argument is required.*

Example request:
```
mutation {
  destroyDog(dogId: 5) {
    message
  }
}
```

Example of expected response:
```
"data": {
  "destroyDog": {
    "message": "Dog successfully deleted"
  }
}
```

#### updateUser(user: <UserInputType>, location: <LocationInputType>)

Updates a user in the database (based on the `token` in the params). Accepts both UserInputType and LocationInputType arguments. Returns a CurrentUserType object. *If a location argument is passed and no location exists for the user, a location will be created.*

Example request:
```
mutation {
  updateUser(
    user: {
      firstName: "Henry",
      lastName: "Ford",
      shortDesc: "I like cars!",
      longDesc: "Yup!"
    },
    location: {
      streetAddress: "1331 17th Street",
      city: "Denver",
      state: "CO",
      zipCode: "80202"
    }
  ) {
    currentUser {
      id
      firstName
      lastName
      shortDesc
      longDesc
      location {
        id
        streetAddress
        city
        state
        zipCode
      }
    }
  }
}
```

Example of expected response:
```
{
  "data": {
    "updateUser": {
      "currentUser": {
        "id": "11",
        "firstName": "Henry",
        "lastName": "Ford",
        "shortDesc": "I like cars!",
        "longDesc": "Yup!",
        "location": {
          "id": "26",
          "streetAddress": "1331 17th Street",
          "city": "Denver",
          "state": "CO",
          "zipCode": "80202"
        }
      }
    }
  }
}
```

## Local Installation

### Requirements

* [Rails 5.2.3](https://rubyonrails.org/) - Rails Version
* [Ruby 2.4.1](https://www.ruby-lang.org/en/downloads/) - Ruby Version

### Clone

```
$ git clone git@github.com:alexander-mathieu/crowdhound_be.git
$ cd crowdhound_be
$ bundle install
$ bundle exec figaro install
```

### AWS Configuration

### Database Setup

The database is setup using Postgres. In order to complete the setup:

* Install [Postgres](https://www.postgresql.org/download/)
* Run the command `$ rails db:{create,migrate,seed}`
