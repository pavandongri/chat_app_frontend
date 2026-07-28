import 'package:flutter/widgets.dart';

/// Lets a notification tap navigate (via `GoRouter.of(context)`) from
/// outside the widget tree — there's no `BuildContext` available when a
/// push is tapped from a killed/backgrounded app.
final rootNavigatorKey = GlobalKey<NavigatorState>();
