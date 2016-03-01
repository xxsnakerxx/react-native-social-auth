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
    permissionsType = SocialAuth.facebookPermissionsType.read) {

    return new Promise((resolve, reject) => {
        RNSocialAuthManager.getFacebookCredentials(permissions, permissionsType, (error, credentials) => {
          if (error) {
            reject(error);
          } else {
            resolve(credentials);
          }
        });
    })
  }

  static getTwitterSystemAccounts() {
    if (React.Platform.OS === 'android') {
      return Promise.reject({
        message: 'SocialAuth.getTwitterSystemAccounts is not supported for android',
      });
    }

    return new Promise((resolve, reject) => {
      RNSocialAuthManager.getTwitterSystemAccounts((error, accounts) => {
        if (error) {
          reject(error);
        } else {
          resolve(accounts);
        }
      });
    })
  }

  static getTwitterCredentials(userName = null, reverseAuthResponse = '') {
    if (React.Platform.OS === 'android') {
      return Promise.reject({
        message: 'SocialAuth.getTwitterCredentials is not supported for android',
      });
    }

    if (userName) {
      return new Promise((resolve, reject) => {
        RNSocialAuthManager.getTwitterCredentials(userName, reverseAuthResponse, (error, credentials) => {
          if (error) {
            reject(error);
          } else {
            resolve(credentials);
          }
        });
      })
    } else {
      return Promise.reject({
        message: 'SocialAuth.getTwitterCredentials: userName is required',
      })
    }
  }
}

SocialAuth.facebookPermissionsType = RNSocialAuthManager.facebookPermissionsType;
