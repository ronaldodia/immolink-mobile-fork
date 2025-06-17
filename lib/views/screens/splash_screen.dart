import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/init_controller.dart';
import 'package:immolink_mobile/views/screens/home_screen.dart';
import 'package:immolink_mobile/utils/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initController = Get.put(InitController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (initController.isInitialized.value) {
          return const HomeScreen();
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.home,
                size: 100,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 30),
              const Text(
                'IMMOLINK',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: LinearProgressIndicator(
                  value: initController.progress.value,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                initController.status.value,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
