(* Generate Lab1 Variant 6 notebook. Russian via \:XXXX.
   Visual rules taken from lab1/input/style-math.nb (Input/Output frames,
   Times New Roman printout). Arial Cyr is not on this Mac, so Arial.
   Diploma headers/footers from that stylesheet are not used. *)

root = DirectoryName[$InputFileName];
If[root === "" || root === $Failed, root = Directory[]];
outDir = FileNameJoin[{root, "output"}];
nbPath = FileNameJoin[{outDir, "lab1-variant-6.nb"}];
pdfPath = FileNameJoin[{outDir, "lab1-variant-6.pdf"}];

(* Overlay from style-math.nb onto Default.nb. *)
labStyle = Notebook[{
  Cell[StyleData[StyleDefinitions -> "Default.nb"]],
  Cell[StyleData["Input"],
    CellFrame -> {{0.25, 0.25}, {0, 0.25}},
    CellMargins -> {{54, 24}, {-1, 2}},
    FontFamily -> "Arial",
    FontSize -> 12,
    FontWeight -> "Bold",
    Background -> RGBColor[0.3098, 0.95686, 0.721569]
  ],
  Cell[StyleData["Input", "Printout"],
    FontFamily -> "Times New Roman",
    FontSize -> 10,
    FontWeight -> "Plain",
    FontColor -> RGBColor[0.1, 0.15, 0.7],
    Background -> RGBColor[1, 1, 1]
  ],
  Cell[StyleData["Output"],
    CellFrame -> {{0.25, 0.25}, {0.25, 0}},
    CellMargins -> {{54, 24}, {10, 0}},
    FontFamily -> "Arial",
    FontSize -> 14,
    FontWeight -> "Bold",
    Background -> RGBColor[0.6777, 0.9444, 0.433]
  ],
  Cell[StyleData["Output", "Printout"],
    CellMargins -> {{54, 24}, {10, 0}},
    FontFamily -> "Times New Roman",
    FontSize -> 12,
    Background -> RGBColor[1, 1, 1]
  ],
  Cell[StyleData["Print"],
    FontFamily -> "Arial",
    FontSize -> 12
  ],
  Cell[StyleData["Print", "Printout"],
    FontFamily -> "Times New Roman",
    FontSize -> 10,
    Background -> RGBColor[1, 1, 1]
  ],
  Cell[StyleData["CellLabel"],
    FontFamily -> "Arial",
    FontSize -> 9,
    FontColor -> RGBColor[0, 0, 1]
  ],
  Cell[StyleData["CellLabel", "Printout"],
    FontFamily -> "Times New Roman",
    FontSize -> 8,
    FontColor -> RGBColor[0, 0, 1]
  ]
}];

writeEvalString[nb_, str_String] := Module[{},
  SelectionMove[nb, After, Notebook];
  NotebookWrite[nb, Cell[str, "Input"]];
  SelectionMove[nb, Previous, Cell];
  FrontEndTokenExecute[nb, "SelectionConvert", "StandardForm"];
  Pause[0.4];
  SelectionEvaluateCreateCell[nb];
  Pause[1.2];
];

writeEvalBoxes[nb_, boxes_List] := Module[{},
  SelectionMove[nb, After, Notebook];
  NotebookWrite[nb, Cell[BoxData[boxes], "Input"]];
  SelectionMove[nb, Previous, Cell];
  SelectionEvaluateCreateCell[nb];
  Pause[1.2];
];

sRound = "\:043F\:043E\:0433\:0440\:0435\:0448\:043D\:043E\:0441\:0442\:044C \:043E\:043A\:0440\:0443\:0433\:043B\:044F\:0435\:043C \:0432 \:0431\:041E\:043B\:044C\:0448\:0443\:044E \:0441\:0442\:043E\:0440\:043E\:043D\:0443 \:0434\:043E \:0434\:0432\:0443\:0445 \:0437\:043D\:0430\:0447\:0430\:0449\:0438\:0445 \:0446\:0438\:0444\:0440";
sRoundPlural = "\:043F\:043E\:0433\:0440\:0435\:0448\:043D\:043E\:0441\:0442\:0438 \:043E\:043A\:0440\:0443\:0433\:043B\:044F\:0435\:043C \:0432 \:0431\:041E\:043B\:044C\:0448\:0443\:044E \:0441\:0442\:043E\:0440\:043E\:043D\:0443 \:0434\:043E \:0434\:0432\:0443\:0445 \:0437\:043D\:0430\:0447\:0430\:0449\:0438\:0445 \:0446\:0438\:0444\:0440";
sSemi = "\:043F\:043E\:043B\:0443\:043F\:0435\:0440\:0438\:043C\:0435\:0442\:0440 \:0442\:0440\:0435\:0443\:0433\:043E\:043B\:044C\:043D\:0438\:043A\:0430";
sCircle = "\:043F\:043B\:043E\:0449\:0430\:0434\:044C \:043A\:0440\:0443\:0433\:0430";

