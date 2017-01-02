### Android setup

#### Link
By using `react-native link` ( __recommended__ ) [Next Step](facebook)

#### Manual

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

4. Register React Package

  ```
  ...
  import com.xxsnakerxx.socialauth.SocialAuthPackage; // import

  public class MainActivity extends ReactActivity {
  ...
    /**
     * A list of packages used by the app. If the app uses additional views
     * or modules besides the default ones, add more packages here.
     */
    @Override
    protected List<ReactPackage> getPackages() {
        return Arrays.<ReactPackage>asList(
            new MainReactPackage(),
            new SocialAuthPackage() // <-- Add this line
        );
    }
  ...
  }
  ```

### Facebook

5. Follow these instructions [setup appId](https://developers.facebook.com/docs/android/getting-started/#app_id) and [setup login](https://developers.facebook.com/docs/android/getting-started/#login_share)
6. Create and setup Key Hash [Facebook docs](https://developers.facebook.com/docs/android/getting-started/#create_hash)

### Twitter

#### Not supported :-(
