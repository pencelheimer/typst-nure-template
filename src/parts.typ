#import "config.typ": nure-state, edu-programs, subjects
#import "style.typ": spacing
#import "utils.typ": *

/// Внутрішня функція для отримання глобального стану конфігурації.
#let get-state() = {
  let c = nure-state.get()
  if c.keys().len() == 0 { panic("Config is empty. Please call #config.setup(...) before building blocks.") }
  c
}

#let note(content) = block(width: 100%, above: 5pt, below: 0pt)[
  #set text(size: 10pt)
  #set par(first-line-indent: 0pt, spacing: 0pt)
  #align(center)[#content]
]

#let form-field(alignment: center, content) = box(
  width: 100%,
  stroke: (bottom: 0.5pt),
  inset: (bottom: 1.5pt),
)[
  #align(alignment)[#content]
]

#let label-line(label, value, caption: none, label-width: auto) = {
  set par(first-line-indent: 0pt)
  if label-width == auto {
    [#label #form-field(alignment: center, value)]
  } else {
    grid(
      columns: (label-width, 1fr),
      gutter: 0pt,
      align: horizon,
      label, form-field(alignment: center, value),
    )
  }
  if caption != none {
    note(caption)
  }
}

#let inline-field(value) = form-field(alignment: center, value)

#let inline-label-line(label, value) = {
  set par(first-line-indent: 0pt)
  block(width: 100%, below: 0pt)[
    #label #uline(align: center, value)
  ]
}

#let task-head-fields(fields) = {
  set par(first-line-indent: 0pt)
  let cells = ()
  for (label, value) in fields {
    if type(value) == array {
      for (i, line) in value.enumerate() {
        cells.push(if i == 0 { label } else { [] })
        cells.push(inline-field(line))
      }
    } else {
      cells.push(label)
      cells.push(inline-field(value))
    }
  }
  grid(
    columns: (auto, 1fr),
    gutter: 0pt,
    row-gutter: 0.65em,
    align: top,
    ..cells,
  )
}

#let task-num(n) = box(str(n) + ".")

#let title-field(value) = {
  uline(align: center, if type(value) == array { value.join() } else { value })
  uline(align: center, [])
  note[(тема)]
}

