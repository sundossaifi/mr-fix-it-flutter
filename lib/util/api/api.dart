import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:mr_fix_it/model/working_location.dart';

import 'package:mr_fix_it/util/response_state.dart';

import 'package:mr_fix_it/util/api/exception/session_expired_exception.dart';

typedef FileUploadBody = Future<void> Function(http.MultipartRequest multipartRequest);

class Api {
  static const String _baseApiUrl = 'http://13.60.3.70/api';

  static const String _registerClientUrl = 'register-client';
  static const String _registerWorkerUrl = 'register-worker';
  static const String _authenticateUrl = 'authenticate';
  static const String _forgetPasswordUrl = 'forget-password-request';
  static const String _fetchCategoiesUrl = 'get-categories';
  static const String _refreshTokenUrl = 'refresh-token';
  static const String _updateFCMTokenUrl = 'update-fcm';
  static const String _logoutUrl = 'logout';

  static const String _authGroupUrl = 'auth';
  static late String _userGroupURL;

  static Future<Map<String, dynamic>> fetchData(String endpoint, Map<String, dynamic> parameters) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (!preferences.containsKey('token') || !preferences.containsKey('user')) {
      throw SessionExpiredException('session expired, please log in again');
    }

    _userGroupURL = json.decode(preferences.getString('user')!)['type'].toString().toLowerCase();
    String url = '$_baseApiUrl/$_userGroupURL/$endpoint';

    if (parameters.isNotEmpty) {
      url += '?';

      parameters.forEach((key, value) {
        url += '$key=$value&';
      });

      if (url.endsWith('&')) {
        url = url.substring(0, url.length - 1);
      }
    }

    final Map<String, String> header = {};
    String? token = preferences.getString('token');

    header['Authorization'] = 'Bearer $token';

    final response = await http.get(
      Uri.parse(url),
      headers: header,
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }

    if (response.statusCode == 401) {
      if (await _refreshToken()) {
        return fetchData(endpoint, parameters);
      }

      throw SessionExpiredException('session expired, please log in again');
    }

