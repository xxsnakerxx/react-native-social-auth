package com.xxsnakerxx.socialauth;

import android.accounts.AccountManager;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookAuthorizationException;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SocialAuthModule extends ReactContextBaseJavaModule implements ActivityEventListener {

  public static final String REACT_CLASS = "RNSocialAuthManager";
  public static final int TWITTER_OAUTH_REQUEST = 1;

  private AccountManager accountManager;
  private String requestedTwitterAccountName;
  private CallbackManager fbCallbackManager;
  private Callback fbRNCallback;

  private String fbRequestedPermissionsType;

  @Override
  public String getName() {
    return REACT_CLASS;
  }

  public void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
    fbCallbackManager.onActivityResult(requestCode, resultCode, data);
  }

  public SocialAuthModule(ReactApplicationContext reactContext) {
    super(reactContext);

    reactContext.addActivityEventListener(this);

    FacebookSdk.sdkInitialize(getReactApplicationContext());

    fbCallbackManager = CallbackManager.Factory.create();

    LoginManager.getInstance().registerCallback(fbCallbackManager, new FacebookCallback<LoginResult>() {
      @Override
      public void onSuccess(LoginResult loginResult) {
        WritableMap map = Arguments.createMap();

        if (fbRequestedPermissionsType.equals("write") && !AccessToken.getCurrentAccessToken().getPermissions().contains("publish_actions")) {
          map.putInt("code", -2);
          map.putBoolean("cancelled", false);
          map.putString("message", "Requested write permissions wasn't granted");

          fbRNCallback.invoke(map, null);

          return;
        }

        map.putString("userId", AccessToken.getCurrentAccessToken().getUserId());
        map.putString("accessToken", AccessToken.getCurrentAccessToken().getToken());
        map.putBoolean("hasWritePermissions", AccessToken.getCurrentAccessToken().getPermissions().contains("publish_actions"));

        fbRNCallback.invoke(null, map);
      }

      @Override
      public void onCancel() {
        WritableMap map = Arguments.createMap();

        map.putInt("code", -1);
        map.putBoolean("cancelled", true);
        map.putString("message", "Credentials request was canceled");

        fbRNCallback.invoke(map, null);
      }

      @Override
      public void onError(FacebookException exception) {
        if (exception instanceof FacebookAuthorizationException) {
          if (AccessToken.getCurrentAccessToken() != null) {
            LoginManager.getInstance().logOut();
          }
        }

        WritableMap map = Arguments.createMap();

        map.putInt("code", 0);
        map.putBoolean("cancelled", false);
        map.putString("message", exception.getLocalizedMessage());

        fbRNCallback.invoke(map, null);
      }
    });
  }

  @Override
  public Map<String, Object> getConstants() {
    final Map<String, Object> constants = new HashMap<>();

    final Map<String, Object> facebookPermissionsType = new HashMap<>();

    facebookPermissionsType.put("read", "read");
    facebookPermissionsType.put("write", "write");

    constants.put("facebookPermissionsType", facebookPermissionsType);

    return constants;
  }

  @ReactMethod
  public void setFacebookApp(ReadableMap app) {
    FacebookSdk.setApplicationId(app.getString("id"));
    FacebookSdk.setApplicationName(app.getString("name"));
  }

  @ReactMethod
  public void getFacebookCredentials(ReadableArray permissions, String permissionsType, final Callback callback) {
    LoginManager loginManager = LoginManager.getInstance();

    List<String> _permissions = new ArrayList<String>();

    for(int i = 0; i < permissions.size(); i++) {
      if (permissions.getType(i).name().equals("String")) {
        String permission = permissions.getString(i);

        _permissions.add(permission);
      }
    }

    fbRequestedPermissionsType = permissionsType;
    fbRNCallback = callback;

    if (permissionsType.equals("write")) {
      loginManager.logInWithPublishPermissions(getCurrentActivity(), _permissions);
    }
    else {
      loginManager.logInWithReadPermissions(getCurrentActivity(), _permissions);
    }
  }
}
