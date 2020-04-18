/*
Sudoku solving program: Solvens any sudoku that doesn't require guessing. 

For further reading / explenation of the code, see: https://joepeijkemans.nl/Portfolio/Projects/ProcessingSketches/index.php#SudokuSolver

s
Build by Joep Eijkemans
www.joepeijkemans.nl

Processing 3.4
*/
int [] possibleNumbers = {1, 2, 3, 4, 5, 6, 7, 8, 9};

int [][] givenValues = {
  {5, 1, 0, 0, 3, 6, 0, 0, 0}, 
  {0, 0, 0, 8, 0, 0, 7, 3, 0}, 
  {2, 0, 0, 0, 0, 0, 0, 0, 0}, 
  {6, 0, 0, 7, 0, 0, 0, 0, 0}, 
  {7, 0, 0, 0, 0, 0, 0, 0, 2}, 
  {0, 0, 0, 0, 5, 8, 0, 0, 0}, 
  {0, 4, 0, 0, 0, 0, 0, 5, 0}, 
  {9, 6, 0, 0, 0, 1, 0, 2, 0}, 
  {1, 0, 0, 5, 4, 0, 6, 0, 0}

};

int [] []IgnoredMatches ={};
Field [] fields;

boolean solutionFound = false;
int requiredIterations;


void setup() {
  size(0, 0);
  background(255);

  fields = new Field[81];

  int index = 0;
  int content;
  boolean Fixed;
  int [] options = {};
  for (int i = 0; i < 9; i++) {
    for (int p = 0; p < 9; p++) {
      options = new int[0];
      if (givenValues[i][p] != 0) {
        content = givenValues[i][p];
        Fixed = true;
        append(options, content);
      } else {
        options = possibleNumbers;
        requiredIterations++;
        content = 0;
        Fixed = false;
      }
      fields[index++]= new Field(p, i, content, Fixed, options);
    }
  }

  printSudoku();
  for (int i = 0; i <= requiredIterations; i++) {
    println("\nIteration " + i + ":");
    updateOptions();
  }
  printSudoku();
  /*for (int i = 0; i < fields.length; i++) {
   if (!fields[i].Fixed) {
   println("\n field: " + i + " Options: ");
   println(fields[i].Options);
   println("");
   }
   }*/
}



void updateOptions() {
  solutionFound = false;
  for (int i = 0; i < 9; i++) { //checks all possible options for each field
    //println("working on i: " + i);
    updateRowOptions(i);
    updateColumnOptions(i);
    updateBoxOptions(i);
  }
  for (int i = 0; i < fields.length; i++) { // if one field only has one option -> fill it in
    if (!fields[i].Fixed && !solutionFound) {
      if (fields[i].Options.length == 1) {
        println("(Exclusion)  solution found for field " + i + ": " + fields[i].Options[0]);
        fillField(i, fields[i].Options[0]);
      }
    }
  }


  if (!solutionFound) { //check if a certain field is the only one in a row, column or field with a specific solution
    for (int i = 0; i < 9; i++) {
      checkRowExclusivity(i);
      checkColumnExclusivity(i);
      checkBoxExclusivity(i);
    }
  }

  if (!solutionFound) { //check if a certain field is the only one in a row, column or field with a specific solution
    for (int i = 0; i < 9; i++) {
      if (!solutionFound) checkRowDivision(i);
      if (!solutionFound) checkColumnDivision(i);
      if (!solutionFound) checkBoxDivision(i);
    }
  }
}

