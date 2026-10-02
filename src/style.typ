#import "utils.typ": bold

/// Базовий міжрядковий інтервал (0.95em).
#let spacing = 0.95em

/// Стандартний відступ абзацу за ДСТУ (1.25cm).
#let indent-size = 1.25cm

/// Подвійний інтервал.
#let double-spacing = spacing * 2

/// Два з половиною інтервали.
#let double-half-spacing = spacing * 2.5

/// Українська абетка для нумерації за ДСТУ 3008:2015.
#let ukr-enum = "абвгдежиклмнпрстуфхцшщюя".clusters()

/// Лічильник для таблиць за ДСТУ.
#let dstu-table-counter = counter("dstu-table")

/// Стан додатка для розв'язання нумерації таблиць за ДСТУ.
#let dstu-table-appendix = state("dstu-table-appendix", none)

/// Відступ для підписів таблиць.
#let dstu-table-caption-gap = 0.65em

/// Допоміжна функція для формування заголовків 2-го та 3-го рівнів.
///
/// - it (content): Елемент заголовка.
/// - num (string, auto): Формат нумерації.
#let heading-block(it, num: auto) = {
  v(double-spacing, weak: true)
  block(width: 100%, spacing: 0em)[
    #h(indent-size)
    #counter(heading).display(num)
    #it.body
  ]
  v(double-spacing, weak: true)
}

#let _col-count(columns) = {
  if type(columns) == int {
    columns
  } else if type(columns) == array {
    columns.len()
  } else {
    panic("dstu-table: columns must be an int or array, e.g. 2 or (1fr, 3fr)")
  }
}

#let _required(name, value) = {
  if value == none {
    panic("dstu-table: " + name + " is required")
  }
  value
}

/// Форматує підпис таблиці згідно з вимогами ДСТУ.
///
/// - it (content): Текст підпису.
#let dstu-table-label(it) = {
  set par(first-line-indent: 0pt)
  align(left)[#it]
}