    throw Exception('Something went wrong, try again later');
  }

  static Future<Map<String, dynamic>> postData(String endpoint, Map<String, dynamic> data) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (!preferences.containsKey('token') || !preferences.containsKey('user')) {
      throw SessionExpiredException('session expired, please log in again');
    }

    _userGroupURL = json.decode(preferences.getString('user')!)['type'].toString().toLowerCase();
    String url = '$_baseApiUrl/$_userGroupURL/$endpoint';

    final Map<String, String> header = {};
    String? token = preferences.getString('token');

    header['Content-Type'] = 'application/json; charset=UTF-8';
    header['Authorization'] = 'Bearer $token';

    final response = await http.post(
      Uri.parse(url),
      headers: header,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return {
        'responseState': ResponseState.success,
        'body': json.decode(utf8.decode(response.bodyBytes)),
      };
    }

    if (response.statusCode == 401) {
      if (await _refreshToken()) {
        return postData(endpoint, data);
      }

      throw SessionExpiredException('session expired, please log in again');
    }

    if (response.statusCode == 409) {
      return {
        'responseState': ResponseState.conflict,
        'body': json.decode(response.body),
      };
    }

    return {
      'responseState': ResponseState.error,
    };
  }

  static Future<Map<String, dynamic>> logout() async {
    String url = '$_baseApiUrl/$_authGroupUrl/$_logoutUrl';

    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (!preferences.containsKey('token') || !preferences.containsKey('user')) {
      throw SessionExpiredException('session expired, please log in again');
    }

    final Map<String, String> header = {};
    String? token = preferences.getString('token');

    header['Authorization'] = 'Bearer $token';

    final response = await http.post(
      Uri.parse(url),
      headers: header,
    );

    if (response.statusCode == 200) {
      return {
        'responseState': ResponseState.success,
        'body': json.decode(utf8.decode(response.bodyBytes)),
      };
    }

    if (response.statusCode == 401) {
      if (await _refreshToken()) {
        return logout();
      }

      throw SessionExpiredException('session expired, please log in again');
    }

    return {
      'responseState': ResponseState.error,
    };
  }

  static Future<Map<String, dynamic>> formData(String endpoint, Map<String, dynamic> data, FileUploadBody fileUploadBody) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (!preferences.containsKey('token') || !preferences.containsKey('user')) {
      throw SessionExpiredException('session expired, please log in again');
    }

    _userGroupURL = json.decode(preferences.getString('user')!)['type'].toString().toLowerCase();
    String url = '$_baseApiUrl/$_userGroupURL/$endpoint';
    String? token = preferences.getString('token');

    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $token';

    data.forEach((key, value) {
      request.fields[key] = value;
    });

    await fileUploadBody(request);

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return {
        'responseState': ResponseState.success,
        'body': json.decode(responseBody),
      };
    }

    if (response.statusCode == 401) {
      if (await _refreshToken()) {
        return formData(endpoint, data, fileUploadBody);
      }

      throw SessionExpiredException('session expired, please log in again');
    }

    if (response.statusCode == 409) {
      return {
        'responseState': ResponseState.conflict,
        'body': json.decode(responseBody),
      };
    }

    return {
      'responseState': ResponseState.error,
    };
  }

  static Future<ResponseState> register(Map<String, dynamic> user, bool isWorker) async {
    String endpoint = (isWorker) ? _registerWorkerUrl : _registerClientUrl;
    String url = '$_baseApiUrl/$_authGroupUrl/$endpoint';

    var request = http.MultipartRequest("POST", Uri.parse(url));

    request.fields['firstName'] = user['firstName'];
    request.fields['lastName'] = user['lastName'];
    request.fields['dob'] = user['dob'];
    request.fields['gender'] = user['gender'];
    request.fields['city'] = user['city'];
    request.fields['email'] = user['email'];
    request.fields['password'] = user['password'];
    request.fields['phone'] = user['phone'];

    XFile profilePictureFile = user['profilePicture'];

    request.files.add(
      await http.MultipartFile.fromPath(
        "profilePicture",
        profilePictureFile.path,
        filename: profilePictureFile.name,
        contentType: MediaType('image', path.extension(profilePictureFile.name).replaceAll(".", "")),
      ),
    );

    if (isWorker) {
      List<WorkingLocation> workingLocations = user['workingLocations'];

      workingLocations.asMap().forEach((index, location) {
        request.fields['workingLocations[$index].locality'] = location.locality;
        request.fields['workingLocations[$index].latitude'] = location.latitude.toString();
        request.fields['workingLocations[$index].longitude'] = location.longitude.toString();
      });

      request.fields['category'] = user['category'];
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      return ResponseState.success;
    }

    if (response.statusCode == 409) {
      return ResponseState.conflict;
    }

    return ResponseState.error;
  }

  static Future<ResponseState> authenticate(String email, String password) async {
    Map<String, dynamic> data = {'email': email, 'password': password};
    String url = '$_baseApiUrl/$_authGroupUrl/$_authenticateUrl';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(utf8.decode(response.bodyBytes));

      final user = responseBody['user'];
      final tokens = responseBody['tokens'];
      final token = tokens['token'];
      final refreshToken = tokens['refreshToken'];
      final notificationToken = await FirebaseMessaging.instance.getToken();

      final SharedPreferences preferences = await SharedPreferences.getInstance();

      preferences.setString('user', json.encode(user));
      preferences.setString('password', password);

      preferences.setString('token', token);
      preferences.setString('refreshToken', refreshToken);
      preferences.setString('notificationToken', notificationToken!);

      String? fcm = await FirebaseMessaging.instance.getToken();
      _updateFCMToken(fcm, token);

      return ResponseState.success;
    }

    if (response.statusCode == 404) {
      return ResponseState.notFound;
    }

    if (response.statusCode == 401) {
      return ResponseState.unauthorized;
    }

    return ResponseState.error;
  }

  static Future<ResponseState> forgetPassword(String email) async {
    String url = '$_baseApiUrl/$_authGroupUrl/$_forgetPasswordUrl?email=$email';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return ResponseState.success;
    }

    if (response.statusCode == 404) {
      return ResponseState.notFound;
    }

    if (response.statusCode == 401) {
      return ResponseState.unauthorized;
    }

    return ResponseState.error;
  }

  static Future<List<dynamic>> fetchCategories() async {
    String url = '$_baseApiUrl/$_authGroupUrl/$_fetchCategoiesUrl';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['categories'].map((category) => category['type']).toList();
    }

    return List.empty();
  }

  static Future<String?> getToken() async {
    await _refreshToken();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('token');
  }

  static Future<bool> _refreshToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (!preferences.containsKey('refreshToken')) {
      return false;
    }

    String url = '$_baseApiUrl/$_authGroupUrl/$_refreshTokenUrl';

    final Map<String, String> header = {};
    String? token = preferences.getString('refreshToken');

    header['Authorization'] = 'Bearer $token';

    final response = await http.get(
      Uri.parse(url),
      headers: header,
    );

    if (response.statusCode == 200) {
      preferences.setString('token', json.decode(response.body)['token']);
      preferences.setString('refreshToken', json.decode(response.body)['refreshToken']);

      return true;
    }

    return false;
  }

  static void _updateFCMToken(String? fcm, String token) async {
    String url = '$_baseApiUrl/$_authGroupUrl/$_updateFCMTokenUrl';

    Map<String, dynamic> data = {'fcm': fcm};
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    await http.post(
      Uri.parse(url),
      headers: header,
      body: json.encode(data),
    );
  }
}
