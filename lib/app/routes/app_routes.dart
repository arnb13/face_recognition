part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const SPLASH = _Paths.SPLASH;
  static const AUTH = _Paths.AUTH;
  static const USER_ATTENDANCE_LIST = _Paths.USER_ATTENDANCE_LIST;
  static const ALL_ATTENDANCE = _Paths.ALL_ATTENDANCE;
  static const LEAVE = _Paths.LEAVE;
  static const CONFIG = _Paths.CONFIG;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const SPLASH = '/splash';
  static const AUTH = '/auth';
  static const USER_ATTENDANCE_LIST = '/user-attendance-list';
  static const ALL_ATTENDANCE = '/all-attendance';
  static const LEAVE = '/leave';
  static const CONFIG = '/config';
}
