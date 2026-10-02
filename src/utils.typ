/// Робить текст напівжирним.
///
/// - content (content): Текст.
#let bold(content) = text(weight: "bold")[#content]

/// Створює заголовок першого рівня без нумерації.
///
/// - title (content): Назва заголовка.
#let nheading(title) = heading(depth: 1, numbering: none, title)

/// Заповнює горизонтальний простір блоком з невидимих символів (HAIR SPACE).
///
/// Використовується для створення підкреслень потрібної довжини.
///
/// - width (length, fraction): Ширина блоку.
#let hfill(width) = box(width: width, repeat(" "))  // HAIR SPACE (U+200A)

/// Перетворює масив рядків у масив рядків з горизонтальним заповненням `hfill(1fr)`.
///
/// Використовується в аркушах завдань для створення багаторядкових підкреслених полів.
///
/// - content (array, content): Масив рядків.
#let filled-lines(content) = if type(content) == array {
  content.map(line => [#line #hfill(1fr)]).join(linebreak())
} else {
  content
}

/// Створює підкреслений блок з можливістю вирівнювання тексту всередині.
///
/// - align (alignment): Вирівнювання (за замовчуванням `center`).
/// - content (content): Текст всередині підкреслення.
#let uline(align: center, content) = underline[
  #if align != left { hfill(1fr) }
  #content
  #if align != right { hfill(1fr) }
]

/// Витягує ім'я файлу без розширення зі шляху.
///
/// - path (string): Шлях до файлу.
#let stem(path) = path.split("/").last().split(".").first()

/// Витягує назву батьківської директорії зі шляху.
///
/// - path (string): Шлях до файлу.
#let parent-dir(path) = path.split("/").at(-2, default: "")

/// Генерує мітку `label` на основі шляху до зображення.
///
/// Формат: "image.png" → `<image>`, "img/foo/bar.png" → `<foo_bar>`.
///
/// - path (string): Шлях до файлу.
#let img-label(path) = {
  let name = stem(path)
  let parent = parent-dir(path)

  // If parent exists and name doesn't start with parent name, combine them
  let base = if parent != "" and not name.starts-with(parent) {
    parent + "_" + name
  } else {
    name
  }

  label(base.replace(" ", "_"))
}

/// Форматує підпис до рисунку на основі інформації про джерело.
///
/// Якщо джерело `none`, додається "(рисунок виконано самостійно)".
/// Якщо джерело надано, додається "(за даними ...)".
///
/// - base-caption (content): Основний підпис.
/// - source (content, string, none): Джерело.
#let img-caption(base-caption, source) = {
  if source == none {
    base-caption + " (рисунок виконано самостійно)"
  } else if source == () or source == "" {
    base-caption
  } else {
    base-caption + " (за даними " + source + ")"
  }
}

/// Вставляє рисунок з автоматично згенерованою міткою та підписом.
///
/// Використання: `img("path/to/image.png", "Caption")(optional: "source")`
///
/// - path (string): Шлях до файлу зображення.
/// - caption (content): Підпис рисунку.
/// - ..sink (any): Додаткові аргументи для функції `image`.
#let img(path, caption, ..sink) = {
  let source = sink.pos().at(0, default: ())
  [ #figure(image(path, ..sink.named()), caption: utils.img-caption(caption, source)) #utils.img-label(path) ]
}
/// Повертає назву місяця українською мовою в родовому відмінку за його номером.
///
/// - month (integer): Номер місяця (1-12).
#let month-gen(month) = (
  "січня",
  "лютого",
  "березня",
  "квітня",
  "травня",
  "червня",
  "липня",
  "серпня",
  "вересня",
  "жовтня",
  "листопада",
  "грудня",
).at(month - 1)

/// Перевіряє, чи починається рядок з кириличної літери.
///
/// - c (string): Рядок для перевірки.
#let is-cyr(c) = regex("^\p{Cyrillic}") in c

/// Безпечна перевірка на порожнечу (працює для `none`, `""` та `[]`).
///
/// - val (any): Значення для перевірки.
#let is-empty(val) = {
  if val == none { return true }
  if type(val) == str { val.len() == 0 } else if type(val) == array { val == [] } else { false }
}