void checkBoxDivision(int BoxNumber) {
  int BoxX = BoxNumber % 3;
  int BoxY = BoxNumber / 3;

  int NumberOfMatches = 0;

  int [] chosenArray = {};
  int [] matchingFields = {};
  //println("START");
  for (int i = BoxY * 3; i < (BoxY * 3) + 3; i++) {
    if (solutionFound) break;
    for (int j = BoxX * 3; j < (BoxX * 3) + 3; j++) {
      if (solutionFound) break;
      for (int n = BoxY * 3; n < (BoxY * 3) + 3; n++) {

        for (int m = BoxX * 3; m < (BoxX * 3) + 3; m++) {
          if ((i * 9) + j > (n * 9) + m) {
            //println("value at " + ((i * 9) + j) + ": " +  fields[(i * 9) + j].Value);
            if (chosenArray.length == 0 || compareArray(chosenArray, fields[(i * 9) + j].Options)) {
              if (compareArray(fields[(i * 9) + j].Options, fields[(n * 9) + m].Options)) {
                //println("MATCHING ARRAYS: " + ((i * 9) + j), ((n * 9) + m));
                chosenArray = fields[(i * 9) + j].Options;
                if (matchingFields.length == 0) { 
                  matchingFields = append(matchingFields, ((i * 9) + j));
                  matchingFields = append(matchingFields, ((n * 9) + m));
                } else
                {
                  matchingFields = append(matchingFields, ((n * 9) + m));
                }
                NumberOfMatches++;
                break;
              }
            }
          } else {
            break;
          }
        }
      }
    }
  }
  //println("matches: " + NumberOfMatches);
  //println(matchingFields);
  boolean skip = false;
  if (NumberOfMatches == chosenArray.length - 1) {
    //println("we can remove options elsewhere");
    for (int i = BoxY * 3; i < (BoxY * 3) + 3; i++) {
      for (int j = BoxX * 3; j < (BoxX * 3) + 3; j++) {
        //compare options
        //skip matching arrays

        for (int q = 0; q < matchingFields.length; q++) {
          if (((i * 9) + j) == matchingFields[q]) { 
            skip = true;
          }
        }

        if (skip) {
          skip = false;
          break;
        }
        for (int p = 0; p < chosenArray.length; p++) {
          for (int k = 0; k < fields[((i * 9) + j)].Options.length; k++) {
            if (fields[((i * 9) + j)].Options[k] == chosenArray[p]) {
              fields[((i * 9) + j)].Options = removeItemInArray(fields[((i * 9) + j)].Options, k);
              println("(Square) Options" + chosenArray[p] + " removed from field " + ((i * 9) + j));
              solutionFound = true;
            }
          }
        }
      }
    }/*
    for (int i = 0; i < matchingFields.length - 1; i++) {
     for (int p = 0; p < matchingFields.length; p++) {
     if (i != p) {
     if (fields[matchingFields[i]].X == fields[matchingFields[p]].X) {
     println("Same X");
     //println(fields[matchingFields[i]].Options);
     
     for (int m = fields[matchingFields[i]].X; m < 73 + fields[matchingFields[i]].X; m += 9) {
     //compare options
     //skip matching arrays
     
     
     if (m < ((3 *BoxY) * 9) || m > ((3 *BoxY) * 9) + 27) {
     for (int n = 0; n < chosenArray.length; n++) {
     for (int k = 0; k < fields[m].Options.length; k++) {
     if (fields[m].Options[k] == chosenArray[n]) {
     fields[m].Options = removeItemInArray(fields[m].Options, k);
     println("(Column) Options " + chosenArray[n] + " removed from field " + m);
     solutionFound = true;
     }
     }
     }
     }
     }
     } else if (fields[matchingFields[i]].Y == fields[matchingFields[p]].Y) {
     println("Same Y");
     //println(fields[matchingFields[i]].Options);
     
     for (int n = (fields[matchingFields[i]].Y * 9); n < (fields[matchingFields[i]].Y * 9) + 9; n++) {
     
     if (n < ((BoxX * 3) * 9) + (BoxX * 3) || n > ((3 *BoxY) * 9) + 27 + (BoxX * 3)) {
     //println("n: " + n);
     for (int m = 0; m < chosenArray.length; m++) {
     for (int k = 0; k < fields[n].Options.length; k++) {
     if (fields[n].Options[k] == chosenArray[m]) {
     println("(Row) Options " + chosenArray[m] + " removed from field " + n);
     fields[n].Options = removeItemInArray(fields[n].Options, k);
     solutionFound = true;
     }
     }
     }
     }
     }
     }
     }
     }
     }*/
  }
  if (!solutionFound) {
    //println("---");
  }
}





