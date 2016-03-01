# React Native Social Auth

### React Native module provides auth methods via social networks using native APIs.
#### Very important! The module doesn't provide full stack communication with social networks API, it made just for auth.

![preview](images/social_auth_example.gif)

## Table of contents
- [What using](#what-using)
- [Installation](#installation)
  - [Common](#common)
  - [iOS](ios#readme)
  - [Android](android#readme)
- [Usage](#usage)
- [Contributing](#contributing)
- [Copyright and license](#copyright-and-license)

## What using
- `facebook`
  - __FacebookSDK__
- `twitter`
	- __Accounts.framework and reverse auth (iOS)__

## Installation

### Common
1. Install package via npm:

```javascript
npm install react-native-social-auth
```

2. Perform platform specific setup
  - [iOS](ios#readme)
  - [Android](android#readme)

3. Inside your code include JS part by adding

  ```javascript
  import SocialAuth from 'react-native-social-auth';
  ```

4. Compile and have fun! Or go to [example](example) and see how it works.

## Usage

#### Constants
  - `SocialAuth.facebookPermissionsType.read`
  - `SocialAuth.facebookPermissionsType.write`

#### setFacebookApp({id, name})
```javascript

SocialAuth.setFacebookApp({id: 'APP_ID', name: 'DISPLAY_NAME'});
```

#### getFacebookCredentials(permissions, permissionsType)
  - `permissions` (Array of strings)
  - `permissionsType` (one of [facebookPermissionsType](#constants))

##### returns a promise
  - __resolved__ with `credentials` (object contains `accessToken`, `userId`, `hasWritePermissions`)
  - __rejected__ with `error` (object contains `code` and `message`)

```javascript

SocialAuth.getFacebookCredentials(["email", "user_friends"], SocialAuth.facebookPermissionsType.read)
.then((credentials) => console.log(credentials));
.catch((error) => console.log(error))
```

#### getTwitterSystemAccounts()
##### returns a promise
  - __resolved__ with `accounts` (array of objects like `{username: "userName"}`)
  - __rejected__ with `error` (object contains `code` and `message`)

```javascript
SocialAuth.getTwitterSystemAccounts()
.then((accounts) => console.log(accounts));
.catch((error) => console.log(error))
```

#### getTwitterCredentials(username, [reverseAuthResponse])
  - `username` (Twitter account user name without `@`)
  - `reverseAuthResponse` (is a string that returns by twitter's api when we do the first part of reverse auth)
    - __you can define `key` and `secret` of your twitter app in [RNSocialAuthManager.m](ios/RNSocialAuthManager.m)__
    ```
    #define twitterAppConsumerKey @"..."
    #define twitterAppConsumerSecret @"..."
    ```
    #### But this way is not SAFE!

    - other option is that your backed can perform the first part of reverse auth and send you back response of it.
      It's looks like this
      ```
      OAuth oauth_timestamp="...", oauth_signature="...", oauth_consumer_key="...", oauth_nonce="...", oauth_token="...", oauth_signature_method="HMAC-SHA1", oauth_version="1.0"
      ```
      Then you just pass it to the function as a second parameter

##### returns a promise
  - __resolved__ with `credentials` (object contains `oauthToken`, `oauthTokenSecret`, `userName`)
  - __rejected__ with `error` (object contains `code` and `message`)

```javascript
SocialAuth.getTwitterCredentials("dimkol")
.then((credentials) => console.log(credentials))
.catch((error) => console.log(error));
```

## Contributing

Just submit a pull request!

## Copyright and license

Code and documentation copyright 2015 Dmitriy Kolesnikov. Code released under the [MIT license](LICENSE).