#let commission-lines(members) = {
  if members != none and members.len() > 0 {
    for (i, member) in members.enumerate() {
      if i > 0 {
        linebreak()
      }
      let member-display-name = member.at("display-name", default: member.name)
      let member-degree = member.at("degree", default: "")
      uline(align: left, [#member-degree #member-display-name])
    }
  } else {
    v(0.55em)
    line(length: 100%, stroke: 0.5pt)
    v(0.55em)
    line(length: 100%, stroke: 0.5pt)
    v(0.55em)
    line(length: 100%, stroke: 0.5pt)
  }
}

/// Генерує титульний аркуш для стандартних звітів.
///
/// - work-type (string): Тип роботи ("ПЗ", "ЛБ", "КР", "РФ", "ІДЗ" або будь-який текст без скорочення).
/// - work-number (integer): Номер роботи.
/// - edu-program (string): Код освітньої програми (наприклад, "ПЗПІ") або повна назва.
/// - subject (string): Коротка або повна назва дисципліни.
/// - title (string): Назва роботи.
/// - authors (array): Список авторів.
/// - mentors (array): Список керівників.
/// - year (string): Рік виконання.
#let report-title-page(
  work-type: auto,
  work-number: auto,
  edu-program: auto,
  subject: auto,
  title: auto,
  authors: auto,
  mentors: auto,
  year: auto,
) = context {
  let c = get-state()

  let _wt = if work-type != auto { work-type } else { c.work-type }
  let _wn = if work-number != auto { work-number } else { c.work-number }
  let _auth = if authors != auto { authors } else { c.authors }
  let _ep_raw = if edu-program != auto { edu-program } else { c.edu-program }
  let _ep = if _ep_raw != none { _ep_raw } else if _auth != none and _auth.len() > 0 { _auth.first().at("edu-program", default: none) } else { none }
  let _subj = if subject != auto { subject } else { c.subject }
  let _title = if title != auto { title } else { c.title }
  let _ment = if mentors != auto { mentors } else { c.mentors }
  let _yr = if year != auto { year } else { c.year }

  let authors-verb = "Виконали"
  if _auth != none and _auth.len() == 1 {
    let g = _auth.first().at("gender", default: "p")
    if g == "m" { authors-verb = "Виконав" }
    if g == "f" { authors-verb = "Виконала" }
  }

  let mentors-verb = "Перевірили"
  if _ment != none and _ment.len() == 1 {
    let g = _ment.first().at("gender", default: "p")
    if g == "m" { mentors-verb = "Перевірив" }
    if g == "f" { mentors-verb = "Перевірила" }
  }

  let mapped-mentors = if _ment != none {
    _ment.map(m => {
      let d = m.at("degree", default: none)
      (..m, degree-formatted: if d != none and d != "" { [#d\ ] })
    })
  } else { () }

  let doc-type-title = none
  if _wt != none {
    let t = (
      "ЛБ": [Звіт \ з лабораторної роботи],
      "ПЗ": [Звіт \ з практичної роботи],
      "КР": [Контрольна робота],
      "РФ": [Реферат],
      "ІДЗ": [Індивідуальне домашнє завдання],
    ).at(_wt, default: _wt)
    doc-type-title = if _wn != none and str(_wn) != "" [#t №#_wn] else [ #t ]
  }

  let fallback-ep = if _ep != none { _ep } else { "" }
  let edu-prog = if type(_ep) == dictionary { _ep } else { edu-programs.at(str(fallback-ep), default: (department-gen: fallback-ep, code: fallback-ep, name-long: fallback-ep)) }
  let subject-str = subjects.at(if _subj != none { _subj } else { "" }, default: _subj)

  align(center)[
    #upper([Міністерство освіти і науки України\ Харківський національний університет радіоелектроніки])

    \ \
    Кафедра #edu-prog.department-gen

    \ \ \
    #doc-type-title

    з дисципліни: "#subject-str"
    #if _title != none [\ з теми: "#eval(_title, mode: "markup")"]

    \ \ \ \
    #columns(2)[
      #set align(left)
      #set par(first-line-indent: 0pt)

      #if _auth != none and _auth.len() == 1 {
        let a = _auth.first()
        [#authors-verb:\ ]
        if ("edu-program" in a) and ("group" in a) [ст. гр. #a.edu-program\-#a.group\ ]
        [#a.name\ ]
        if ("variant" in a) and (a.variant != none) [Варіант: №#a.variant]
      } else if _auth != none and _auth.len() > 1 [
        #authors-verb:\
        #for a in _auth [
          #if ("edu-program" in a) and ("group" in a) [ ст. гр. #a.edu-program\-#a.group\ ]
          #a.name\
        ]
      ]

      #colbreak()
      #set align(right)

      #if mapped-mentors.len() == 1 {
        let m = mapped-mentors.first()
        [#mentors-verb:\ ]
        m.degree-formatted
        [#m.name\ ]
      } else if mapped-mentors.len() > 1 [
        #mentors-verb:\
        #for m in mapped-mentors {
          m.degree-formatted
          [#m.name\ ]
        }
      ]
    ]

    #v(1fr)

    Харків -- #_yr
  ]
}

/// Генерує титульний аркуш для курсової роботи.
///
/// - edu-program (string): Код освітньої програми (наприклад, "ПЗПІ").
/// - title (string): Назва роботи.
/// - authors (array): Список авторів.
/// - mentors (array): Список керівників.
/// - year (string): Рік виконання.
/// - committee-members (array): Список членів комісії.
/// - program-name (string): Повна назва програми.
/// - faculty (string): Назва факультету.
/// - education-level (string): Рівень вищої освіти.
/// - program-type (string): Тип програми.
#let coursework-title-page(
  edu-program: auto,
  title: auto,
  authors: auto,
  mentors: auto,
  year: auto,
  committee-members: auto,
  program-name: auto,
  faculty: auto,
  education-level: auto,
  program-type: auto,
) = context {
  let c = get-state()

  let _auth = if authors != auto { authors } else { c.authors }
  let _ep_raw = if edu-program != auto { edu-program } else { c.edu-program }
  let _ep = if _ep_raw != none { _ep_raw } else if _auth != none and _auth.len() > 0 { _auth.first().at("edu-program", default: none) } else { none }
  let _title = if title != auto { title } else { c.title }
  let _ment = if mentors != auto { mentors } else { c.mentors }
  let _yr = if year != auto { year } else { c.year }
  let _cm = if committee-members != auto { committee-members } else { c.committee-members }
  let _pn = if program-name != auto { program-name } else { c.program-name }
  let _fac = if faculty != auto { faculty } else { c.faculty }
  let _el = if education-level != auto { education-level } else { c.education-level }
  let _pt = if program-type != auto { program-type } else { c.program-type }

  let author = _auth.first()
  let head-mentor = _ment.first()
  let commission-members = if _cm == none {
    _ment.slice(1)
  } else {
    _cm
  }

  let _auth_ep = author.at("edu-program", default: _ep)
  let fallback-ep = if _auth_ep != none { _auth_ep } else { "" }
  let edu-prog = if type(_auth_ep) == dictionary { _auth_ep } else { edu-programs.at(str(fallback-ep), default: (department-gen: fallback-ep, code: fallback-ep, name-long: fallback-ep)) }
  let p-name = if _pn == none {
    edu-prog.at("program-name", default: edu-prog.name-long)
  } else {
    _pn
  }
  let group-name = if str(author.group).starts-with(author.at("edu-program", default: _ep)) {
    str(author.group)
  } else {
    author.at("edu-program", default: _ep) + "-" + str(author.group)
  }
  let executor-label = if author.at("gender", default: "p") == "f" {
    "Виконала:"
  } else {
    "Виконав:"
  }
  let author-display-name = author.at("display-name", default: author.name)
  let mentor-display-name = head-mentor.at("display-name", default: head-mentor.name)
  let mentor-degree = head-mentor.at("degree", default: "")

  [
    #set par(first-line-indent: 0pt, justify: false, leading: 0.45em)
    #set text(size: 14pt)
    #set align(center)
    МІНІСТЕРСТВО ОСВІТИ І НАУКИ УКРАЇНИ\
    [Харківський національний університет радіоелектроніки]

    #v(0.7em)

    #set align(left)
    #inline-label-line(
      [Факультет],
      _fac,
    )
    #note([(повна назва)])

    #v(0.8em)
    #inline-label-line(
      [Кафедра],
      lower(edu-prog.department-gen),
    )
    #note([(повна назва)])

    #v(1.8em)

    #set align(center)
    #text(size: 20pt, weight: "bold")[КОМПЛЕКСНИЙ КУРСОВИЙ ПРОЄКТ]\
    #text(size: 20pt, weight: "bold")[Пояснювальна записка]

    #v(0.9em)

    #set align(left)
    #label-line([рівень вищої освіти], _el, label-width: 120pt)

    #v(1.0em)
    #title-field(_title)

    #v(3em)

    #grid(
      columns: (0.36fr, 0.64fr),
      [],
      [
        #executor-label\
        здобувач #underline([#author.course]) курсу, групи #underline(group-name)\
        #uline(align: center, author-display-name)
        #note[(Власне ім'я, ПРІЗВИЩЕ)]

        #v(0.2em)
        #inline-label-line([Спеціальність], [#edu-prog.code -- #edu-prog.name-long])
        #note[(код і повна назва спеціальності)]
        #inline-label-line([Тип програми], _pt)
        #inline-label-line([Освітня програма], p-name)
        #note[(повна назва освітньої програми)]

        #v(0.3em)
        #inline-label-line([Керівник], [#mentor-degree #mentor-display-name])
        #note[(посада, Власне ім'я, ПРІЗВИЩЕ)]

        #v(0.3em)
        #pad(left: 75pt)[
          #set par(first-line-indent: 0pt)
          Члени комісії (#text(size: 10pt)[Власне ім'я, ПРІЗВИЩЕ, підпис])
          #v(0.15em)
          #commission-lines(commission-members)
        ]
      ],
    )

    #v(1fr)

    #set align(center)
    #_yr р.

    #pagebreak()
  ]
}

/// Генерує заголовок роботи на початку основного тексту документа.
///
/// - title (string): Назва роботи.
/// - work-number (integer): Номер роботи.
#let title-heading(
  title: auto,
  work-number: auto,
) = context {
  let c = get-state()

  let _t = if title != auto { title } else { c.title }
  let _num = if work-number != auto { work-number } else { c.work-number }

  pagebreak(weak: true)

  if _t == none {
    if _num == none { counter(heading).update(1) } else {
      counter(heading).update(_num)
    }
  } else {
    if _num != none {
      counter(heading).update(_num - 1)
    }
    heading(eval(_t, mode: "markup"))
  }
}

/// Генерує аркуш із завданням (Завдання на курсовий проєкт/роботу) для курсової роботи.
///
/// - source (content): Вихідні дані до проєкту.
/// - content (content): Перелік питань, що потрібно опрацювати в роботі.
/// - done-date (datetime): Термін здачі студентом закінченої роботи.
/// - initial-date (datetime): Дата видачі завдання.
/// - title (string): Тема роботи.
/// - faculty (string): Назва факультету.
/// - education-level (string): Рівень вищої освіти.
/// - program-type (string): Тип освітньої програми.
/// - program-name (string): Повна назва освітньої програми.
/// - edu-program (string): Код освітньої програми.
/// - authors (array): Список авторів.
#let task-list(
  source: [],
  content: [],
  done-date: datetime.today(),
  initial-date: datetime.today(),
  title: auto,
  faculty: auto,
  education-level: auto,
  program-type: auto,
  program-name: auto,
  edu-program: auto,
  authors: auto,
) = context {
  let c = get-state()

  let _title = if title != auto { title } else { c.title }
  let _fac = if faculty != auto { faculty } else { c.faculty }
  let _el = if education-level != auto { education-level } else { c.education-level }
  let _pt = if program-type != auto { program-type } else { c.program-type }
  let _pn = if program-name != auto { program-name } else { c.program-name }
  let _ep_raw = if edu-program != auto { edu-program } else { c.edu-program }
  let _auth = if authors != auto { authors } else { c.authors }

  let _ep = if _ep_raw != none { _ep_raw } else if _auth != none and _auth.len() > 0 { _auth.first().at("edu-program", default: none) } else { none }

  let author = _auth.first()
  let fallback-ep = if _ep != none { _ep } else { "" }
  let edu-prog = if type(_ep) == dictionary { _ep } else { edu-programs.at(str(fallback-ep), default: (department-gen: fallback-ep, code: fallback-ep, name-long: fallback-ep)) }
  let p-name = if _pn == none { edu-prog.at("program-name", default: edu-prog.name-long) } else { _pn }
  let group-name = if str(author.group).starts-with(author.at("edu-program", default: _ep)) { str(author.group) } else { author.at("edu-program", default: _ep) + "-" + str(author.group) }
  let author-full-name-dat = author.at("full-name-dat", default: author.at("full-name-gen", default: author.name))

  [
    #set par(first-line-indent: 0pt, justify: false)
    #align(center)[[Харківський національний університет радіоелектроніки]]

    #v(1.1em)
    #task-head-fields((
      (
        [Факультет],
        (
          _fac,
        ),
      ),
      ([Кафедра], lower(edu-prog.department-gen)),
      ([Рівень вищої освіти], _el),
      ([Спеціальність], [#edu-prog.code -- #edu-prog.name-long]),
      ([Тип програми], _pt),
      ([Освітня програма], p-name),
    ))
    #note[(шифр і назва)]

    #v(1.7em)
    #grid(
      columns: (1.1fr, 1.1fr, 1.1fr, 1.7fr, 1.3fr, 1.1fr),
      gutter: 0pt,
      align: center + horizon,
      [Курс], uline(author.course), [Група], uline(group-name), [Семестр], uline(author.semester),
    )

    #v(2.6em)

    #align(center)[
      #bold[ЗАВДАННЯ]\
      #text(style: "italic", weight: "bold")[на курсовий проєкт (роботу) студента]
    ]

    #v(1.0em)

    #label-line([здобувачеві], author-full-name-dat, caption: [(прізвище, ім'я, по батькові)], label-width: 95pt)

    #v(1.0em)

    #task-num(1) Тема роботи #uline(align: left, filled-lines(_title))

    #v(0.4em)
    #task-num(2) Термін здачі студентом закінченої роботи
    “#underline(done-date.display("[day]"))” #underline(month-gen(done-date.month())) #done-date.display("[year]")р.

    #v(0.4em)
    #task-num(3) Вихідні дані до проєкту #uline(align: left, filled-lines(source))
    #v(0.4em)
    #uline(align: left, [])

    #v(0.4em)
    #task-num(4) Перелік питань, що потрібно опрацювати в роботі\
    #uline(align: left, filled-lines(content))
    #v(0.4em)
    #uline(align: left, [])

    #pagebreak()
  ]
}

