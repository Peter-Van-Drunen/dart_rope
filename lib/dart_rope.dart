class Rope {
  //Fields
  _Rope_Node _root;
  num _length;

  //Constructors

  //Default Constructor
  Rope()
      : _root = new _Rope_Node(),
        _length = 0 {
    _root.val = "";
  }

  //String Constructor
  Rope.init(String input)
      : _root = new _Rope_Node.init(input),
        _length = input.length;

  //Shallow Copy constructor
  //Invoking this constuctor will yield a rope with the wrong length. You much set this manually in the calling method.
  //TODO: Fix above issue. Likely a pretty big refactor.
  Rope._from(_Rope_Node new_root)
      : _root = new_root,
        _length = 0;

  //Split method that splits the rope in place, returning the 2nd half.
  Rope split(int index) {
    if (index > this._length - 1 || index < 0) {
      throw new Exception(
          "Invalid argument in Rope:split(). Index out of bounds.");
    }
    if (this._root.isShared()) {
      this._root = _Rope_Node.move(this._root);
    }
    if (index == 0) {
      Rope temp = new Rope._from(this._root);
      temp._length = this._length;
      this._root = new _Rope_Node();
      this._root.val = "";
      this._length = 0;
      return temp;
    }

    List<_Rope_Node> orphans = this._root.split(index);

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
      _root = _Rope_Node.move(_root);
    }
    _root.setIndex(index, val);
  }

  //Concat using the + operator
  Rope operator +(Rope other) {
    _Rope_Node new_root = new _Rope_Node();

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

class _Rope_Node {
  //Fields
  _Rope_Node l, r;
  num weight;
  String val;
  num refs;

  //Constructors
  _Rope_Node() {
    this.weight = 0;
    this.refs = 1;
  }

  _Rope_Node.init(String input) {
    this.refs = 1;
    if (input.length <= 10) {
      this.val = input;
      this.weight = input.length;
    } else {
      this.l = new _Rope_Node.init(input.substring(0, input.length ~/ 2));
      this.r =
      new _Rope_Node.init(input.substring(input.length ~/ 2, input.length));

      this.weight = this.l.getWeight();
    }
  }

  //Static method for moving the reference to a node if we are mutating it and it has multiple references
  static _Rope_Node move(_Rope_Node it) {
    String content = it.getContent();
    _Rope_Node new_node = new _Rope_Node.init(content);
    it.removeRefs();
    return new_node;
  }

  //Method for splitting a rope at a given index. Returns orphaned nodes which are re-concated in the parent function
  List<_Rope_Node> split(int index) {
    if (this.weight <= index) {
      //When we travel to the left on our way up the tree, we will never orphan a node, so simply carry whatever values are present onto the next node.
      List<_Rope_Node> orphans = this.r.split(index - this.weight);

      if (orphans.length == 1 && this.r.isLeaf()) {
        this.r = null;
      }

      return orphans;
    } else {
      if (this.l != null) {
        List<_Rope_Node> orphans = this.l.split(index);

        //If the left child node contains the index, orphan that node and add it to the list
        if (orphans.length > 0) {
          //add the right node to the list of orphans
          orphans.add(this.r);
          this.r = null;

          //re-define the weight of this node taking into account any changes that may have occured further down the tree
          this.weight = this.l.getWeight();
        }
        return orphans;
      } else {
        if (index == 0) {
          //Return a list with this as it's only element
          List<_Rope_Node> new_orphan_list = new List<_Rope_Node>();
          new_orphan_list.add(this);
          return new_orphan_list;
        } else {
          //create a left node, return an orphaned right node
          this.l = new _Rope_Node.init(this.val.substring(0, index));
          _Rope_Node orphan =
          new _Rope_Node.init(this.val.substring(index, this.val.length));
          this.val = null;
          this.weight = this.l.weight;

          List<_Rope_Node> new_orphans_list = new List<_Rope_Node>();
          new_orphans_list.add(orphan);
          return new_orphans_list;
        }
      }
    }
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
        this.r = _Rope_Node.move(this.r);
      }
      this.r.setIndex(index - this.weight, val);
    } else {
      if (this.l != null) {
        if (this.l.isShared()) {
          this.l = _Rope_Node.move(this.l);
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
  num getWeight() {
    if (this.isLeaf()) {
      return this.weight;
    } else {
      return this.l.getWeight() + (this.r != null ? this.r.getWeight() : 0);
    }
  }

  //Utility method that returns true if the node is a leaf node
  bool isLeaf() {
    return this.val != null || this.val == "";
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

