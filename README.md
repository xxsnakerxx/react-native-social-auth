# React Native Social Auth

### React Native module provides auth methods via social networks using native APIs.
#### Very important! The module doesn't provide full stack communication with social networks API, it made just for auth.

## Table of contents
- [What using](#what-using)
- [Installation](#what-using)

## What using
- `facebook`
  - __FacebookSDK__
- `twitter`
	- __Accounts.framework (iOS)__

## Installation
1. Install package via npm:

```javascript
npm install react-native-social-auth
```

2. Link your library by one of those ways: either by using `rnpm link` (see more about rnpm [here](https://github.com/rnpm/rnpm)) or like it's [described here](http://facebook.github.io/react-native/docs/linking-libraries-ios.html).
3. Inside your code include JS part by adding

  ```javascript
  import { NativeModules } from 'react-native';

  const { RNSocialAuthManager } = NativeModules;
  ```

4. Compile and have fun! Or go to [example](link) and see how it works.
