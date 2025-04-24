#import "@preview/codly:1.2.0": *
#import "@preview/codly-languages:0.1.7": *
#import "@preview/chic-hdr:0.5.0": *
#import "@preview/i-figured:0.2.4"
#import "@preview/pintorita:0.1.3"
#import "@preview/gentle-clues:1.2.0": *
#import "@preview/cheq:0.2.2": checklist
#import "@preview/unify:0.7.1": num, qty, numrange, qtyrange
#import "@preview/thmbox:0.2.0": *
#import "@preview/hydra:0.6.0": hydra
#import "@preview/treet:0.1.1": *
#import "@preview/pinit:0.2.2": *
#import "@preview/cetz:0.3.2": canvas, draw, tree
#import "@preview/colorful-boxes:1.4.2": *
#import "@preview/showybox:2.0.4": *
#import "@preview/conchord:0.3.0": *
#import "@preview/badgery:0.1.1": *
#import "@preview/syntree:0.2.1": syntree
#import "@preview/physica:0.9.4": *
#import "@preview/mitex:0.2.5": *
#import "@preview/algo:0.3.4": algo, i, d, comment, code
#import "@preview/diagraph:0.3.1": *
#import "@preview/xarrow:0.3.1": xarrow, xarrowSquiggly, xarrowTwoHead
#import "@preview/neoplot:0.0.3" as gp
#import "@preview/pyrunner:0.2.0" as py
#import "@preview/note-me:0.5.0" as nt
#import "@preview/iconic-salmon-svg:3.0.0": *
#import "@preview/echarm:0.2.1"
#import "@preview/mannot:0.2.2": *
#import "@preview/tblr:0.3.1": *
#import "@preview/ourchat:0.1.0" as oc: default-profile
#import "@preview/tablem:0.2.0": tablem, three-line-table

#let Heiti = ("Times New Roman", "Heiti SC", "Heiti SC", "SimHei")
#let Songti = ("Times New Roman", "Songti SC", "Songti SC", "SimSun")
#let Zhongsong = ("Times New Roman", "STZhongsong", "SimSun")
#let Xbs = ("Times New Roman", "FZXiaoBiaoSong-B05S", "FZXiaoBiaoSong-B05S")

#let head(term, level: 1) = {
  heading(level: level, numbering: none)[
    #term
  ]
}

#let indent() = {
  box(width: 2em)
}

#let info_key(body) = {
  rect(width: 100%, inset: 2pt, stroke: none, text(font: Zhongsong, size: 16pt, body))
}

#let info_value(body) = {
  rect(
    width: 100%,
    inset: 2pt,
    stroke: (bottom: 1pt + black),
    text(font: Zhongsong, size: 16pt, bottom-edge: "descender")[ #body ],
  )
}

#let project(
  lab_name: "",
  sub_name:"",
  stu_name: "王歆喆",
  stu_num: "PB24000073",
  department: "少年班学院",
  teach:"",
  date: (2025, 1, 1),
  show_content: true,
  show_content_figure: true,
  watermark: "",
  body,
) = {
  set page("a4")
  // 封面
  align(center)[
    #image("./USTC-name.png", width: 100%)
    #set text(
      size: 26pt,
      font: Zhongsong,
      weight: "bold",
    )
    #v(0.5em)

    // 报告名
    #text(size: 24pt, font: Xbs)[
      _#lab_name _
    ]
    #text(size:16pt,font:Xbs)[
      _#sub_name _
    ]
    #image("./USTC-logo.png", width: 50%)
    #v(0.5em)

    // 个人信息
    #grid(
      columns: (70pt, 160pt),
      rows: (40pt, 40pt),
      gutter: 3pt,
      info_key("学院"),
      info_value(department),
      info_key("姓名"),
      info_value(stu_name),
      info_key("学号"),
      info_value(stu_num),
      info_key("指导老师"),
      info_value(teach)
    )
    #v(1pt)

    // 日期
    #text(font: Zhongsong, size: 14pt)[
      #date.at(0) 年 #date.at(1) 月 #date.at(2) 日
    ]
  ]
  pagebreak()

  // 目录
  if show_content {
    show outline.entry.where(level: 1): it => {
      v(12pt, weak: true)
      strong(it)
    }
    show outline.entry: it => {
      v(10pt, weak: true)
      set text(
        font: Xbs,
        size: 14pt,
      )
      it
    }
    outline(
      title: text(font: Xbs, size: 20pt)[目录],
      indent: auto,
    )
    if show_content_figure {
      text(font: Xbs, size: 14pt)[
        #i-figured.outline(title: [图表])
      ]
    }
    pagebreak()
  }

  // 页眉页脚设置
  show: chic.with(
    chic-header(
      left-side: smallcaps(
        text(size: 12pt, font: Xbs)[
          #lab_name
        ],
      ),
      right-side: text(size: 12pt, font: Xbs)[
        #chic-page-number()
      ],
      side-width: (60%, 0%, 35%),
    ),
    chic-separator(on: "header", stroke()),
    chic-offset(20%),
    chic-height(2cm),
  )

  // 正文设置
  show: thmbox-init()
  set heading(numbering: "1.1")
  show heading: i-figured.reset-counters.with()
  show figure: i-figured.show-figure.with()
  show math.equation: i-figured.show-equation.with(only-labeled: true)
  set text(
    font: Songti,
    size: 12pt,
  )
  set par(    // 段落设置
    justify: false,
    leading: 1.04em,
    first-line-indent: (amount: 2em, all: true)
  )
  show heading: set block(above: 1em, below: 1em)     // 标题设置
  show link: it => {          // 链接
    set text(fill: blue.darken(20%))
    it
  }
  show: gentle-clues.with(    // gentle块
    headless: false, // never show any headers
    breakable: true, // default breaking behavior
    header-inset: 0.4em, // default header-inset
    content-inset: 1em, // default content-inset
    stroke-width: 2pt, // default left stroke-width
    border-radius: 2pt, // default border-radius
    border-width: 0.5pt, // default boarder-width
  )
  show: checklist.with(fill: luma(95%), stroke: blue, radius: .2em)   // 复选框

  // 代码段设置
  show: codly-init.with()
  codly(languages: codly-languages)
  show raw.where(lang: "pintora"): it => pintorita.render(it.text)

  body
}