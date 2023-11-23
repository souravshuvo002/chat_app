import 'package:chat_app/component/list_tile.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onTapProfile;
  final void Function()? onTapSignOut;

  const MyDrawer(
      {super.key, required this.onTapProfile, required this.onTapSignOut});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //header
          Column(
            children: [
              const DrawerHeader(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 64,
                ),
              ),
              // Home List tile
              MyListTile(
                icon: Icons.home,
                text: 'H O M E',
                onTap: () => Navigator.pop(context),
              ),
              // Profile List Tile
              MyListTile(
                icon: Icons.home,
                text: 'P R O F I L E',
                onTap: onTapProfile,
              ),
            ],
          ),
          // Log out List Tile
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
              icon: Icons.home,
              text: 'L O G O U T',
              onTap: onTapSignOut,
            ),
          ),
        ],
      ),
    );
  }
}
