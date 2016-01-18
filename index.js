import React from 'react-native';

const { NativeModules } = React;
const { RNSocialAuthManager } = NativeModules;

const _app = {
  id: '',
  name: '',
}

export default class SocialAuth {
  static setFacebookApp(app) {
    if (!app.id || !app.name) {
      throw new Error('SocialAuth:setFacebookApp: id and name keys are required');
    }

    if (app.id !== _app.id && app.name !== _app.name) {
      RNSocialAuthManager.setFacebookApp({id: `${app.id}`, name: `${app.name}`});

      _app.id = app.id;
      _app.name = app.name;
    }
  }

  static getFacebookCredentials(
    permissions = ['email'],
    permissionsType = SocialAuth.facebookPermissionsType.read,
    cb = () => {}) {

    RNSocialAuthManager.getFacebookCredentials(permissions, permissionsType, cb);
  }

  static getTwitterSystemAccounts(cb = () => {}) {
    if (React.Platform.OS === 'android') {
      console.warn('SocialAuth.getTwitterSystemAccounts is not supported for android');
      return;
    }

    RNSocialAuthManager.getTwitterSystemAccounts(cb);
  }

  static getTwitterCredentials(userName = null, reverseAuthResponse = '', cb = () => {}) {
    if (React.Platform.OS === 'android') {
      console.warn();('SocialAuth.getTwitterCredentials is not supported for android');
      return;
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
