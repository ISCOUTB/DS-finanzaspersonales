import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/common/constants/app_colors.dart';
import 'package:nuevo_proyecto_flutter/common/constants/app_text_styles.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceWhite,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              width: constraints.maxWidth > 800 ? 800 : constraints.maxWidth * 0.95,
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Imagen
                  Expanded(
                    flex: 3,
                    child: Image.asset(
                      'assets/images/man.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 30),

                 
                  Text(
                    'Manage your finances easily and make better decisions',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.mediumText.copyWith(
                      color: AppColors.greelightTwo,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: 200,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greelightTwo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        
                      },
                      child: const Text('Get Started'),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.smallText.copyWith(color: AppColors.grey),
                      ),
                      InkWell(
                        onTap: () {
                         
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          'Log In',
                          style: AppTextStyles.smallText.copyWith(
                            color: AppColors.greelightTwo,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
