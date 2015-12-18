import React from 'react-native';

const {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  NativeModules,
} = React;

const { RNSocialAuthManager } = NativeModules;

class socialAuthExample extends React.Component {
  componentDidMount() {
    RNSocialAuthManager.test();
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          React Native Social Auth module example
        </Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
});

AppRegistry.registerComponent('socialAuthExample', () => socialAuthExample);
