# Flutter Agora Fully Functional Video Call module

## Tech Stack

**Client:** Dart, Flutter

**Server:** Firebase firestore, Google cloud functions

## Techniques:

*BloC pattern with Cubit State management

*Fully Real-time data-consuming for (Users-History-VideoCall status)

*Real-time handling for all call status (calling - accept- reject - cancel - busy - unAnswer - end)

*Clean code and arch

*Ui=>Cubit=>Api data flow

*Dio package for deals with (generate agora token - FCM) api

*Fcm notification (handling incoming calls in terminated mode)

**Build token generator using nodejs:** https://www.youtube.com/watch?v=KcLypppA2IQ&ab_channel=Agora

**Demo Video :** https://www.youtube.com/watch?v=Ond-VhB11h4


![App Screenshot](https://i.ibb.co/3kWWdVX/Untitled1.png)

![App Screenshot](https://i.ibb.co/nbV41dV/new.png)

![App Screenshot](https://i.ibb.co/8KdjTF1/Untitled2.png)


## Getting Started

*Create a new firebase project and setup firestore and enable email/password authentication

*Copy FCM authorization key and past it on fcmKey var in constants.dart file

*Create agora new project and general token, channel name for test purpose and past them with your appId on (agoraAppId-agoraTestChannelName-agoraTestToken) vars in constants.dart file