/// Генерує аркуш календарного плану для курсової роботи.
///
/// - initial-date (datetime): Дата видачі завдання.
/// - plan-table (content): Блок контенту з таблицею розкладу.
/// - mentors (array): Список керівників.
#let calendar-plan(
  initial-date: datetime.today(),
  plan-table: [],
  mentors: auto,
) = context {
  let c = get-state()

  let _mentors = if mentors != auto { mentors } else { c.mentors }
  let head-mentor = _mentors.first()
  let mentor-display-name = head-mentor.at("display-name", default: head-mentor.name)
  let mentor-degree = head-mentor.at("degree", default: "")

  [
    #align(center, bold[КАЛЕНДАРНИЙ ПЛАН])
    #set par(first-line-indent: 0pt)

    #v(1.4em)

    #plan-table

    #v(5.0em)

    Дата видачі завдання “#underline(initial-date.display("[day]"))” #underline(month-gen(initial-date.month())) #initial-date.display("[year]") р.

    #v(1.4em)

    Здобувач #underline([#hfill(6cm)])
    #note[(підпис) #h(8cm)]

    #v(1.4em)

    Керівник роботи #uline(align: center, []) #h(1cm) #underline[#mentor-degree #mentor-display-name]
    #note[(підпис) #h(4.5cm) (посада, Власне ім'я, ПРІЗВИЩЕ)]

    #pagebreak()
  ]
}