commentLine[txt_] := RowBox[{"(*", txt, "*)"}];

sciOf[arg_] := RowBox[{"ScientificForm", "[", RowBox[{arg, ",", "2"}], "]"}];

cell1 = "\:0412\:0430\:0440\:0438\:0430\:043D\:0442 6;
\:0417\:0430\:0434\:0430\:043D\:0438\:0435 1;
SuperStar[\[Alpha]] = 50*60*60 + 58*60 + 38; SuperStar[\[CapitalDelta]\[Alpha]] = 2;
N[(SuperStar[\[CapitalDelta]\[Alpha]]/SuperStar[\[Alpha]])*100, 3]";

cell2boxes = {
  commentLine[sRound],
  RowBox[{"Print", "[", RowBox[{
    ToBoxes["\:041E\:0442\:0432\:0435\:0442: \:043E\:0442\:043D\:043E\:0441\:0438\:0442\:0435\:043B\:044C\:043D\:0430\:044F \:043F\:043E\:0433\:0440\:0435\:0448\:043D\:043E\:0441\:0442\:044C 0<=\:03B4\:03B1*<= "],
    ",",
    sciOf[RowBox[{"Ceiling", "[", RowBox[{"%", ",", "0.0001"}], "]"}]],
    ",",
    ToBoxes["%"]
  }], "]"}]
};

