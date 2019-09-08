# CrowdHound

## About

Welcome to _CrowdHound_!

The deployed site's endpoints can be consumed at:

https://crowdhound-be.herokuapp.com/

## Endpoints

_CrowdHound_ utilizes [GraphQL](https://graphql.org/). All queries are made to a single endpoint, `POST /graphql`. This endpoint will always return 200 (OK), even if there is an error. If there is an error, it will be present in an `errors` attribute of the response, and the `data` attribute will be `null`.

### Object Types

Object types are templates for resources in the database.  Each object type has a list of attributes that are available to return along with the object.

#### UserType Attributes

* id - ID (Int, required)
* firstName - String
* shortDesc - String
* longDesc - String
* dogs - [ DogType ]
* photos - [ PhotoType ]

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
* user - UserType
* photos - [ PhotoType ]

#### PhotoType Attributes

* id
* sourceUrl

#### LocationType Attributes

* id - ID (Int, required)
* streetAddress - String
* city - String
* state - String
* zipCode - String
* lat - Float
* long - Float

#### AuthenticationInputType Attributes

* firstName - String (required)
* lastName - String (required)
* email - String (required)
* googleToken - String (required)

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

Returns an authenticated user, based on the specified googleToken. Returns null if no user has the specified googleToken. Has additional information not available in the basic user query, such as lastName, email and location.

#### dogs(<filters>)

Returns a collection of dogs, with the option to filter by comma separated arguments. Available arguments are:
* activityLevelRange: <Array with two integer values, denoting the minimum and maximum acceptable activity level>
  * _i.e. activityLevelRange: [0, 2]_
* ageRange: <Array with two integer or float values, denoting the minimum and maximum acceptable age in years>
  * _i.e. ageRange: [2, 4.5]_
* breed: <Array of comma separated strings, denoting the acceptable breeds>
  * _i.e. breed: ["Rat Terrier", "German Shepherd"]_
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
      token: "googletoken"
    }
  ) {
    currentUser {
      id
      firstName
      lastName
      email
    }
    new
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
    }
  }
}
```

#### logOutUser

Logs out a user based on the specified `google_token` query parameter. A successful request returns a `message` attribute.

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
