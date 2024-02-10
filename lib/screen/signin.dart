import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/accounts.dart';
import '../utils.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  static const String createToken = """
    mutation CreateCustomerToken(\$email: String!, \$pass: String!) {
      generateCustomerToken(
        email: \$email
        password: \$pass
      ) {
        token
      }
    }
  """;

  final _formKey = GlobalKey<FormState>();
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Giriş Yap'),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Giriş Bilgileri'),
                const SizedBox(
                  height: 45.0,
                ),
                TextFormField(
                  obscureText: false,
                  autocorrect: false,
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    labelText: 'Email adresinizi girin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: const BorderSide(color: Colors.grey), // Gri renkli kenarlık
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: const BorderSide(color: Colors.grey), // Gri renkli kenarlık
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen Email adresinizi girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25.0),
                TextFormField(
                  obscureText: true,
                  autocorrect: false,
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'Parola',
                    labelText: 'Parolanızı girin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: const BorderSide(color: Colors.grey), // Gri renkli kenarlık
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: const BorderSide(color: Colors.grey), // Gri renkli kenarlık
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen parolanızı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 35.0,
                ),
                Mutation(
                  options: MutationOptions(
                    document: gql(createToken),
                    onCompleted: (data) {
                      if (data == null) {
                        return;
                      }
                      final generateToken = data['generateCustomerToken'];
                      if (generateToken == null) {
                        return;
                      }
                      final token = generateToken['token'];
                      Provider.of<AccountsProvider>(context, listen: false)
                          .signIn(token);
                      getCart(context);
                      Navigator.pop(context);
                    },
                    onError: (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error.toString()),
                        ),
                      );
                    },
                  ),
                  builder: (runMutation, result) {
                    return ElevatedButton(
                      child: const Text('Giriş Yap'),
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          runMutation({
                            'email': emailController.text,
                            'pass': passwordController.text,
                          });
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
