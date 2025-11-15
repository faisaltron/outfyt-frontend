import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/services/auth_service.dart';
import '../controllers/auth_state_provider.dart';
import '../controllers/signin_controller.dart';

// Changed to ConsumerStatefulWidget to manage local state for the form key.
class SigninScreen extends ConsumerStatefulWidget {
  const SigninScreen({super.key});

  @override
  ConsumerState<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends ConsumerState<SigninScreen> {
  // Form key is now managed locally within the widget's state.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(signinControllerProvider);
    final authState = ref.watch(authStateProvider);
    final size = MediaQuery.of(context).size;

    // If already authenticated, check profile completion and redirect
    if (authState == AuthStatus.authenticated) {
      Future.microtask(() async {
        // Read the AuthService notifier to call its method
        final authService = ref.read(authServiceProvider.notifier); // <--- Access AuthService
        final isProfileComplete = await authService.isProfileCompleted(); // <--- Call method on AuthService

        if (context.mounted) {
          if (isProfileComplete) {
            Navigator.pushNamedAndRemoveUntil(context, '/holder', (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/aboutyou', (route) => false);
          }
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: const Text(
                "Sign In",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                  vertical: size.height * 0.02
              ),
              // The Form widget now uses the local _formKey.
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email Input
                    const Text('Email',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 8),
                    TextFormField(
                      autofocus: true,
                      controller: controller.emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) => value!.isEmpty ? 'Email is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Password Input
                    const Text('Password',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      textInputAction: TextInputAction.done,
                      // Pass the local _formKey to the signIn method.
                      onFieldSubmitted: (_) => controller.signIn(context, _formKey),
                      validator: (value) => value!.isEmpty ? 'Password is required' : null,
                    ),
                    const SizedBox(height: 10),

                    // Forgot Password Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/forgetpassword'),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authState == AuthStatus.loading
                            ? null
                        // Pass the local _formKey to the signIn method.
                            : ()=> controller.signIn(context,_formKey),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD00A62),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                            'Sign In',
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // OR Divider
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Or',
                              style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ),
                        Expanded(child: Divider(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Google Sign-In
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed:authState == AuthStatus.loading
                            ? null
                            : () => controller.signInWithGoogle(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD00A62)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/google.svg',
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                'Sign In with Google',
                                style: TextStyle(
                                    color: Color(0xFFD00A62),
                                    fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (authState == AuthStatus.loading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}