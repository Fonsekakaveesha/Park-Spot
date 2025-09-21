// lib/web/platform_view_registry_web.dart
// This file exposes platformViewRegistry for Flutter Web

// ignore_for_file: undefined_shown_name, recursive_getters, duplicate_ignore, unused_import

// ignore: avoid_web_libraries_in_flutter
import 'dart:ui' as ui;
// ignore: unused_import
import 'dart:ui_web' as ui_web;
import 'dart:ui_web';

// ignore: unused_import
import 'package:final_pro/web/platform_view_registry_web.dart' show PlatformViewFactory, platformViewFactory, platformViewRegistry;

// Expose the actual factory function, not the type
// ignore: recursive_getters
PlatformViewFactory get platformViewFactory => platformViewFactory;

PlatformViewRegistry get platformViewRegistry => platformViewRegistry;

// lib/web/platform_view_registry_stub.dart
// Stub for non-web platforms

typedef PlatformViewFactory = dynamic;

