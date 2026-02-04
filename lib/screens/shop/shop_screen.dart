import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_data_provider.dart';
import 'shop_tab.dart';
import 'manage_decoration_tab.dart';
import 'skin_tab.dart';
import 'shop_colors.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShopColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: ShopColors.appBarBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ShopColors.appBarIcon),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '🏪 장식 관리',
          style: TextStyle(
            color: ShopColors.appBarText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          Consumer<UserDataProvider>(
            builder: (context, provider, child) {
              final gold = provider.userData?.gold ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: ShopColors.goldBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '💰',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$gold G',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: ShopColors.goldText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: ShopColors.appBarTabIndicator,
          unselectedLabelColor: ShopColors.textDisabled,
          indicatorColor: ShopColors.appBarTabIndicator,
          tabs: const [
            Tab(text: '장식 상점'),
            Tab(text: '장식 관리'),
            Tab(text: '스킨 테마'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ShopTab(),
          ManageDecorationTab(),
          SkinTab(),
        ],
      ),
    );
  }}