import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../cubit/Auth/auth_cubit.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('naame: ${AuthCubit.get(context).currentUser.name}');

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
