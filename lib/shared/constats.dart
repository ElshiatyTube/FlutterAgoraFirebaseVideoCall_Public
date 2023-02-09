//Firebase
const userCollection = 'Users';
const callsCollection = 'Calls';
const chatCollection = 'Chat';
const tokensCollection = 'Tokens';

const fcmKey = 'AAAAfffff8hfeYZfdfdfdOH5gp2'; //replace with your Fcm key
//Routes
const splashScreen = '/';
const authScreen = '/authScreen';
const homeScreen = '/homeScreen';
const callScreen = '/callScreen';
const testScreen = '/testScreen';



//Agora
const agoraAppId = 'efsaadadadaf921dde2988cf896b'; //replace with your agora app id
const agoraTestChannelName = 'testChannel'; //replace with your agora channel name
const agoraTestToken = '007eJxTYIhZ/W6Wo3SzEwsTNMsjQxTUlKNLC0sktMsLM2ShDSeJjcEMjIIes1kYmSAQBCfm6EktbjEOSMxLy81h4EBAGFwIgM='; //replace with your agora token

//EndPoints -- this is for generating call token programmatically for each call
const cloudFunctionBaseUrl = 'https://us-central1-agora-409098655.cloudfunctions.net/'; //replace with your clouded api base url
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