// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // Removed unused AuthState import
// // import '../providers/auth_provider.dart';
// // // Removed unused navigation provider import
// // import '../screens/guest/guest_screen.dart';
// // import '../screens/main_screen.dart';
// // import '../screens/splash/on_boarding_screen.dart';
// // import '../utils/app_preference.dart';

// // class AuthWrapper extends ConsumerStatefulWidget {
// //   final VoidCallback? onLogout;
// //   const AuthWrapper({super.key, this.onLogout});

// //   @override
// //   ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
// // }

// // class _AuthWrapperState extends ConsumerState<AuthWrapper> {
// //   bool _checkingFirstLaunch = true;
// //   bool _showOnboarding = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _checkFirstLaunch();
// //   }

// //   Future<void> _checkFirstLaunch() async {
// //     final isFirstLaunch = await AppPreferences.isFirstLaunch();
// //     final onboardingCompleted = await AppPreferences.isOnboardingCompleted();

// //     setState(() {
// //       _showOnboarding = isFirstLaunch || !onboardingCompleted;
// //       _checkingFirstLaunch = false;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Watch auth state provider
// //     final authState = ref.watch(authStateProvider);

// //     // If still checking first launch status, show loading
// //     if (_checkingFirstLaunch) {
// //       return const Scaffold(
// //         body: Center(
// //           child: CircularProgressIndicator(),
// //         ),
// //       );
// //     }

// //     // If first launch or onboarding not completed, show onboarding
// //     if (_showOnboarding) {
// //       return OnboardingScreen(
// //         onComplete: () async {
// //           await AppPreferences.markOnboardingCompleted();
// //           setState(() {
// //             _showOnboarding = false;
// //           });
// //         },
// //       );
// //     }

// //     // Reset navigation when auth state changes
// //     // ref.listen<AuthState>(authStateProvider, (previous, current) {
// //     //   if (previous?.runtimeType != current.runtimeType) {
// //     //     ref.read(navigationProvider.notifier).setIndex(0);
// //     //   }
// //     // });

// //     return authState.maybeWhen(
// //       authenticated: (token, userId) => MainScreen(onLogout: widget.onLogout),
// //       unauthenticated: () => const GuestScreen(),
// //       loading: () => const Scaffold(
// //         body: Center(
// //           child: CircularProgressIndicator(),
// //         ),
// //       ),
// //       error: (message) {
// //         // Clear the error state and show guest screen
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           ref.read(authStateProvider.notifier).clearError();
// //         });
// //         return const GuestScreen();
// //       },
// //       // For any other transient states (signupSuccess, resetCodeSent, codeVerified,
// //       // passwordResetSuccess, initial), show GuestScreen to avoid blank/unknown screens
// //       orElse: () => const GuestScreen(),
// //     );
// //   }
// // }
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import '../models/auth_state.dart';
// // import '../providers/auth_provider.dart';
// // import '../providers/botttom_navigation_provider.dart';
// // import '../screens/guest/guest_screen.dart';
// // import '../screens/main_screen.dart';

// // class AuthWrapper extends ConsumerWidget {
// //   const AuthWrapper({super.key});

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     // Watch your auth state provider here
// //     final authState = ref.watch(authStateProvider);

// //     // Reset navigation when auth state changes
// //     ref.listen<AuthState>(authStateProvider, (previous, current) {
// //       if (previous?.runtimeType != current.runtimeType) {
// //         ref.read(navigationProvider.notifier).setIndex(0);
// //       }
// //     });

// //     return authState.maybeWhen(
// //       authenticated: (token, userId) => const MainScreen(),
// //       unauthenticated: () => const GuestScreen(),
// //       orElse: () => const SafeArea(child: CircularProgressIndicator()), // All other states will show GuestScreen
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/auth_state.dart';
// import '../providers/auth_provider.dart';
// import '../providers/botttom_navigation_provider.dart';
// import '../screens/guest/guest_screen.dart';
// import '../screens/main_screen.dart';
// import '../screens/splash/on_boarding_screen.dart';
// import '../utils/app_preference.dart';

// class AuthWrapper extends ConsumerStatefulWidget {
//   final VoidCallback? onLogout;
//   const AuthWrapper({super.key, this.onLogout});

//   @override
//   ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
// }

// class _AuthWrapperState extends ConsumerState<AuthWrapper> {
//   bool _checkingFirstLaunch = true;
//   bool _showOnboarding = false;
//   bool _isLoading = false;
//   DateTime? _loadingStartTime;

//   @override
//   void initState() {
//     super.initState();
//     _checkFirstLaunch();
//   }

//   Future<void> _checkFirstLaunch() async {
//     final isFirstLaunch = await AppPreferences.isFirstLaunch();
//     final onboardingCompleted = await AppPreferences.isOnboardingCompleted();

//     setState(() {
//       _showOnboarding = isFirstLaunch || !onboardingCompleted;
//       _checkingFirstLaunch = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Watch auth state provider
//     final authState = ref.watch(authStateProvider);