void checkColumnDivision(int ColumnIndex) {
  int NumberOfMatches = 0;

  int [] chosenArray = {};

  int [] skipArray = {};

  int [] matchingFields = {};
  int undecidedFields = 0;

  for (int i = ColumnIndex; i < 73 + ColumnIndex; i += 9) {
    if (!fields[i].Fixed) undecidedFields++;
  }

  for (int l = 0; l < undecidedFields / 2; l++) {
    //println("\nITERATION OF CULUMNS : " + l);
    if (solutionFound) break;
    for (int i = ColumnIndex; i < 73 + ColumnIndex; i += 9) {
      if (solutionFound) break;
      for (int p = i + 9; p <  73 + ColumnIndex; p+= 9) {
        if (!compareArray(fields[i].Options, skipArray)) {
          if (chosenArray.length == 0 || compareArray(chosenArray, fields[i].Options)) {
            if (compareArray(fields[i].Options, fields[p].Options)) {
              println("MATCHING ARRAYS: " + i, p);
              chosenArray = fields[i].Options;
              if (matchingFields.length == 0) { 
                matchingFields = append(matchingFields, i);
                matchingFields = append(matchingFields, p);
              } else
              {
                matchingFields = append(matchingFields, p);
              }
              NumberOfMatches++;
              break;
            }
          }
        }
      }
    }
    //println("matches: " + NumberOfMatches);
    //println(matchingFields);
    if (NumberOfMatches == chosenArray.length - 1) {
      //println("we can remove options elsewhere");
      for (int i = ColumnIndex; i < 73 + ColumnIndex; i += 9) {
        //compare options
        //skip matching arrays

        for (int q = 0; q < matchingFields.length; q++) {
          if (i == matchingFields[q]) i += 9;
        }

        for (int p = 0; p < chosenArray.length; p++) {
          for (int k = 0; k < fields[i].Options.length; k++) {
            if (fields[i].Options[k] == chosenArray[p]) {
              fields[i].Options = removeItemInArray(fields[i].Options, k);
              println("(Column) Options " + chosenArray[p] + " removed from field " + i);
              solutionFound = true;
            }
          }
        }
      }
    }
    if (!solutionFound) {
      skipArray = chosenArray;
      chosenArray = new int [0];
      matchingFields = new int [0];
      NumberOfMatches = 0;
    }
  }
}



void checkRowDivision(int RowIndex) {
  int NumberOfMatches = 0;

  int [] chosenArray = {};
  int [] matchingFields = {};

  int [] skipArray = {};

  int undecidedFields = 0;

  for (int i = (RowIndex * 9); i < (RowIndex * 9) + 9; i++) {
    if (!fields[i].Fixed) undecidedFields++;
  }

  for (int l = 0; l < undecidedFields / 2; l++) {
    //println("\nITERATION OF CULUMNS : " + l);
    if (solutionFound) break;
    for (int i = (RowIndex * 9); i < (RowIndex * 9) + 9; i++) { //for every field in row
      if (solutionFound) break;
      //println("value at " + i + ": " + fields[i].Value);
      for (int p = i + 1; p < (RowIndex * 9) + 9; p++) {
        //println(i, p);
        if (!compareArray(fields[i].Options, skipArray)) {
          if (chosenArray.length == 0 || compareArray(chosenArray, fields[i].Options)) {
            if (compareArray(fields[i].Options, fields[p].Options)) {
              //println("MATCHING ARRAYS: " + i, p);
              chosenArray = fields[i].Options;
              if (matchingFields.length == 0) { 
                matchingFields = append(matchingFields, i);
                matchingFields = append(matchingFields, p);
              } else
              {
                matchingFields = append(matchingFields, p);
              }
              NumberOfMatches++;
              break;
            }
          }
        }
      }
    }
    //println("matches: " + NumberOfMatches);
    //println(matchingFields);
    if (NumberOfMatches == chosenArray.length - 1) {
      //println("we can remove options elsewhere");
      for (int i = (RowIndex * 9); i < (RowIndex * 9) + 9; i++) {
        //compare options
        //skip matching arrays

        for (int q = 0; q < matchingFields.length; q++) {
          if (i == matchingFields[q]) i += 1;
        }

        for (int p = 0; p < chosenArray.length; p++) {
          for (int k = 0; k < fields[i].Options.length; k++) {
            if (fields[i].Options[k] == chosenArray[p]) {
              println("(Row) Options " + chosenArray[p] + " removed from field " + i);
              fields[i].Options = removeItemInArray(fields[i].Options, k);
              solutionFound = true;
            }
          }
        }
      }
    }
    if (!solutionFound) {
      skipArray = chosenArray;
      chosenArray = new int [0];
      matchingFields = new int [0];
      NumberOfMatches = 0;
    }
  }
}


boolean compareArray(int [] array1, int [] array2) {
  boolean match = true;

  if (array1.length != array2.length || array1.length == 0) {
    match = false;
    return match;
  } else {
    for (int i = 0; i < array1.length; i++) {
      if (array1[i] != array2[i]) {
        match = false;
        break;
      }
    }
    return match;
  }
}

