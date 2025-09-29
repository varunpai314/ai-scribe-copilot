// lib/src/utils/router.dart - Go Router configuration
import 'package:go_router/go_router.dart';
import 'package:medinote/src/screens/add_patient_screen.dart';
import 'package:medinote/src/screens/auth_screen.dart';
import 'package:medinote/src/screens/home_screen.dart';
import 'package:medinote/src/screens/init_screen.dart';
import 'package:medinote/src/screens/patient_detail_screen.dart';
import 'package:medinote/src/screens/session_screen.dart';
import 'package:medinote/src/screens/pre_session_form_screen.dart';

final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const InitScreen()),
    GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/add_patient',
      builder: (context, state) => const AddPatientScreen(),
    ),
    GoRoute(
      path: '/patient_details/:patientId',
      builder: (context, state) {
        final patientId = state.pathParameters['patientId']!;
        return PatientDetailScreen(patientId: patientId);
      },
    ),
    GoRoute(
      path: '/pre-session/:patientId',
      builder: (context, state) {
        final patientId = state.pathParameters['patientId']!;
        return PreSessionFormScreen(patientId: patientId);
      },
    ),
    GoRoute(
      path: '/session/:patientId',
      builder: (context, state) {
        final patientId = state.pathParameters['patientId']!;
        final sessionId = state.uri.queryParameters['sessionId'];
        final extra = state.extra as Map<String, dynamic>?;
        return SessionScreen(
          patientId: patientId,
          sessionId: sessionId,
          templateId: extra?['templateId'] as String?,
          preDefinedSessionTitle: extra?['sessionTitle'] as String?,
        );
      },
    ),
  ],
);