/// Генерує сторінку реферату (Реферат / Abstract).
///
/// Підтримує передачу контенту реферату через позиційні блоки:
/// `#parts.abstract(keywords: (...))[Український текст][Англійський текст]`
///
/// - keywords (dictionary, array): Ключові слова українською мовою. Якщо передано словник, ключі є українськими словами, а значення - англійськими перекладами.
/// - ..bodies (content): Позиційні аргументи з блоками тексту (перший — укр., другий — англ.).
#let abstract(
  keywords: (),
  ..bodies
) = context {
  let pos = bodies.pos()
  let body = pos.at(0, default: [])
  let en-text = pos.at(1, default: none)

  let header = if en-text != none {
    bold[РЕФЕРАТ / ABSTRACT]
  } else {
    bold[РЕФЕРАТ]
  }

  [
    #align(center, header) \

    #context [
      #let pages = counter(page).final().at(0)
      #let images = query(figure.where(kind: image)).len()
      #let dstu-tables = query(metadata).filter(it => type(it.value) == dictionary and it.value.at("kind", default: none) == "dstu-table").len()
      #let tables = query(figure.where(kind: table)).len() + dstu-tables
      #let bibs = state("citation-counter", ()).final().dedup().len()

      #let counters = ()
      #if pages != 0 { counters.push[#pages с.] }
      #if tables != 0 { counters.push[#tables табл.] }
      #if images != 0 { counters.push[#images рис.] }
      #if bibs != 0 { counters.push[#bibs джерел] }

      Пояснювальна записка містить: #counters.join(", ").
    ]

    \

    #let keyword-pairs = if type(keywords) == dictionary {
      keywords.pairs().map(((uk, en)) => (uk: uk, en: en))
    } else if keywords.len() > 0 and type(keywords.first()) == array {
      keywords.map(pair => (
        uk: pair.at(0),
        en: pair.at(1),
      ))
    } else {
      keywords.map(uk => (uk: uk))
    }

    #let sorted-keyword-pairs = keyword-pairs.sorted(by: (a, b) => {
      if is-cyr(a.uk) != is-cyr(b.uk) { is-cyr(a.uk) } else { a.uk < b.uk }
    })

    #(sorted-keyword-pairs.map(pair => upper(pair.uk)).join(", "))

    \

    #body

    #if en-text != none or (keyword-pairs.len() > 0 and keyword-pairs.first().at("en", default: none) != none and keyword-pairs.first().en != "") [
      \

      #(sorted-keyword-pairs.map(pair => upper(pair.en)).join(", "))

      \

      #en-text
    ]
  ]
}

/// Генерує автоматичний зміст документа.
#let table-of-contents() = {
  show outline.entry: it => {
    let el = it.element

    if el.func() == heading and el.supplement == [Додаток] {
      if el.level > 1 {
        none
      } else {
        block(width: 100%)[
          #link(el.location())[
            Додаток #it.prefix()#h(0.5em)#it.inner()
          ]
        ]
      }
    } else {
      it
    }
  }

  outline(
    title: [
      ЗМІСТ
      #v(spacing * 2, weak: true)
    ],
    depth: 2,
    indent: auto,
  )
}

/// Встановлює глобальні метадані PDF документа.
///
/// Отримує `title` та імена авторів з конфігурації та застосовує їх глобально
/// за допомогою `set document(...)`. Розміщуйте на самому початку документа.
///
/// - title (string): Назва роботи.
/// - authors (array): Список авторів.
#let metadata(
  title: auto,
  authors: auto,
) = context {
  let c = get-state()

  let _t = if title != auto { title } else { c.title }
  let _auth = if authors != auto { authors } else { c.authors }

  let authors-names = if _auth != none and _auth != () {
    _auth.map(a => a.name)
  } else {
    ()
  }

  set document(
    title: if _t != none { _t } else { "" },
    author: authors-names
  )
}
