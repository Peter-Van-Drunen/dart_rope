import 'package:dart_rope/src/rope_node.dart';

class Rope {
  //Fields
  Rope_Node _root;
  num _length;

  //Constructors

  //Default Constructor
  Rope()
      : _root = new Rope_Node(),
        _length = 0 {
    _root.val = "";
  }

  //String Constructor
  Rope.init(String input)
      : _root = new Rope_Node.init(input),
        _length = input.length;

  //Shallow Copy constructor
  //Invoking this constuctor will yield a rope with the wrong length. You much set this manually in the calling method.
  //TODO: Fix above issue. Likely a pretty big refactor.
  Rope._from(Rope_Node new_root)
      : _root = new_root,
        _length = 0;

  //Split method that splits the rope in place, returning the 2nd half.
  Rope split(int index) {
    if (index > this._length - 1 || index < 0) {
      throw new Exception(
          "Invalid argument in Rope:split(). Index out of bounds.");
    }
    if (this._root.isShared()) {
      this._root = Rope_Node.move(this._root);
    }
    if (index == 0) {
      Rope temp = new Rope._from(this._root);
      temp._length = this._length;
      this._root = new Rope_Node();
      this._root.val = "";
      this._length = 0;
      return temp;
    }

    List<Rope_Node> orphans = this._root.split(index);

    Rope new_rope = new Rope._from(orphans.removeAt(0));

    while (orphans.length > 0) {
      new_rope = new_rope + new Rope._from(orphans.removeAt(0));
    }

    new_rope._length = this._length - index;
    this._length = index;

    return new_rope;
  }

  //insert a string at a given index.
  void insert(int index, String input) {
    if (index >= this._length || index < 0) {
      throw new Exception(
          "Invalid argument in Rope:delete(). Index out of bounds.");
    }

    Rope that = new Rope._from(this._root);
    that._length = this._length;

    Rope right = that.split(index);

    that = that + new Rope.init(input);
    that = that + right;
    this._root = that._root;
    this._length = that._length;
  }

  //delete a character at a given index
  String delete(int index) {
    if (index >= this._length || index < 0) {
      throw new Exception(
          "Invalid argument in Rope:delete(). Index out of bounds.");
    }

    Rope that = new Rope._from(this._root);
    that._length = this._length;

    Rope mid = that.split(index);
    Rope right = mid.split(1);

    that = that + right;
    this._root = that._root;
    this._length = this._length - 1;

    return mid._root.getContent();
  }

  //Operator overloads

  //Index getter
  String operator [](int index) {
    if (index > this._length - 1 || index < 0) {
      throw new Exception("Invalid argument in Rope:[]. Index out of bounds.");
    }
    return _root.getIndex(index);
  }

  //Index setter
  operator []=(int index, String val) {
    if (val.length != 1) {
      throw new Exception(
          "Invalid argument in Rope:[]=. Input value must be of length 1.");
    } else if (index > this._length - 1 || index < 0) {
      throw new Exception("Invalid argument in Rope:[]=. Index out of bounds.");
    }
    if (_root.isShared()) {
      _root = Rope_Node.move(_root);
    }
    _root.setIndex(index, val);
  }

  //Concat using the + operator
  Rope operator +(Rope other) {
    Rope_Node new_root = new Rope_Node();

    new_root.l = this._root;
    new_root.r = other._root;

    new_root.weight = new_root.l.getWeight();

    Rope new_rope = new Rope._from(new_root);
    new_rope._length = this._length + other._length;

    this._root.addRefs();
    other._root.addRefs();

    return new_rope;
  }

  String toString() {
    return this._root.getContent();
  }

  //length getter
  num getLength() {
    return _length;
  }
}