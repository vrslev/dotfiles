# Registers and examples

These are invented examples for applying the profile, not quotations or
evidence of the user's authorship. Use their decisions, not their exact wording.

## Peer chat

Facts: a new setting applies automatically; a manual cache reset is unnecessary.

> Привет! Достаточно поменять настройку — сервис сам её подхватит. Кэш чистить
> не нужно.

This answers the practical question before explaining the mechanism. Shared
context makes a detailed description of the configuration system unnecessary.

Facts: validation should be required for new experiments; existing stored
records can retain optional fields.

> Давай проверять эти поля при создании новых экспериментов? В старых записях
> оставим их опциональными.

The proposal names the action and its scope. It remains a proposal.

## Technical uncertainty

Facts: a local benchmark measured a small overhead; production behavior has not
been checked.

> На локальном бенчмарке накладные расходы небольшие. Пока не вижу причины
> усложнять код. Если на реальной нагрузке появится разница, вернёмся к этому.

The observation, judgment, and next step are separate. “Local” stays attached to
the evidence rather than disappearing during compression.

## Issue description

Facts: a failed export leaves a stuck status, retries are blocked, and the scope
is a reset action without deleting the existing export.

> После ошибки экспорт остаётся в статусе «В работе», поэтому его нельзя
> запустить повторно. Сейчас статус приходится сбрасывать вручную.
>
> Добавить сброс статуса в интерфейсе. Существующий экспорт при этом сохранять.

The reader gets the trigger, effect, current workaround, and desired change.
Add acceptance criteria if the destination requires them.

## Assessment for an outsider

Facts: the author owned the release workflow, added repeatable checks and status
reporting, and removed a dependency on one person. No numerical time saving is
available.

> Отвечаю за выпуск сервисов команды. Когда релизы стали делать все
> разработчики, добавил повторяемые проверки и понятные статусы. Теперь выпуск
> можно провести без помощи одного конкретного человека.

Responsibility comes first, the example substantiates it, and the effect
explains why it matters. Technical implementation details can live in the
supporting evidence. Do not invent a percentage improvement.

For a peer audience, the same mechanism can be more technical:

> Собрал релизный workflow с проверками и статусами в CI. Теперь разработчики
> могут сами провести релиз, без ручного сопровождения.

## Plain English

Facts: an option is selected automatically based on changed content; the update
has only been checked locally and is waiting for integration testing.

> The service now chooses the option based on what changed. I checked it
> locally; integration testing is still pending.

Keep the result and the evidence boundary. First person describes only the
supplied author's work.

## Editing decisions

| Starting wording | Better direction |
| --- | --- |
| “Была осуществлена оптимизация процесса” | Name who changed what and the useful effect. |
| “Обеспечил стратегическое повышение эффективности” | State the supported outcome in ordinary words. |
| A résumé paragraph full of internal component names | Explain the responsibility, problem, and impact to an outsider. |
| A one-line summary missing the trigger or constraint | Restore the clause needed to understand or act. |
| Several headings for a two-sentence reply | Use one connected paragraph. |
| The same example repeated for several competencies | Pick distinct evidence, or make the different contribution explicit. |
| A planned deployment rewritten as completed work | Preserve its actual status. |

The profile supports both compact explanations and detailed instructions.
Choose the amount of detail from the reader's task rather than enforcing a word
count or a fixed message template.
