# CrowdHound

![CrowdHound Screenshot](/public/images/crowdhound_screenshot.png)

[View deployed site](https://crowdhound.herokuapp.com/)

Welcome! This is an API that serves as the backend for _CrowdHound_, built by [Alexandra Chakeres](https://github.com/chakeresa/) and [Alexander Mathieu](https://github.com/alexander-mathieu/). The _CrowdHound_ frontend is viewable on GitHub [here](https://github.com/evanmarkowitz/crowdhound/).

The project board used to organize our user stories can be viewed [here](https://github.com/alexander-mathieu/crowdhound_be/projects/2/), while the backend-specific board can be viewed [here](https://github.com/alexander-mathieu/crowdhound_be/projects/3/). The app utilized CI/CD through [CircleCI](https://circleci.com/gh/alexander-mathieu/crowdhound_be).

## About

Some people just want to chill with a dog for an afternoon or a few days, without the responsibility of having them 24/7/365. On the other side of the coin, many busy dog owners have to bug their friends and family, or pay expensive boarding fees when they leave town or can’t come home right after work. _CrowdHound_ lets dog owners and enthusiasts find each other. You can see photos of the dogs and users, read each other's profiles, and filter by preferences (like dog age, weight and distance to you). When you find a profile you like, you can send them a message to connect.

The deployed API's endpoints can be consumed at:

https://crowdhound-be.herokuapp.com/

## Schema

![CrowdHound Schema](/public/images/schema.png)

## Tech Stack

 - Ruby on Rails
 - PostgreSQL database
 - GraphQL API
 - AWS S3 (photo storage)
 - CircleCI CI/CD
 - RSpec testing
 - Pusher Chatkit

## GraphQL Endpoints

_CrowdHound_ utilizes [GraphQL](https://graphql.org/). All queries are made to a single endpoint, `POST /graphql`. This endpoint will always return 200 (OK), even if there is an error. If there is an error, it will be present in an `errors` attribute of the response, and the `data` attribute will be `null`.

### Authentication

To make queries or mutations as a logged-in user, include that user's token as a `token` query param.

### Object Types

Object types are templates for resources in the database.  Each object type has a list of attributes that are available to return along with the object.

#### ChatType Attributes

* id - String (required)
* unreadCount - Int
* lastMessageAt - String
* user - UserType

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

#### `users`

Returns an array of all UserType objects with requested attributes.

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

#### `user(id: <ID>)`

Returns a single UserType object having the specified ID. *ID argument is required.*

#### `currentUser`

Returns an authenticated user (CurrentUserType object), based on the specified token. Returns null if no user has the specified token. Has additional information not available in the basic user query, such as lastName, email and location.

#### `dogs(<filters>)`

Returns an array of DogType objects, with the option to filter by comma separated arguments. If the request is authenticated, the dogs are sorted by distance to the authenticated user.

Available arguments are:
* activityLevelRange: <Array with two integer values, denoting the minimum and maximum acceptable activity level>
  * _i.e. activityLevelRange: [0, 2]_
* ageRange: <Array with two integer or float values, denoting the minimum and maximum acceptable age in years>
  * _i.e. ageRange: [2, 4.5]_
* breed: <Array of comma separated strings, denoting the acceptable breeds>
  * _i.e. breed: ["Rat Terrier", "German Shepherd"]_
* maxDistance: <Int (in miles)>
* weightRange: <Array with two integer values, denoting the minimum and maximum acceptable weight in pounds>
 * _i.e. weightRange: [20, 40]_

Filters may be used in any combination. For fields where only a single value is desired, enter the same value twice.
* _i.e. ageRange: [2, 2]_

#### `dog(id: <ID>)`

Returns a single DogType object having the specified ID. *id: argument is required.*

#### `chats`

If the request is authenticated (with a valid `token` query parameter), the request returns an array of ChatType objects that the current user is a part of. If the request is not authenticated, the request returns null.

### Mutations

Mutations are requests to modify resources in the database.

#### `authenticateUser(auth: <AuthenticationInputType>, apiKey: <String>)`

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

#### `logOutUser`

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

#### `createLocation(location: <LocationInputType>)`

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

#### `createDog(dog: <DogInputType>)`

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

#### `createPhoto(photo: <PhotoInputType>)`

Decrypts and uploads a base-64 encoded photo from the `file` query param to an AWS S3 bucket and creates a photo resource in the database for the current user or the current user's dog. Whitelisted image file types include: bmp, jpeg, jpg, tiff, png. Requires a PhotoInputType argument. Returns a PhotoType object.

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

#### `destroyDog(dog_id: <ID>)`

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

#### `updateUser(user: <UserInputType>, location: <LocationInputType>)`

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

#### `startChat(userId: <id of user to start chat with>)`

Finds or creates a chatkit room (chat) between the current user (based on the specified `token` query parameter) and the user specified by id in the mutation's argument. A successful request returns a `roomId` attribute.

Example request (for user 73):
```
mutation {
  startChat(userId: 56)
  {
    roomId
  }
}
```

Expected response:
```
{
  "data": {
    "startChat": {
      "roomId": "56-73"
    }
  }
}
```

### Lonely REST Endpoint

#### `POST /chatkit_auth?token=<token>`

Provides the information required to authenticate a user through Pusher. *Requires valid user token passed as a parameter.* Returns 401 unauthorized if an invalid token is passed.

Example of expected response:
```
{
  "access_token": "eyJhbGciOiJIUzI1NiJ9.eyJpbnN0YW5jZSI6ImU5ZDQzY2U1LTIxNTktNGQ3NS04MDMwLTYxNzg2NzUyOGIwYiIsImlzcyI6ImFwaV9rZXlzL2Y4YThhNjdjLTk1MGQtNGY5OC04YWE5LWE0ZTkxNzEzMzQ2MSIsImlhdCI6MTU2ODI0MjI5NSwiZXhwIjoxNTY4MzI4Njk1LCJzdWIiOiI1OCJ9.VNhCUpsudrcVBPhQchX2J3HP9cGWc99hoqnpCQpDEwo",
  "token_type": "bearer",
  "expires_in": 86400
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

### Required Environment Variables

```
AWS_ACCESS_KEY_ID
AWS_BUCKET
AWS_REGION
AWS_SECRET_ACCESS_KEY
BACKEND_DOMAIN
CHATKIT_INSTANCE_LOCATOR
CHATKIT_SECRET_KEY
CHATKIT_TEST_TOKEN_ENDPOINT
EXAMPLE_USER_ID
EXAMPLE_USER_TOKEN
EXPRESS_API_KEY
GOOGLE_MAPS_API_KEY
HEROKU_API_KEY
```

### Database Setup

The database is setup using Postgres. In order to complete the setup:

* Install [Postgres](https://www.postgresql.org/download/)
* Run the command `$ rails db:{create,migrate,seed}`

### Testing

The full test suite can be run with `$ bundle exec rspec`.
