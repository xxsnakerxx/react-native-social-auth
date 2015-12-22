## Android setup

1. Link the library
  - by using `rnpm link` ([rnpm](https://github.com/rnpm/rnpm)) (but need some changes, go to step 4)
  - or `manual` (see next steps)
2. Open `android/settings.gradle` file and add following
```
...
include ':react-native-social-auth'
project(':react-native-social-auth').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-social-auth/android')
```
3. Open `android/app/build.gradle` file and add following
```
...
dependencies {
    ...
    compile project(':react-native-social-auth')
}
```

4. Register React Package and Handle onActivityResult

```
...
import android.content.Intent; // import
import com.xxsnakerxx.socialauth.SocialAuthPackage; // import

public class MainActivity extends Activity implements DefaultHardwareBackBtnHandler {

    private ReactInstanceManager mReactInstanceManager;
    private ReactRootView mReactRootView;

    // One
    private SocialAuthPackage mSocialAuthPackage;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mReactRootView = new ReactRootView(this);

        // two
        mSocialAuthPackage = new SocialAuthPackage(this);

        mReactInstanceManager = ReactInstanceManager.builder()
                .setApplication(getApplication())
                .setBundleAssetName("index.android.bundle")
                .setJSMainModuleName("index.android")
                .addPackage(new MainReactPackage())

                // three
                .addPackage(mSocialAuthPackage)

                .setUseDeveloperSupport(BuildConfig.DEBUG)
                .setInitialLifecycleState(LifecycleState.RESUMED)
                .build();
        mReactRootView.startReactApplication(mReactInstanceManager, "AwesomeProject", null);
        setContentView(mReactRootView);
    }
...
```

### Facebook
5. Update MainActivity.java

```
...
import com.facebook.FacebookSdk; // import

...

@Override
protected void onCreate(Bundle savedInstanceState) {
    ...
    setContentView(mReactRootView);
    FacebookSdk.sdkInitialize(getApplicationContext());
}

@Override
public void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
    super.onActivityResult(requestCode, resultCode, data);

    // handle onActivityResult
    mSocialAuthPackage.handleActivityResult(requestCode, resultCode, data);
}
```
6. Follow these instructions [setup appId](https://developers.facebook.com/docs/android/getting-started/#app_id) and [setup login](https://developers.facebook.com/docs/android/getting-started/#login_share)
7. Create and setup Key Hash [Facebook docs](https://developers.facebook.com/docs/android/getting-started/#create_hash)

### Twitter

#### Not supported :-(
