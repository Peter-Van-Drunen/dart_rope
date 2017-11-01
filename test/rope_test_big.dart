import 'dart:io';
import 'dart:math';

import 'package:dart_rope/dart_rope.dart';

main() {
  Stopwatch sw = new Stopwatch();
  Random rand = new Random();

  var sherlock = new File("./test/sherlock.txt");

  String sherlock_string = sherlock.readAsStringSync();

  sw.start();
  Rope sherlock_rope = new Rope.init(sherlock_string);
  sw.stop();

  print("rope constructor took: ${sw.elapsed}");
  sw.reset();

  int index = rand.nextInt(sherlock_string.length - 1);

  sw.start();
  sherlock_rope[index];
  sw.stop();

  print("rope index took: ${sw.elapsed}");
  sw.reset();


  sw.start();
  sherlock_rope.delete(index);
  sw.stop();

  print("rope delete took: ${sw.elapsed}");
  sw.reset();
}