//     // Handle loading state with timeout
//     if (authState.maybeWhen(
//       loading: () => true,
//       orElse: () => false,
//     )) {
//       if (!_isLoading) {
//         _isLoading = true;
//         _loadingStartTime = DateTime.now();
//       } else if (_loadingStartTime != null) {
//         // If loading for more than 5 seconds, force unauthenticated state
//         if (DateTime.now().difference(_loadingStartTime!).inSeconds > 5) {
//           ref.read(authStateProvider.notifier).state = const AuthState.unauthenticated();
//           _isLoading = false;
//           _loadingStartTime = null;
//         }
//       }
//     } else {
//       _isLoading = false;
//       _loadingStartTime = null;
//     }

//     // If still checking first launch status, show loading
//     if (_checkingFirstLaunch) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     // If first launch or onboarding not completed, show onboarding
//     if (_showOnboarding) {
//       return OnboardingScreen(
//         onComplete: () async {
//           await AppPreferences.markOnboardingCompleted();
//           setState(() {
//             _showOnboarding = false;
//           });
//         },
//       );
//     }

//     // Reset navigation when auth state changes
//     ref.listen<AuthState>(authStateProvider, (previous, current) {
//       if (previous?.runtimeType != current.runtimeType) {
//         ref.read(navigationProvider.notifier).setIndex(0);
//       }
//     });

//     return authState.maybeWhen(
//       authenticated: (token, userId) => MainScreen(onLogout: widget.onLogout),
//       unauthenticated: () => const GuestScreen(),
//       loading: () => const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       ),
//       error: (message) => const GuestScreen(), // On error, show guest screen
//       orElse: () => const GuestScreen(), // Default to guest screen for any other state
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/auth_state.dart';
// import '../providers/auth_provider.dart';
// import '../providers/botttom_navigation_provider.dart';
// import '../screens/guest/guest_screen.dart';
// import '../screens/main_screen.dart';

// class AuthWrapper extends ConsumerWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Watch your auth state provider here
//     final authState = ref.watch(authStateProvider);

//     // Reset navigation when auth state changes
//     ref.listen<AuthState>(authStateProvider, (previous, current) {
//       if (previous?.runtimeType != current.runtimeType) {
//         ref.read(navigationProvider.notifier).setIndex(0);
//       }
//     });

//     return authState.maybeWhen(
//       authenticated: (token, userId) => const MainScreen(),
//       unauthenticated: () => const GuestScreen(),
//       orElse: () => const SafeArea(child: CircularProgressIndicator()), // All other states will show GuestScreen
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../providers/auth_provider.dart';
import '../providers/botttom_navigation_provider.dart';
import '../screens/guest/guest_screen.dart';
import '../screens/main_screen.dart';
import '../screens/splash/on_boarding_screen.dart';
import '../utils/app_preference.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  final VoidCallback? onLogout;
  const AuthWrapper({super.key, this.onLogout});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _checkingFirstLaunch = true;
  bool _showOnboarding = false;
  bool _isLoading = false;
  DateTime? _loadingStartTime;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final isFirstLaunch = await AppPreferences.isFirstLaunch();
    final onboardingCompleted = await AppPreferences.isOnboardingCompleted();

    setState(() {
      _showOnboarding = isFirstLaunch || !onboardingCompleted;
      _checkingFirstLaunch = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state provider
    final authState = ref.watch(authStateProvider);

    // Handle loading state with timeout
    if (authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    )) {
      if (!_isLoading) {
        _isLoading = true;
        _loadingStartTime = DateTime.now();
      } else if (_loadingStartTime != null) {
        // If loading for more than 5 seconds, force unauthenticated state
        if (DateTime.now().difference(_loadingStartTime!).inSeconds > 5) {
          ref.read(authStateProvider.notifier).state = const AuthState.unauthenticated();
          _isLoading = false;
          _loadingStartTime = null;
        }
      }
    } else {
      _isLoading = false;
      _loadingStartTime = null;
    }

    // If still checking first launch status, show loading
    if (_checkingFirstLaunch) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If first launch or onboarding not completed, show onboarding
    if (_showOnboarding) {
      return OnboardingScreen(
        onComplete: () async {
          await AppPreferences.markOnboardingCompleted();
          setState(() {
            _showOnboarding = false;
          });
        },
      );
    }

    // Reset navigation when auth state changes
    ref.listen<AuthState>(authStateProvider, (previous, current) {
      if (previous?.runtimeType != current.runtimeType) {
        ref.read(navigationProvider.notifier).setIndex(0);
      }
    });

    return authState.maybeWhen(
      authenticated: (token, userId) => MainScreen(onLogout: widget.onLogout),
      unauthenticated: () => const GuestScreen(),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (message) => const GuestScreen(), // On error, show guest screen
      orElse: () => const GuestScreen(), // Default to guest screen for any other state
    );
  }
}