class Field {
  int Value;
  int X, Y;
  boolean Fixed;
  int [] Options;
  Field(int Xpos, int Ypos, int Content, boolean Done, int [] potentialNumbers){
    X = Xpos;
    Y = Ypos;
    Value = Content;
    Fixed = Done;
    Options = potentialNumbers;
  }
  
}
