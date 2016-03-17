import React from 'react-native';

const {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  Modal,
} = React;

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

  componentDidMount() {}

  _getFBCredentials() {
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
        <TouchableOpacity
          style={styles.btn}
          onPress={this._getTWSystemAccounts.bind(this)}>
          <Text style={styles.btnText}>getTwitterSystemAccounts()</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.btn}
          onPress={this._getTWCredentials.bind(this)}>
          <Text style={styles.btnText}>getTwitterCredentials()</Text>
        </TouchableOpacity>
        <Modal
          transparent={false}
          animated={true}
          visible={!!(this.state.error || this.state.credentials)}>
          <View style={styles.modal}>
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
            <TouchableOpacity
              style={styles.closeModalBtn}
              onPress={() => {
                this.setState({
                  error: null,
                  credentials: null,
                })
              }}>
              <Text style={styles.closeModalBtnText}>Close</Text>
            </TouchableOpacity>
          </View>
        </Modal>
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
  modal: {
    backgroundColor: '#fff',
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  closeModalBtn: {
    position: 'absolute',
    right: 10,
    top: 20,
    height: 40,
    alignItems: 'center',
    justifyContent: 'center',
  },
  closeModalBtnText: {
    color: '#000',
  }
});

AppRegistry.registerComponent('socialAuthExample', () => socialAuthExample);
