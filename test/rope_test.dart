import 'package:dart_rope/Rope.dart';
import 'package:test/test.dart';

void main() {
  test('default constructor', () {
    Rope r1 = new Rope();

    expect(r1.length, 0);
  });

  test('init constructor', () {
    Rope r1 = new Rope.init(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.");

    expect(r1.length, 123);
  });

  test('index access', () {
    Rope r1 = new Rope.init(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.");

    expect(r1[0], "L");
    expect(r1[1], "o");
    expect(r1[14], "l");

    r1[0] = "R";
    expect(r1[0], "R");
    r1[5] = "!";
    expect(r1[5], "!");
    r1[24] = "G";
    expect(r1[24], "G");
  });

  test('concat', () {
    Rope r1 = new Rope.init(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ");
    Rope r2 = new Rope.init(
        "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.");

    Rope r3 = r1 + r2;
    expect(r3[r1.length], "U");
    expect(r3[r3.length - 1], ".");
  });
}
