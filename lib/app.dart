import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/ui/screens/login_screen.dart';
import 'features/auth/ui/screens/register_screen.dart';
import 'features/auth/ui/screens/forgot_password_screen.dart';
import 'features/auth/ui/screens/profile_screen.dart';
import 'features/capsules/bloc/capsules_bloc.dart';
import 'features/capsules/bloc/capsules_event.dart';
import 'features/capsules/bloc/capsules_state.dart';
import 'features/capsules/data/repositories/capsules_repository.dart';
import 'features/capsules/ui/screens/capsules_list_screen.dart';
import 'features/capsules/ui/screens/capsule_detail_screen.dart';
import 'features/capsules/ui/screens/create_edit_capsule_screen.dart';
import 'injection_container.dart';
import 'package:go_router/go_router.dart';

import 'dart:async';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class TimeCapsuleApp extends StatefulWidget {
  const TimeCapsuleApp({super.key});

  @override
  State<TimeCapsuleApp> createState() => _TimeCapsuleAppState();
}

class _TimeCapsuleAppState extends State<TimeCapsuleApp> {
  late final AuthBloc _authBloc;
  late final CapsulesBloc _capsulesBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(
      authRepository: AuthRepository(
        dio: InjectionContainer().apiClient.dio,
      ),
    )..add(const CheckAuthStatus());

    _capsulesBloc = CapsulesBloc(
      repository: CapsulesRepository(
        dio: InjectionContainer().apiClient.dio,
      ),
    )..add(const LoadCapsules());

    _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/capsules',
          builder: (context, state) => const CapsulesListScreen(),
        ),
        GoRoute(
          path: '/capsules/create',
          builder: (context, state) => const CreateEditCapsuleScreen(),
        ),
        GoRoute(
          path: '/capsules/:id',
          builder: (context, state) {
            final capsuleId = state.pathParameters['id']!;
            return CapsuleDetailScreen(capsuleId: capsuleId);
          },
        ),
        GoRoute(
          path: '/capsules/:id/edit',
          builder: (context, state) {
            final capsuleId = state.pathParameters['id']!;
            return _EditCapsuleWrapper(capsuleId: capsuleId);
          },
        ),
      ],
      redirect: (context, state) {
        final authState = _authBloc.state;
        final isAuthenticated = authState is Authenticated;
        final isLoading = authState is AuthLoading || authState is AuthInitial;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/forgot-password';

        if (isLoading) return null;

        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }
        if (isAuthenticated && isAuthRoute) {
          return '/capsules';
        }
        return null;
      },
      refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    _capsulesBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: BlocProvider.value(
        value: _capsulesBloc,
        child: MaterialApp.router(
          title: 'Time Capsule',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: _router,
        ),
      ),
    );
  }
}

class _EditCapsuleWrapper extends StatefulWidget {
  final String capsuleId;

  const _EditCapsuleWrapper({required this.capsuleId});

  @override
  State<_EditCapsuleWrapper> createState() => _EditCapsuleWrapperState();
}

class _EditCapsuleWrapperState extends State<_EditCapsuleWrapper> {
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      context.read<CapsulesBloc>().add(LoadCapsuleDetail(capsuleId: widget.capsuleId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CapsulesBloc, CapsulesState>(
      builder: (context, state) {
        if (state is CapsuleDetailLoaded) {
          return CreateEditCapsuleScreen(capsule: state.capsule);
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