void checkBoxExclusivity(int BoxNumber) {
  int BoxX = BoxNumber % 3;
  int BoxY = BoxNumber / 3;

  boolean AlreadyMatched;
  for (int i = BoxY * 3; i < (BoxY * 3) + 3; i++) {
    if (solutionFound) break;
    for (int j = BoxX * 3; j < (BoxX * 3) + 3; j++) {
      int [] OtherOptions = {};
      for (int n = BoxY * 3; n < (BoxY * 3) + 3; n++) {
        for (int m = BoxX * 3; m < (BoxX * 3) + 3; m++) {


          if (((i * 9) + j) !=((n * 9) + m)) { //i = current box index, p = all other boxes index
            //println("Current field: " + i + " compared to field: "+ p);
            for (int q = 0; q < fields[(n * 9) + m].Options.length; q++) {
              AlreadyMatched = false;
              for (int k = 0; k < OtherOptions.length; k++) {
                if (OtherOptions[k] == fields[(n * 9) + m].Options[q]) {
                  AlreadyMatched = true;
                  break;
                }
              }
              if (!AlreadyMatched)OtherOptions = append(OtherOptions, fields[(n * 9) + m].Options[q]);
            }
          }
        }
      }
      //println("\n Options for field " + ((i * 9) + j) + ": ");
      //println(fields[(i * 9) + j].Options);
      //println("\n OtherOptions in this row for field " + ((i * 9) + j) + ": ");
      //println(OtherOptions);
      //println("\n Difference: ");
      //println(GetDifference(fields[((i * 9) + j)].Options, OtherOptions));

      if (GetDifference(fields[((i * 9) + j)].Options, OtherOptions).length == 1) {
        println("(Square)     solution found for field " + ((i * 9) + j) + ": "+ GetDifference(fields[((i * 9) + j)].Options, OtherOptions)[0]);
        fillField((i * 9) + j, GetDifference(fields[((i * 9) + j)].Options, OtherOptions)[0]);
      }
    }
  }
}

void fillField(int index, int value) {
  solutionFound = true;
  fields[index].Value = value;
  fields[index].Options = new int [0];
  fields[index].Fixed = true;
}
void checkColumnExclusivity(int ColumnIndex) {


  boolean AlreadyMatched;
  for (int i = ColumnIndex; i < 73 + ColumnIndex; i+= 9) {
    if (solutionFound) break;
    int [] OtherOptions = {};
    for (int p = ColumnIndex; p < 73 + ColumnIndex; p+= 9) {

      if (i != p) { //i = current box index, p = all other boxes index
        //println("Current field: " + i + " compared to field: "+ p);
        for (int q = 0; q < fields[p].Options.length; q++) {
          AlreadyMatched = false;
          for (int k = 0; k < OtherOptions.length; k++) {
            if (OtherOptions[k] == fields[p].Options[q]) {
              AlreadyMatched = true;
              break;
            }
          }
          if (!AlreadyMatched)OtherOptions = append(OtherOptions, fields[p].Options[q]);
        }
      }
    }
    //if (ColumnIndex == 8) {
    //println("\n Options for field " + i/9 + ": ");
    //println(fields[i].Options);
    //}
    //println("\n OtherOptions in this row for field " + i/9 + ": ");
    //println(OtherOptions);
    //println("\n Difference: ");
    //println(GetDifference(fields[i].Options, OtherOptions));
    if (GetDifference(fields[i].Options, OtherOptions).length == 1) {
      println("(vertical)   solution found for field " + i + ": "+ GetDifference(fields[i].Options, OtherOptions)[0]);
      fillField(i, GetDifference(fields[i].Options, OtherOptions)[0]);
    }
  }
}

void checkRowExclusivity(int RowIndex) {


  boolean AlreadyMatched;

  for (int i = (RowIndex * 9); i < (RowIndex * 9) + 9; i++) { //for every field in row
    if (solutionFound) break;
    int [] OtherOptions = {};
    for (int p = (RowIndex * 9); p < (RowIndex * 9) + 9; p++) { //for every field in row
      if (i != p) { //i = current box index, p = all other boxes index
        //println("Current field: " + i + " compared to field: "+ p);
        for (int q = 0; q < fields[p].Options.length; q++) {
          AlreadyMatched = false;
          for (int k = 0; k < OtherOptions.length; k++) {
            if (OtherOptions[k] == fields[p].Options[q]) {
              AlreadyMatched = true;
              break;
            }
          }
          if (!AlreadyMatched)OtherOptions = append(OtherOptions, fields[p].Options[q]);
        }
      }
    }
    //println("\n Options for field " + i + ": ");
    //println(fields[i].Options);
    //println("\n OtherOptions in this row for field " + i + ": ");
    //println(OtherOptions);
    //println("\n Difference: ");
    //println(GetDifference(fields[i].Options, OtherOptions));
    if (GetDifference(fields[i].Options, OtherOptions).length == 1) {
      println("(horizontal) solution found for field " + i + ": "+ GetDifference(fields[i].Options, OtherOptions)[0]);
      fillField(i, GetDifference(fields[i].Options, OtherOptions)[0]);
    }
  }
}

