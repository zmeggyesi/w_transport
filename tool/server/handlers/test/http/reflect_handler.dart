// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart2_constant/convert.dart' as convert_constant;
import 'package:dart2_constant/io.dart' as io_constant;
import 'package:http_parser/http_parser.dart' show MediaType;

import 'package:w_transport/src/http/utils.dart' as http_utils;

import '../../../handler.dart';

/// Always responds with a 200 OK and dumps a reflection
/// of the request to the response body. This reflection
/// is a JSON payload that includes the request method,
/// request URL path, request headers, and request body.
class ReflectHandler extends Handler {
  ReflectHandler() : super() {
    enableCors();
  }

  Future<void> reflect(HttpRequest request) async {
    final headers = <String, String>{};
    request.headers.forEach((name, values) {
      headers[name] = values.join(', ');
    });

    Encoding encoding;
    if (request.headers.contentType == null) {
      encoding = convert_constant.latin1;
    } else {
      final contentType = MediaType(
          request.headers.contentType.primaryType,
          request.headers.contentType.subType,
          request.headers.contentType.parameters);
      encoding = http_utils.parseEncodingFromContentType(contentType,
          fallback: convert_constant.latin1);
    }

    final reflection = <String, Object>{
      'method': request.method,
      'path': request.uri.path,
      'headers': headers,
      'body': await encoding.decodeStream(request),
    };

    request.response.statusCode = io_constant.HttpStatus.ok;
    request.response.headers
        .set('content-type', 'application/json; charset=utf-8');
    setCorsHeaders(request);
    request.response.write(convert_constant.json.encode(reflection));
  }

  @override
  Future<void> copy(HttpRequest request) async => reflect(request);

  @override
  Future<void> delete(HttpRequest request) async => reflect(request);

  @override
  Future<void> get(HttpRequest request) async => reflect(request);

  @override
  Future<void> head(HttpRequest request) async => reflect(request);

  @override
  Future<void> options(HttpRequest request) async => reflect(request);

  @override
  Future<void> patch(HttpRequest request) async => reflect(request);

  @override
  Future<void> post(HttpRequest request) async => reflect(request);

  @override
  Future<void> put(HttpRequest request) async => reflect(request);

  @override
  Future<void> trace(HttpRequest request) async => reflect(request);
}
