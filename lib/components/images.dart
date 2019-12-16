import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Widget containing an icon for a monster or dungeon. When clicked it may optionally redirect
/// to the underlying data. This makes sense for a monster or dungeon, but not as much for an icon
/// representing an event or attached to a list.
class PadIcon extends StatelessWidget {
  final int iconId;
  final double size;
  final bool ink;

  const PadIcon(
    this.iconId, {
    this.size = 48,
    this.ink = false,
  });

  @override
  Widget build(BuildContext context) {
    var finalIconId = iconId ?? 0;
    var url = _imageUrl('icons', finalIconId, 5);
    return Image.network(url, width: size, height: size);
//    return CachedNetworkImage(imageUrl: url);
  }
}

// TODO: should probably adjust the special icon range
bool isMonsterId(int monsterId) {
  return monsterId < 9000 || monsterId > 9999;
}

// TODO: convert to using Endpoints
String _imageUrl(String category, int value, int length) {
  var paddedNo = value.toString().padLeft(length, '0');
  return 'https://f002.backblazeb2.com/file/dadguide-data/media/$category/$paddedNo.png';
}
