import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/locator.dart';
import 'package:http/http.dart' as http;

typedef ResSuccess = Future<void> Function(Map<String, dynamic>);
typedef ResFailure = Future<void> Function(dynamic);

class ServiceCall {
  static final NavigationService navigationService = locator<NavigationService>();
  static Map userPayload = {};

  // ✅ Thêm baseUrl
  static const String baseUrl = "https://foood-tour.online/api"; // <-- chỉnh chỗ này "https://10.0.2.2:1228/api"
  // static const String baseUrl = "https://10.0.2.2:7064/api"; // <-- chỉnh chỗ này "https://10.0.2.2:1228/api"


  // ✅ Hàm POST chuẩn
  static void post(String endpoint, Map<String, dynamic> parameter,
      {bool isToken = false, ResSuccess? withSuccess, ResFailure? failure}) {
    Future(() async {
      try {
        var headers = {'Content-Type': 'application/json'};

        // Nếu có token
        if (isToken) {
          headers["Authorization"] = "Bearer ${Globs.getToken()}"; // <-- tự xử lý token
        }
        final response = await http.post(
          Uri.parse("$baseUrl/$endpoint"), // <-- gắn vào baseUrl
          body: json.encode(parameter),
          headers: headers,
        );
        if (response.statusCode == 200) {
          var jsonObj = json.decode(response.body) as Map<String, dynamic>? ?? {};
          if (withSuccess != null) await withSuccess(jsonObj);
        }else {
          String errorMsg = "Error: ${response.statusCode}";
          try {
            // Vì BE trả plain text, nên cứ lấy luôn body
            if (response.body.isNotEmpty) {
              errorMsg = response.body;
            }
          } catch (e) {
            // Nếu có lỗi decode (dù ít khi xảy ra) thì giữ nguyên errorMsg cũ.
          }

          if (failure != null) await failure(errorMsg);
        }

      } catch (err) {
        if (failure != null) await failure(err.toString());
      }
    });
  }

  // ✅ Hàm GET
  static void get(String endpoint,
      {bool isToken = false, ResSuccess? withSuccess, ResFailure? failure}) {
    Future(() async {
      try {
        var headers = {'Content-Type': 'application/json'};

        if (isToken) {
          headers["Authorization"] = "Bearer ${Globs.getToken()}";
        }

        final response = await http.get(
          Uri.parse("$baseUrl/$endpoint"),
          headers: headers,
        );
        if (response.statusCode == 200) {
          var jsonObj = json.decode(response.body) as Map<String, dynamic>? ?? {};
          if (withSuccess != null) await withSuccess(jsonObj);
        } else {
          if (failure != null) await failure("Error: ${response.statusCode}");
        }
      } catch (err) {
        if (failure != null) await failure(err.toString());
      }
    });
  }

  static logout(){
    Globs.udBoolSet(false, Globs.userLogin);
    userPayload = {};
    navigationService.navigateTo("welcome");
  }
}
