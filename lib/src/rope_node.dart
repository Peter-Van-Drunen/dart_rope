import 'dart:math';

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

      this.weight = this.l.get_weight();
    }
  }

  //Static method for moving the reference to a node if we are mutating it and it has multiple references
  static Rope_Node move(Rope_Node it) {
    String content = it.get_content();
    Rope_Node new_node = new Rope_Node.init(content);
    it.remove_refs();
    return new_node;
  }

  //Method for splitting a rope at a given index. Returns orphaned nodes which are re-concated in the parent function
  List<Rope_Node> split(int index) {
    if (this.weight <= index) {
      //When we travel to the left on our way up the tree, we will never orphan a node, so simply carry whatever values are present onto the next node.
      List<Rope_Node> orphans = this.r.split(index - this.weight);

      if (orphans.length == 1 && this.r.is_leaf()) {
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
          this.weight = this.l.get_weight();
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
  String get_index(int index) {
    if (this.weight <= index) {
      return this.r.get_index(index - this.weight);
    } else {
      if (this.l != null) {
        return this.l.get_index(index);
      } else {
        return this.val[index];
      }
    }
  }

  //Setter for indexing operation
  void set_index(int index, String val) {
    if (this.weight <= index) {
      if (this.r.is_shared()) {
        this.r = Rope_Node.move(this.r);
      }
      this.r.set_index(index - this.weight, val);
    } else {
      if (this.l != null) {
        if (this.l.is_shared()) {
          this.l = Rope_Node.move(this.l);
        }
        this.l.set_index(index, val);
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
  void add_refs() {
    this.refs++;
    if (this.r != null) {
      this.l.add_refs();
      this.r.add_refs();
    } else if (this.l != null) {
      this.l.add_refs();
    }
  }

  //Utility method to remove 1 from every ref count for this and all child nodes
  void remove_refs() {
    this.refs--;
    if (this.r != null) {
      this.l.add_refs();
      this.r.add_refs();
    } else if (this.l != null) {
      this.l.add_refs();
    }
  }

  //Utility method that gets the weight of the node
  num get_weight() {
    if (this.is_leaf()) {
      return this.weight;
    } else {
      return this.l.get_weight() + (this.r != null ? this.r.get_weight() : 0);
    }
  }

  //Utility method that returns true if the node is a leaf node
  bool is_leaf() {
    return this.val != null || this.val == "";
  }

  //Method for getting the full string content of a node and all it's children
  String get_content() {
    if (this.is_leaf()) {
      return this.val;
    } else {
      return this.l.get_content() +
          (this.r != null ? this.r.get_content() : "");
    }
  }

  num max_depth() {
    if (this.is_leaf()) {
      return 0;
    }
    return 1 +
        max(this.l.max_depth(), (this.r != null ? this.r.max_depth() : 0));
  }

  //Method for checking the ref count. Returns true if ref count is more than 1
  bool is_shared() {
    return this.refs > 1;
  }
}