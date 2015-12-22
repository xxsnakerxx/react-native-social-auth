import React from 'react-native';

const { NativeModules } = React;
const { RNSocialAuthManager } = NativeModules;

export default class SocialAuth {
  static getFacebookCredentials(
    permissions = ['email'],
    permissionsType = SocialAuth.facebookPermissionsType.read,
    cb = () => {}) {

    RNSocialAuthManager.getFacebookCredentials(permissions, permissionsType, cb);
  }

  static getTwitterSystemAccounts(cb = () => {}) {
    if (React.Platform.OS === 'android') {
      throw new Error('SocialAuth.getTwitterSystemAccounts is not supported for android');
    }

    RNSocialAuthManager.getTwitterSystemAccounts(cb);
  }

  static getTwitterCredentials(userName = null, reverseAuthResponse = '', cb = () => {}) {
    if (React.Platform.OS === 'android') {
      throw new Error('SocialAuth.getTwitterCredentials is not supported for android');
    }

    if (arguments.length === 2) {
      cb = arguments[1] || (() => {});
      reverseAuthResponse = '';
    }

    if (userName) {
      RNSocialAuthManager.getTwitterCredentials(userName, reverseAuthResponse, cb);
    }
  }
}

SocialAuth.facebookPermissionsType = RNSocialAuthManager.facebookPermissionsType;
