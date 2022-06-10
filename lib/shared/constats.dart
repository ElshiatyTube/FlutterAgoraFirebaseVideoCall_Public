//Firebase
const userCollection = 'Users';
const callsCollection = 'Calls';
const tokensCollection = 'Tokens';

const fcmKey = 'AAAAdsdgregeFfdDSPED7zdXkyKrxgAjd88hfeYZKXDOOmZ6OR8Cd70oZdKsD2Ao44mGjga2sdYQzT8fL0hQhcO3sieU7p98YfuXBFgocNOH5gp2'; //replace with your Fcm key
//Routes
const loginScreen = '/';
const homeScreen = '/homeScreen';
const callScreen = '/callScreen';
const testScreen = '/testScreen';



//Agora
const agoraAppId = 'eff3c482e2f6485f9dsdsde2988cf896b'; //replace with your agora app id
const agoraTestChannelName = 'channelTest'; //replace with your agora channel name
const agoraTestToken = '00896bIAAfP7N7HZ83a7t78IAiDh7OgDrFRhWLfAjRHZXrgMAAAAAEABUm4+sBYKkYgEAAQAHgqRi'; //replace with your agora token

//EndPoints -- this is for generating call token programmatically for each call
const cloudFunctionBaseUrl = 'https://us-central1-agora-4895655.cloudfunctions.net/'; //replace with your clouded api base url
const fireCallEndpoint = 'app/access_token'; //replace with your clouded api endpoint


const int callDurationInSec = 45;

//Call Status
enum CallStatus {
  none,
  ringing,
  accept,
  reject,
  unAnswer,
  cancel,
  end,
}