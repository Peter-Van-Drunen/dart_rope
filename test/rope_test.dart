import 'package:dart_rope/dart_rope.dart';
import 'package:test/test.dart';

void main() {
  test('default constructor', () {
    Rope r1 = new Rope();

    expect(r1.getLength(), 0);
  });

  test('init constructor', () {
    Rope r1 = new Rope.init(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.");

    expect(r1.getLength(), 123);
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

  test('concat operator +', () {
    Rope r1 = new Rope.init(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ");
    Rope r2 = new Rope.init(
        "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.");

    Rope r3 = r1 + r2;
    expect(r3[r1.getLength()], "U");
    expect(r3[r3.getLength() - 1], ".");

    r3[0] = "X";
    expect(r1[0], "L");
    expect(r3[0], "X");

    r2[0] = "X";
    expect(r3[r1.getLength()], "U");
    expect(r2[0], "X");

    expect(r3.getLength(), r1.getLength() + r2.getLength());
  });

  test('split', () {
    //split on the "end" of a node
    Rope r1 = new Rope.init(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ");
    Rope r2 = r1.split(23);

    expect(r1.getLength(), 23);
    expect(r1[22], "a");
    expect(r2[0], "m");

    //split in the "middle" of a node
    Rope r3 = new Rope.init(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ");
    Rope r4 = r3.split(22);

    expect(r3.getLength(), 22);
    expect(r3[21], " ");
    expect(r4[0], "a");

    //edge case of splitting on the 0 index
    Rope r5 = new Rope.init(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ");
    Rope r6 = r5.split(0);

    expect(r5.getLength(), 0);
    expect(r6.getLength(), 124);
    expect(r6[0], "L");
    expect(r6[123], " ");

    //edge case of splitting on last index
    Rope r7 = new Rope.init(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ");
    Rope r8 = r7.split(123);

    expect(r8[0], " ");
    expect(r7[122], ".");
    expect(r8.getLength(), 1);
  });

  test('insert', () {
    Rope r1 = new Rope.init(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ");
    r1 = Rope.insert(r1, 0, "X");
    expect(r1[0], "X");
    expect(r1[1], "L");
  });
}
