class Rope {
  //Fields
  _Node _root;
  num length;

  //Constructors

  //Default Constructor
  Rope()
      : _root = new _Node(),
        length = 0;

  //String Constructor
  Rope.init(String input)
      : _root = new _Node.init(input),
        length = input.length;

  //Shallow Copy constructor
  Rope._from(_Node new_root) : _root = new_root;

  //Operator overloads

  //Index getter
  String operator [](int index) {
    if (index > this.length - 1 || index < 0) {
      throw new Exception("Invalid argument in Rope:[]. Index out of bounds.");
    }
    return _root.getIndex(index);
  }

  //Index setter
  operator []=(int index, String val) {
    if (val.length != 1) {
      throw new Exception(
          "Invalid argument in Rope:[]=. Input value must be of length 1.");
    } else if (index > this.length - 1 || index < 0) {
      throw new Exception("Invalid argument in Rope:[]=. Index out of bounds.");
    }
    if (_root.isShared()) {
      _root = _Node.move(_root);
    }
    _root.setIndex(index, val);
  }

  Rope operator +(Rope other) {
    _Node new_root = new _Node();
    new_root.l = this._root;
    new_root.r = other._root;

    new_root.weight = new_root.l.getSize();

    Rope new_rope = new Rope._from(new_root);
    new_rope.length = this.length + other.length;

    this._root.addRefs();
    other._root.addRefs();

    return new_rope;
  }
}

class _Node {
  //Fields
  _Node l, r;
  num weight;
  String val;
  num refs;

  //Constructors
  _Node() {
    this.weight = 0;
    this.refs = 1;
  }

  _Node.init(String input) {
    this.refs = 1;
    if (input.length <= 10) {
      this.val = input;
      this.weight = input.length;
    } else {
      this.l = new _Node.init(input.substring(0, input.length ~/ 2));
      this.r = new _Node.init(input.substring(input.length ~/ 2, input.length));

      this.weight = this.l.getSize();
    }
  }

  //Static method for moving the reference to a node if we are mutating it
  static _Node move(_Node it) {
    String content = it.getContent();
    _Node new_node = new _Node.init(content);
    it.removeRefs();
    return new_node;
  }

  //Getter for indexing operation
  String getIndex(int index) {
    if (this.weight <= index) {
      return this.r.getIndex(index - this.weight);
    } else {
      if (this.l != null) {
        return this.l.getIndex(index);
      } else {
        return this.val[index];
      }
    }
  }

  //Setter for indexing operation
  void setIndex(int index, String val) {
    if (this.weight <= index) {
      if (this.r.isShared()) {
        this.r = _Node.move(this.r);
      }
      this.r.setIndex(index - this.weight, val);
    } else {
      if (this.l != null) {
        if (this.l.isShared()) {
          this.l = _Node.move(this.l);
        }
        this.l.setIndex(index, val);
      } else {
        if (index + 1 >= this.val.length) {
          this.val = this.val.substring(0, this.val.length - 1) + val;
        } else {
          String left = this.val.substring(0, index);
          String right = this.val.substring(index + 1, this.val.length);
          this.val = left + val + right;
        }
      }
    }
  }

  //Utility method to add 1 to every ref count for this and all child nodes
  void addRefs() {
    this.refs++;
    if (this.r != null) {
      this.l.addRefs();
      this.r.addRefs();
    } else if (this.l != null) {
      this.l.addRefs();
    }
  }

  //Utility method to remove 1 from every ref count for this and all child nodes
  void removeRefs() {
    this.refs--;
    if (this.r != null) {
      this.l.addRefs();
      this.r.addRefs();
    } else if (this.l != null) {
      this.l.addRefs();
    }
  }

  //Utility method that gets the weight of the node
  num getSize() {
    if (this.isLeaf()) {
      return this.weight;
    } else {
      return this.l.getSize() + (this.r != null ? this.r.getSize() : 0);
    }
  }

  //Utility method that returns true if the node is a leaf node
  bool isLeaf() {
    return this.val != null;
  }

  //Method for getting the full string content of a node and all it's children
  String getContent() {
    if (this.isLeaf()) {
      return this.val;
    } else {
      return this.l.getContent() + (this.r != null ? this.r.getContent() : "");
    }
  }

  //Method for checking the ref count. Returns true if ref count is more than 1
  bool isShared() {
    return this.refs > 1;
  }
}
