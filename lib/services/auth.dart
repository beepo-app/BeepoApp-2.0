// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:hive/hive.dart';
// import 'package:http/http.dart' as http;
// import '../Utils/functions.dart';


// class AuthService {
//   Box box = Hive.box('Beepo');

//   //GETTERS
//   String get userPin => box.get('PIN', defaultValue: '');

//   //Get UserID
//   String get userID => box.get('userId', defaultValue: '');

//   String get uid => box.get('uid', defaultValue: '');

//   //Get User token
//   String get token => box.get('token', defaultValue: '');

//   //Get Access token
//   // String get accessToken => box.get('EAT', defaultValue: '');
//   String get accessToken => box.get('accessToken', defaultValue: '');

//   //Get Context Id
//   String get contextId => box.get('contextId', defaultValue: '');

//   //Create User
//   Future<bool> createUser(String displayName, File img, String pin) async {
//     try {
//       //To generate keys and contextId
//       Map keys = await isolateFunction();
//       box.put('privateKey', keys['privateKey']);
//       Map contextResult = await AuthService().createContext(keys['publicKey']);

//       //Encrypt PIN
//       String encryptedPin = await EncryptionService().encrypt(pin);

//       // Upload image and get image url
//       String imageUrl = "";
//       imageUrl = await MediaService.uploadProfilePicture(img);
//       //If image was selected, add to the body of the request

//       var body = {'displayName': displayName, "encrypted_pin": encryptedPin};

//       body['profilePictureUrl'] = imageUrl;

//       final response = await http.post(
//         Uri.parse('$baseUrl/users'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           Headers.context: contextResult['contextId'],
//         },
//         body: json.encode(body),
//       );

//       beepoPrint(response.body);
//       if (response.statusCode == 201 || response.statusCode == 200) {
//         var data = json.decode(response.body);

//         await box.put('seedphrase', data['encrypted_seedphrase']);
//         await box.put('accessToken', data['access_token']);
//         await box.put('isLogged', true);
//         await box.put('userData', data['user']);


//         return true;
//       } else {
//         // showToast(response.body);
//         return false;
//       }
//     } catch (e) {
//       beepoPrint(e);
//       // showToast(e.toString());
//       return false;
//     }
//   }
