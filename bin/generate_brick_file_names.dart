import 'dart:io';

import 'package:equatable/equatable.dart';


import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

void main() {
  final file = File('assets/spritesheet_elements.xml');
  final rects = <String, Rect>{};
  final document = XmlDocument.parse(file.readAsStringSync());
  for (final node in document.xpath('//TextureAtlas/SubTexture')) {
    final name = node.getAttribute('name')!;
    rects[name] = Rect(
      x: int.parse(node.getAttribute('x')!),
      y: int.parse(node.getAttribute('y')!),
      width: int.parse(node.getAttribute('width')!),
      height: int.parse(node.getAttribute('height')!),
    );
  }
  print(generateBrickFilesNames(rects));
}

class Rect extends Equatable {
  const Rect({
    required this.x,
    required this.y,
    required this.height,
    required this.width,
  });
  final int x;
  final int y;
  final int height;
  final int width;
  Size get size => Size(width, height);

  @override
  List<Object?> get props => [x, y, width, height];

  @override
  bool get stringify => true;
}

class Size extends Equatable {
  const Size(this.width, this.height);
  final int width;
  final int height;
  @override
  List<Object?> get props => [width, height];
}

String generateBrickFilesNames(Map<String, Rect> rects) {
  final groups = <Size, List<String>>{};
  for (final entry in rects.entries) {
    groups.putIfAbsent(entry.value.size, () => []).add(entry.key);
  }
  final buff = StringBuffer();
  buff.writeln(
      ''' Map<BrickDamage , String> brickFileName(BrickType type , BrickSize size){
    return switch ((type,size))  { '''); //}
  for (final entry in groups.entries) {
    final size = entry.key;
    final entries = entry.value;
    entries.sort();
    for (final type in ['Explosive', 'Glass', 'Metal', 'Stone', 'Wood']) {
      var filtered = entries.where((element) => element.contains(type));
      if (filtered.length == 5) {
        buff.writeln(
            ''' (BrickType.${type.toLowerCase()},BrickSize.size${size.width}x${size.height})=>{
          BrickDamage.none: '${filtered.elementAt(0)}',
          BrickDamage.some: '${filtered.elementAt(1)}',
          BrickDamage.lots: '${filtered.elementAt(4)}',
          }, ''');
      } else if (filtered.length == 10) {
        buff.writeln('''
    (BrickType.${type.toLowerCase()}, BrickSize.size${size.width}x${size.height}) => {
        BrickDamage.none: '${filtered.elementAt(3)}',
        BrickDamage.some: '${filtered.elementAt(4)}',
        BrickDamage.lots: '${filtered.elementAt(9)}',
      },''');
      } else if (filtered.length == 15) {
        buff.writeln('''
    (BrickType.${type.toLowerCase()}, BrickSize.size${size.width}x${size.height}) => {
        BrickDamage.none: '${filtered.elementAt(7)}',
        BrickDamage.some: '${filtered.elementAt(8)}',
        BrickDamage.lots: '${filtered.elementAt(13)}',
      },''');
      }
    }
  }
  buff.writeln(''' 
  };
  }''');
  return buff.toString();
}