void updateBoxOptions(int BoxNumber) {
  int BoxX = BoxNumber % 3;
  int BoxY = BoxNumber / 3;
  int [] fixedNumbers = {};

  //println("Box X: " + BoxX + " Box Y: " + BoxY);
  for (int i = BoxY * 3; i < (BoxY * 3) + 3; i++) {
    for (int p = BoxX * 3; p < (BoxX * 3) + 3; p++) {
      if (fields[(i * 9) + p].Fixed) {
        fixedNumbers = append(fixedNumbers, fields[(i * 9) + p].Value);
      }
    }
  }
  for (int i = BoxY * 3; i < (BoxY * 3) + 3; i++) {
    for (int p = BoxX * 3; p < (BoxX * 3) + 3; p++) {
      if (!fields[(i * 9) + p].Fixed) {
        for (int k = 0; k < fixedNumbers.length; k++) {
          for (int q = 0; q < fields[(i * 9) + p].Options.length; q++) {
            if (fields[(i * 9) + p].Options[q] == fixedNumbers[k]) {
              fields[(i * 9) + p].Options = removeItemInArray(fields[(i * 9) + p].Options, q);
            }
          }
        }
      }
    }
  }
}
void updateColumnOptions(int ColumnIndex) {
  int [] fixedNumbers = {};
  for (int i = ColumnIndex; i < 73 + ColumnIndex; i+= 9) {
    if (fields[i].Fixed) {
      fixedNumbers = append(fixedNumbers, fields[i].Value);
    }
  }
  for (int i = ColumnIndex; i < 73 + ColumnIndex; i+= 9) {
    if (!fields[i].Fixed) {
      for (int p = 0; p < fixedNumbers.length; p++) {
        for (int q = 0; q < fields[i].Options.length; q++) {
          if (fields[i].Options[q] == fixedNumbers[p]) {
            fields[i].Options = removeItemInArray(fields[i].Options, q);
          }
        }
      }
      fixedNumbers = append(fixedNumbers, fields[i].Value);
    }
  }
}

void updateRowOptions(int RowIndex) {
  int [] fixedNumbers = {};
  for (int i = (RowIndex * 9); i < (RowIndex * 9) + 9; i++) {
    if (fields[i].Fixed) {
      fixedNumbers = append(fixedNumbers, fields[i].Value);
    }
  }
  for (int i = (RowIndex * 9); i < (RowIndex * 9) + 9; i++) {
    if (!fields[i].Fixed) {
      for (int p = 0; p < fixedNumbers.length; p++) {
        for (int q = 0; q < fields[i].Options.length; q++) {
          if (fields[i].Options[q] == fixedNumbers[p]) {
            fields[i].Options = removeItemInArray(fields[i].Options, q);
          }
        }
      }
      fixedNumbers = append(fixedNumbers, fields[i].Value);
    }
  }
}

int[] GetDifference(int [] array1, int [] array2) {
  for (int p = 0; p < array2.length; p++) {
    for (int i = 0; i < array1.length; i++) {
      if (array1[i] == array2[p]) {
        array1 = removeItemInArray(array1, i);
      }
    }
  }
  return array1;
}

void printSudoku() {
  int index = 0;
  int previ = 0;
  println("\n");
  for (int i = 0; i < 9; i++) {
    for (int q = 0; q < 9; q++) {
      if (q % 3 == 0 && q > 1)print("|");
      if (i % 3 == 0 && i != previ) {
        println("-----------------------------");
        previ = i;
      }
      print(" " + fields[index++].Value + " ");
    }
    println("");
  }
  println("\n");
}

int[] removeItemInArray(int array[], int item) {
  int outgoing[] = new int[array.length - 1];
  System.arraycopy(array, 0, outgoing, 0, item);
  System.arraycopy(array, item+1, outgoing, item, array.length - (item + 1));
  return outgoing;
} 
