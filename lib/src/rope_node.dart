class Rope_Node {
  //Fields
  Rope_Node l, r;
  num weight;
  String val;
  num refs;

  //Constructors
  Rope_Node() {
    this.weight = 0;
    this.refs = 1;
  }

  Rope_Node.init(String input) {
    this.refs = 1;
    if (input.length <= 10) {
      this.val = input;
      this.weight = input.length;
    } else {
      this.l = new Rope_Node.init(input.substring(0, input.length ~/ 2));
      this.r =
      new Rope_Node.init(input.substring(input.length ~/ 2, input.length));

      this.weight = this.l.getWeight();
    }
  }

  //Static method for moving the reference to a node if we are mutating it and it has multiple references
  static Rope_Node move(Rope_Node it) {
    String content = it.getContent();
    Rope_Node new_node = new Rope_Node.init(content);
    it.removeRefs();
    return new_node;
  }

  //Method for splitting a rope at a given index. Returns orphaned nodes which are re-concated in the parent function
  List<Rope_Node> split(int index) {
    if (this.weight <= index) {
      //When we travel to the left on our way up the tree, we will never orphan a node, so simply carry whatever values are present onto the next node.
      List<Rope_Node> orphans = this.r.split(index - this.weight);

      if (orphans.length == 1 && this.r.isLeaf()) {
        this.r = null;
      }

      return orphans;
    } else {
      if (this.l != null) {
        List<Rope_Node> orphans = this.l.split(index);

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
          List<Rope_Node> new_orphan_list = new List<Rope_Node>();
          new_orphan_list.add(this);
          return new_orphan_list;
        } else {
          //create a left node, return an orphaned right node
          this.l = new Rope_Node.init(this.val.substring(0, index));
          Rope_Node orphan =
          new Rope_Node.init(this.val.substring(index, this.val.length));
          this.val = null;
          this.weight = this.l.weight;

          List<Rope_Node> new_orphans_list = new List<Rope_Node>();
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
        this.r = Rope_Node.move(this.r);
      }
      this.r.setIndex(index - this.weight, val);
    } else {
      if (this.l != null) {
        if (this.l.isShared()) {
          this.l = Rope_Node.move(this.l);
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