import React from 'react-native';

const {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  Dimensions,
} = React;

const SCREEN_WIDTH = Dimensions.get('window').width;

import SocialAuth from 'react-native-social-auth';

const beatifyJsonStr = (json) => {
  return json.replace(/,/g, ',\n\n')
             .replace(/{/g, '{\n\n')
             .replace(/}/g, '\n\n}')
}

class socialAuthExample extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      error: null,
      credentials: null,
    }
  }

  _getFBCredentials() {
    this._clearResults();
    SocialAuth.getFacebookCredentials(['email', 'public_profile'], SocialAuth.facebookPermissionsType.read)
    .then((credentials) => {
      this.setState({
        error: null,
        credentials,
      })
    })
    .catch((error) => {
      this.setState({
        error,
        credentials: null,
      })
    })
  }

  _getTWSystemAccounts() {
    this._clearResults();
    SocialAuth.getTwitterSystemAccounts()
    .then((accounts) => {
      this.setState({
        error: null,
        credentials: accounts,
      })
    })
    .catch((error) => {
      this.setState({
        error,
        credentials: null,
      })
    })
  }

  _getTWCredentials() {
    this._clearResults();
    SocialAuth.getTwitterCredentials('snakerxx')
    .then((credentials) => {
      this.setState({
        error: null,
        credentials,
      })
    })
    .catch((error) => {
      this.setState({
        error,
        credentials: null,
      })
    })
  }

  _clearResults() {
    this.setState({
      error: null,
      credentials: null,
    })
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          React Native Social Auth module example
        </Text>
        <TouchableOpacity
          style={styles.btn}
          onPress={this._getFBCredentials.bind(this)}>
          <Text style={styles.btnText}>getFacebookCredentials()</Text>
        </TouchableOpacity>
        <View style={styles.results}>
          <Text>Results:</Text>
          {this.state.error ?
            <Text style={{color: 'red'}}>
              error => {beatifyJsonStr(JSON.stringify(this.state.error))}
            </Text> :
            null}
          {this.state.credentials ?
            <Text style={{color: 'green'}}>
              credentials => {beatifyJsonStr(JSON.stringify(this.state.credentials))}
            </Text> :
            null}
        </View>
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
  btn: {
    height: 40,
    backgroundColor: '#ccc',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 10,
    marginBottom: 10,
    borderRadius: 10,
  },
  results: {
    backgroundColor: '#fff',
    width: SCREEN_WIDTH,
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 20,
    paddingHorizontal: 20,
  },
});

AppRegistry.registerComponent('socialAuthExample', () => socialAuthExample);
