//Firebase
const userCollection = 'Users';
const callsCollection = 'Calls';
const tokensCollection = 'Tokens';

const fcmKey = 'AAAA8hfeYZKXDOOmZ6OR8Cd70oZdKsD2Ao44YfuXBFgocNOH5gp2'; //replace with your Fcm key
//Routes
const loginScreen = '/';
const homeScreen = '/homeScreen';
const callScreen = '/callScreen';
const testScreen = '/testScreen';



//Agora
const agoraAppId = 'e21dde29886b'; //replace with your agora app id
const agoraTestChannelName = 'newChannel'; //replace with your agora channel name
const agoraTestToken = '006effbIACQIrib0zw+jFMnUP0OBgJajy/o8utZ2Zg9CqRnJo7WwAAAAAEABUm4+syy+mYgEAAQDOL6Zi'; //replace with your agora token

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