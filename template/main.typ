#import "@local/nure:0.2.0": config, parts, style, utils

#show: style.dstu

#config.setup(
  title: "Назва вашої роботи",
  work-type: "ПЗ",
  work-number: 1,
  authors: ((name: "Студент С. С.", edu-program: "ПЗПІ", group: "23-1", gender: "m", variant: 1),),
)

#parts.metadata()

#parts.report-title-page(
  subject: "Назва дисципліни",
  edu-program: "ПЗПІ",
  mentors: ((name: "Керівник К. К.", degree: "ст. викл. кафедри ПІ", gender: "m"),),
)

#parts.title-heading()
#v(-style.spacing)

== Мета роботи
Метою роботи є...

== Хід роботи
=== Завдання
1. Ознайомитись із...
2. Розробити...

=== Результати
Текст із результатами...

== Висновки
У ході виконання даної роботи було...

/*
#show: style.appendices
= Код програми
```c
```
*/
