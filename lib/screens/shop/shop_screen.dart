import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shop'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Shop Items'),
              Tab(text: 'Manage Items'),
              Tab(text: 'Skin Themes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ShopItemsTab(),
            _ManageItemsTab(),
            _SkinThemesTab(),
          ],
        ),
      ),
    );
  }
}

class _ShopItemsTab extends StatelessWidget {
  const _ShopItemsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildShopItem('Seaweed', 'Waving brown seaweed', 20),
        _buildShopItem('Green Seaweed', 'Fresh green seaweed', 25),
        _buildShopItem('Kelp', 'Large kelp forest', 30),
      ],
    );
  }

  Widget _buildShopItem(String name, String description, int cost) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: const Icon(Icons.eco, color: Colors.green),
        title: Text(name),
        subtitle: Text(description),
        trailing: Text('$cost G', style: const TextStyle(color: Colors.amber)),
      ),
    );
  }
}

class _ManageItemsTab extends StatelessWidget {
  const _ManageItemsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('Owned Items: 1'),
          Text('Placed Items: 1'),
        ],
      ),
    );
  }
}

class _SkinThemesTab extends StatelessWidget {
  const _SkinThemesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildSkinTheme('Classic', 'Default fish skin', 0, true),
        _buildSkinTheme('Neon Party', 'Glowing vibrant fish', 120, false),
        _buildSkinTheme('Ocean Explorer', 'Adventurous ocean fish', 180, false),
      ],
    );
  }

  Widget _buildSkinTheme(String name, String description, int cost, bool isActive) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: const Icon(Icons.palette, color: Colors.blue),
        title: Text(name),
        subtitle: Text(description),
        trailing: isActive
            ? const Text('Active', style: TextStyle(color: Colors.green))
            : Text('$cost G', style: const TextStyle(color: Colors.amber)),
      ),
    );
  }
}