/// Генерує таблицю з підтримкою розриву сторінок та правильним маркуванням
/// (наприклад, "Продовження таблиці...") за ДСТУ.
///
/// - caption (content): Назва таблиці.
/// - columns (array, integer): Кількість або розміри колонок.
/// - header (array): Масив комірок заголовка (наприклад, `([Колонка 1], [Колонка 2])`).
/// - tag (label): Мітка для створення посилання на таблицю (наприклад, `<my-table>`).
/// - ..args (any): Аргументи, що передаються у стандартну функцію `table`.
#let dstu-table(
  caption: none,
  columns: none,
  header: none,
  tag: none,
  ..args,
) = {
  let caption = _required("caption", caption)
  let columns = _required("columns", columns)
  let header = _required("header", header)

  if type(header) != array {
    panic("dstu-table: header must be an array, e.g. ([A], [B])")
  }

  dstu-table-counter.step()

  let named = args.named()
  let body = args.pos()
  context {
    let h = counter(heading).get()
    let section = if h.len() > 0 { h.at(0) } else { 0 }
    let n = dstu-table-counter.get().first()
    let appendix = dstu-table-appendix.get()
    let num = if appendix == none {
      numbering("1.1", section, n)
    } else {
      upper(ukr-enum.at(appendix - 1)) + "." + str(n)
    }

    let id = "dstu-table-" + str(section) + "-" + str(n)
    let start-marker = "start-" + id
    let end-marker = "end-" + id
    let cols = _col-count(columns)

    v(double-spacing, weak: true)

    {
      set block(spacing: dstu-table-caption-gap)

      [#metadata((kind: "dstu-table", number: num)) #if tag != none { label(tag) }]

      block(sticky: true)[
        #dstu-table-label[Таблиця #num -- #caption]
      ]

      table(
        columns: columns,
        ..named,

        table.header(
          repeat: true,

          table.cell(
            colspan: cols,
            stroke: none,
            inset: 0pt,
          )[
            #metadata(start-marker)

            #context {
              let starts = query(metadata.where(value: start-marker))
              let ends = query(metadata.where(value: end-marker))

              if starts.len() > 0 and ends.len() > 0 {
                let start-page = starts.first().location().page()
                let end-page = ends.first().location().page()
                let current-page = here().page()

                if current-page != start-page {
                  let label = if current-page == end-page {
                    [Кінець таблиці #num]
                  } else {
                    [Продовження таблиці #num]
                  }

                  pad(top: dstu-table-caption-gap, bottom: dstu-table-caption-gap)[
                    #dstu-table-label[#label]
                  ]
                }
              }
            }
          ],

          ..header,
        ),

        ..body,
      )
    }

    metadata(end-marker)

    v(double-spacing, weak: true)
  }
}

/// Застосовує загальні правила оформлення документа за ДСТУ 3008:2015.
///
/// Використовується як show rule: `#show: style.dstu`
///
/// - it (content): Основний вміст документа.
/// - skip (integer): Кількість перших заголовків 1-го рівня, що не нумеруються (наприклад, Вступ).
/// - offset (integer): Зсув нумерації заголовків.
#let dstu(
  it,
  skip: 0,
  offset: 0,
) = {
  // Page setup
  set page(
    paper: "a4",
    number-align: top + right,
    margin: (top: 20mm, right: 10mm, bottom: 20mm, left: 25mm),
    numbering: (i, ..) => if i > skip { numbering("1", i + offset) },
  )

  // Text and paragraph
  set text(lang: "uk", size: 14pt, hyphenate: false, font: ("Times New Roman", "Liberation Serif"))
  set par(justify: true, spacing: spacing, leading: spacing, first-line-indent: (
    amount: indent-size,
    all: true,
  ))
  set block(spacing: spacing)
  set underline(evade: false)

  // Lists
  set enum(indent: indent-size, body-indent: 0.5cm, numbering: i => ukr-enum.at(i - 1) + ")")
  show enum: it => {
    set enum(indent: 0em, numbering: "1)")
    it
  }
  set list(indent: indent-size + 0.1cm, body-indent: 0.5cm, marker: [--])

  // Figures
  show ref: it => {
    let target = it.element

    if target == none {
      return it
    }

    // dstu-table refs carry a number already resolved at the table location.
    if (
      target.func() == metadata
        and type(target.value) == dictionary
        and target.value.at("kind", default: none) == "dstu-table"
    ) {
      return link(target.location())[#target.value.at("number")]
    }

    if target.func() != figure and target.func() != math.equation {
      return it
    }

    // A figure or equation number must be read at the element itself, not at the citation site.
    // The default ref display re-runs the numbering function here, where its inner `counter(heading)`
    // context resolves to the citing chapter and prints the wrong section or appendix letter.
    // We sample every counter at the target location instead.
    let loc = target.location()

    let appendix = dstu-table-appendix.at(loc)

    let section = if appendix == none {
      str(counter(heading).at(loc).first())
    } else {
      upper(ukr-enum.at(appendix - 1))
    }

    let number = if target.func() == figure {
      let idx = counter(figure.where(kind: target.kind)).at(loc).first()
      section + "." + str(idx)
    } else {
      let idx = counter(math.equation).at(loc).first()
      "(" + section + "." + str(idx) + ")"
    }

    let supplement = if it.supplement == auto {
      target.supplement
    } else {
      it.supplement
    }

    let body = if supplement != auto and supplement != none {
      [#supplement #number]
    } else {
      [#number]
    }

    link(loc, body)
  }

  show figure: it => {
    v(double-spacing, weak: true)
    it
    v(double-spacing, weak: true)
  }
  set figure.caption(separator: [ -- ])
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption.where(kind: table): set align(left)
  show figure.where(kind: raw): set figure.caption(position: top)
  show figure.where(kind: raw): set align(left)

  // Numbering reset on level 1 headings
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    dstu-table-counter.update(0)
    it
  }
  set figure(numbering: i => context numbering("1.1", counter(heading).get().at(0), i))
  set math.equation(numbering: i => context numbering("(1.1)", counter(heading).get().at(0), i))

  // Headings
  set heading(numbering: "1.1")
  show heading: it => {
    set text(size: 14pt)
    if it.level == 1 {
      set align(center)
      set text(weight: "semibold")
      pagebreak(weak: true)
      upper(it)
      v(double-spacing, weak: true)
    } else {
      set text(weight: "regular")
      heading-block(it, num: if it.level == 3 { it.numbering } else { auto })
    }
  }

  // Code listings
  show raw.where(block: true): it => {
    let code-spacing = 0.5em
    set block(spacing: code-spacing)
    set par(spacing: code-spacing, leading: code-spacing)
    set text(size: 11pt, weight: "semibold", font: ("Courier New", "Liberation Mono"))
    v(double-half-spacing, weak: true)
    pad(it, left: indent-size)
    v(double-half-spacing, weak: true)
  }

  // blocks `like this` aren't welcome, so ` is replaced with "
  show raw.where(block: false): it => text(
    lang: "uk",
    size: 14pt,
    hyphenate: false,
    weight: "regular",
    font: ("Times New Roman", "Liberation Serif"),
  )["#it.text"]

  it
}

/// Застосовує правила оформлення додатків за ДСТУ 3008:2015.
///
/// Змінює нумерацію заголовків, рисунків, таблиць та формул на літерну (А, Б, В...).
/// Використовується як show rule: `#show: style.appendices`
///
/// - it (content): Вміст додатків.
#let appendices(it) = {
  counter(heading).update(0)

  set heading(numbering: (i, ..n) => upper(ukr-enum.at(i - 1)) + numbering(".1.1", ..n))
  set heading(supplement: [Додаток])

  let app-letter = context upper(ukr-enum.at(counter(heading).get().at(0) - 1))
  set figure(numbering: i => app-letter + "." + str(i))
  set math.equation(numbering: i => [(#app-letter.#str(i))])

  show heading: h => {
    set text(size: 14pt)
    if h.level == 1 {
      counter(math.equation).update(0)
      counter(figure.where(kind: raw)).update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      dstu-table-counter.update(0)
      dstu-table-appendix.update(counter(heading).get().at(0))

      set align(center)
      set text(weight: "regular")
      pagebreak(weak: true)
      [ДОДАТОК #counter(heading).display(auto)]
      linebreak()
      h.body
      v(double-spacing, weak: true)
    } else {
      set text(weight: "regular")
      heading-block(h)
    }
  }

  it
}
