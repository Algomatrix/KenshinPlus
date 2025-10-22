//
//  AnalyteLexicon.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/22.
//

enum AnalyteKey: String, CaseIterable {
    case WBC, RBC, HGB, HCT, PLT
    case AST, ALT, ALP, GGT, LDH
    case TP, ALB, CRE, eGFR, UA
    case GLU, HbA1c
    case LDL, HDL, TG, TC
}

struct AnalyteLexicon {
  static let labels: [AnalyteKey: [String]] = [
    .WBC: [
      "白血球","白血球数",
      "wbc","wb c","w b c",
      "white blood cell","white blood cells",
      "leukocyte","leukocytes",
      "wbc count","total wbc"
    ],
    .RBC: [
      "赤血球","赤血球数",
      "rbc","rb c","r b c",
      "red blood cell","red blood cells",
      "rbc count","total rbc"
    ],
    .HGB: [
      "ヘモグロビン","血色素","血色素量",
      "hemoglobin","hgb","hb","hb g/dl","hb(g/dl)"
    ],
    .HCT: ["ヘマトクリット","ヘマトクリット値","hct","hematocrit"],
    .PLT: ["血小板数","plt","platelet"],
    
    // Liver
    .AST: ["ast(got)","ast","got"],
    .ALT: ["alt(gpt)","alt (gpt)","alt","gpt"],
    .GGT: ["γ-gt","y-gt","γgt","y-gt(y-gtp)","γ-gtp","ggt"],
    .ALP: ["alp ifcc","alp"],
    .LDH: ["ld ifcc","ldh","ld"],

    // Renal / urate
    .TP:  ["総蛋白","総たんぱく","total protein","tp"],
    .ALB: ["アルブミン","albumin","alb"],
    .CRE: ["クレアチニン","creatinine","cre","cr"],
    .eGFR:["egfr"],
    .UA:  ["尿酸","uric acid","ua"],
    
    // Metabolism
    .GLU: ["グルコース（血糖）","血糖","空腹時血糖","glucose","glu"],
    .HbA1c:["hba1c","hb a1c","hba 1c ngsp","ヘモグロビンa1c","HbA1c"],
    
    // Lipids
    .LDL: ["ldlコレステロール","ldl-c","ldl"],
    .HDL: ["hdlコレステロール","hdl-c","hdl"],
    .TG:  ["中性脂肪（tg）","中性脂肪","トリグリセリド","triglycerides","tg"],
    .TC:  ["総コレステロール","total cholesterol","tc"]
  ]
}