cell3 = "\:0417\:0430\:0434\:0430\:043D\:0438\:0435 2;
SuperStar[x] = 1400231/100000; SuperStar[\[CapitalDelta]x] = 0.1*10^(-3);
Print[\"\:041E\:0442\:0432\:0435\:0442: \:0437\:043D\:0430\:0447\:0430\:0449\:0438\:0435 \:0446\:0438\:0444\:0440\:044B \:0447\:0438\:0441\:043B\:0430 \", z = RealDigits[SuperStar[x]][[1]], \".\"];
p = RealDigits[SuperStar[x]][[2]];
Table[If[SuperStar[\[CapitalDelta]x] <= (1/2)*10^(p-i), Print[\"\:0426\:0438\:0444\:0440\:0430 \", z[[i]], \" - \:0432\:0435\:0440\:043D\:0430\:044F.\"], Print[\"\:0426\:0438\:0444\:0440\:0430 \", z[[i]], \" - \:0441\:043E\:043C\:043D\:0438\:0442\:0435\:043B\:044C\:043D\:0430\:044F.\"]], {i, 1, Length[z]}];";

cell4 = "\:0417\:0430\:0434\:0430\:043D\:0438\:0435 3;
SuperStar[a] = 502/100; SuperStar[b] = 603/100; SuperStar[c] = 848/100; SuperStar[\[CapitalDelta]a] = SuperStar[\[CapitalDelta]b] = SuperStar[\[CapitalDelta]c] = 1/100;
P[A_, B_, C_] = (A + B + C)/2;
SuperStar[\[CapitalDelta]P] = N[(D[P[A, B, C], A] SuperStar[\[CapitalDelta]a] + D[P[A, B, C], B] SuperStar[\[CapitalDelta]b] + D[P[A, B, C], C] SuperStar[\[CapitalDelta]c]) /. {A -> SuperStar[a], B -> SuperStar[b], C -> SuperStar[c]}, 3]
SuperStar[\[Delta]P] = N[(SuperStar[\[CapitalDelta]P]/P[SuperStar[a], SuperStar[b], SuperStar[c]])*100, 3]";

cell5boxes = {
  commentLine[sRoundPlural],
  RowBox[{
    RowBox[{"Print", "[", RowBox[{
      ToBoxes["\:041E\:0442\:0432\:0435\:0442: \:0430\:0431\:0441\:043E\:043B\:044E\:0442\:043D\:0430\:044F \:043F\:043E\:0433\:0440\:0435\:0448\:043D\:043E\:0441\:0442\:044C 0<=\[CapitalDelta]P*<= "],
      ",",
      RowBox[{"Ceiling", "[", RowBox[{SuperscriptBox["\[CapitalDelta]P", "*"], ",", "0.001"}], "]"}],
      ",",
      ToBoxes[" \:0441\:043C ;"]
    }], "]"}],
    ";"
  }],
  RowBox[{"Print", "[", RowBox[{
    ToBoxes["\:043E\:0442\:043D\:043E\:0441\:0438\:0442\:0435\:043B\:044C\:043D\:0430\:044F \:043F\:043E\:0433\:0440\:0435\:0448\:043D\:043E\:0441\:0442\:044C 0<=\:03B4P*<= "],
    ",",
    RowBox[{"Ceiling", "[", RowBox[{SuperscriptBox["\[Delta]P", "*"], ",", "0.01"}], "]"}],
    ",",
    ToBoxes["%"],
    ",",
    ToBoxes["."]
  }], "]"}]
};

cell6boxes = {
  RowBox[{RowBox[{"\:0417\:0430\:0434\:0430\:043D\:0438\:0435", " ", "4"}], ";"}],
  RowBox[{RowBox[{"rr", "=", "100"}], ";"}],
  commentLine[sCircle],
  RowBox[{RowBox[{RowBox[{"S", "[", "R_", "]"}], "=", RowBox[{"\[Pi]", " ", SuperscriptBox["R", "2"]}]}], ";"}],
  RowBox[{
    SuperscriptBox["\[Delta]S", "*"], "=",
    RowBox[{"N", "[", RowBox[{
      RowBox[{"Reduce", "[", RowBox[{
        RowBox[{"{", RowBox[{
          RowBox[{RowBox[{"Abs", "[", RowBox[{RowBox[{"S", "[", "rr", "]"}], "-", RowBox[{"S", "[", RowBox[{"rr", "+", SuperscriptBox["\[CapitalDelta]rr", "*"]}], "]"}]}], "]"}], "\[LessEqual]", "1"}], ",",
          RowBox[{RowBox[{"Abs", "[", RowBox[{RowBox[{"S", "[", "rr", "]"}], "-", RowBox[{"S", "[", RowBox[{"rr", "-", SuperscriptBox["\[CapitalDelta]rr", "*"]}], "]"}]}], "]"}], "\[LessEqual]", "1"}], ",",
          RowBox[{SuperscriptBox["\[CapitalDelta]rr", "*"], "\[GreaterEqual]", "0"}]
        }], "}"}], ",",
        SuperscriptBox["\[CapitalDelta]rr", "*"]
      }], "]"}], ",", "3"
    }], "]"}]
  }]
};

cell7boxes = {
  commentLine[sRound],
  RowBox[{"Print", "[", RowBox[{
    ToBoxes["\:041E\:0442\:0432\:0435\:0442: \:0430\:0431\:0441\:043E\:043B\:044E\:0442\:043D\:0430\:044F \:043F\:043E\:0433\:0440\:0435\:0448\:043D\:043E\:0441\:0442\:044C "],
    ",",
    RowBox[{
      RowBox[{"N", "[", RowBox[{SuperscriptBox["\[Delta]S", "*"], ",", "2"}], "]"}],
      "/.",
      RowBox[{RowBox[{"x_", "?", "Positive"}], "\[RuleDelayed]", RowBox[{"ScientificForm", "[", RowBox[{"x", ",", "2"}], "]"}]}]
    }],
    ",",
    ToBoxes[" \:0441\:043C"],
    ",",
    ToBoxes["."]
  }], "]"}]
};

UsingFrontEnd[
  nb = CreateDocument[{},
    Visible -> False,
    WindowTitle -> "Lab1 Variant 6",
    StyleDefinitions -> labStyle
  ];
  SetOptions[nb,
    PrintingStyleEnvironment -> "Printout",
    ShowPageBreaks -> False,
    PageHeaders -> {{None, None, None}, {None, None, None}},
    PageFooters -> {{None, None, None}, {None, None, None}},
    PrintingOptions -> {
      "PaperSize" -> {595.28, 841.89},
      "PageSize" -> {595.28, 841.89},
      "PrintingMargins" -> {{54, 54}, {54, 54}},
      "FirstPageHeader" -> False,
      "FirstPageFooter" -> False,
      "RestPagesHeader" -> False,
      "RestPagesFooter" -> False
    }
  ];
  writeEvalString[nb, cell1];
  writeEvalBoxes[nb, cell2boxes];
  writeEvalString[nb, cell3];
  writeEvalString[nb, cell4];
  writeEvalBoxes[nb, cell5boxes];
  writeEvalBoxes[nb, cell6boxes];
  writeEvalBoxes[nb, cell7boxes];
  Pause[1];
  NotebookSave[nb, nbPath];
  Export[pdfPath, nb, "PDF"];
  NotebookClose[nb];
];

Print["Saved: ", nbPath];
Print["Saved: ", pdfPath];
Print["NB size=", FileByteCount[nbPath]];
Print["PDF size=", FileByteCount[pdfPath]];
