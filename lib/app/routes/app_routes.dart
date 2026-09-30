/// Route name constants. The v2.4 journey uses [entry], [signIn],
/// [myRequests], [newRequest], [requestDetail], [simulate] and [blocked];
/// the v1.5 constants below them are kept only for the unused v1.5 pages
/// awaiting removal (tasks T09).
abstract class AppRoutes {
  AppRoutes._();

  static const entry = '/';
  static const signIn = '/sign-in';
  static const myRequests = '/transfer/requests';
  static const newRequest = '/transfer/new';
  static const requestDetail = '/transfer/request';
  static const simulate = '/demo/simulate';
  static const blocked = '/blocked';

  static const placeholder = entry;
  static const transferRequestSubmit = '/transfer-request/submit';
  static const transferRequestStatus = '/transfer-request/status';
  static const login = '/login';
  static const register = '/register';
}
