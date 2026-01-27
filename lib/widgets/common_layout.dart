import 'package:flutter/material.dart';

class CommonLayout extends StatelessWidget {
  final Widget aquariumSection;
  final Widget taskSection;

  const CommonLayout({
    Key? key,
    required this.aquariumSection,
    required this.taskSection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top 45% - Aquarium Section
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Stack(
                children: [
                  aquariumSection,
                ],
              ),
            ),

            // Bottom 55% - Task Section
            Expanded(
              child: SingleChildScrollView(
                child: taskSection,
              ),
            ),
          ],
        ),
      ),
    );
  }
}