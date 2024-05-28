import 'dart:core';

import 'package:draw_canvas/animation_page.dart';
import 'package:draw_canvas/draw_canvas_page.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {

  int _selectedPageIndex = 0;

  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(vsync: this, length: 2, initialIndex: _selectedPageIndex);
    tabController.addListener(() {
      _selectedPageIndex = tabController.index;
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          DrawingCanvas(),
          AnimationPage(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TabBar(
          controller: tabController,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.black54,
          dividerColor: Colors.transparent,
          indicatorColor: Colors.black54,
          labelPadding: EdgeInsets.zero,
          tabs: const [
            Tab(
              height: 60,
              text: "Canvas",

            ),
            Tab(
              height: 60,
              text: "Animation",

            ),
          ],
        ),
      ),
    );
  }
}



