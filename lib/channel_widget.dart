import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

import 'room.dart';

class ChannelWidget extends StatelessWidget {
  final Room channel;
  final int unreads;
  final VoidCallback? onTap;
  const ChannelWidget({
    required this.channel,
    this.onTap,
    this.unreads = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Badge(
      badgeContent: Text('$unreads'),
      showBadge: unreads > 0,
      position: const BadgePosition(top: 0, end: 0),
      animationType: BadgeAnimationType.fade,
      child: Card(
        child: ListTile(
          title: Row(
            children: [
              Expanded(child: Text('${channel.name}')),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
