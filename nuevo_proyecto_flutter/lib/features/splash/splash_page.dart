import 'package:nuevo_proyecto_flutter/common/constants/app_colors.dart';

import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        alignment:Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          
          colors:AppColors.greenGradient, )
        ),
       child:  Image.asset("assets/images/man.png"),
      ),
      );
  }
}

// child:  Text("Finance Tracker",style: AppTextStyles.bigText. copyWith(color:  AppColors.white),
//        ),