# Interview protocol

The user of specflow expects to be consulted: specflow reads what they gave,
asks what it cannot settle, offers concrete choices, and only then completes
the document. The kit supplies the discipline behind this: every ambiguity is
recorded, contract-level ambiguity stops the work, and questions are batched
once per stage (`specflow/PLAYBOOK.md` section 7, rules 1 to 3). This file
describes how to run that round well.

## When to ask

- **After a first draft.** Draft the stage's document from the request, the
  attachments and the approved upstream documents, then collect what the draft
  could not decide. A draft makes the questions concrete ("the SRS assumes one
  currency; keep that?") and lets many small gaps be closed by safe,
  recorded assumptions instead of questions.
- **Before a draft, only when nothing can be drafted.** If the request holds
  too little to start (a name and no goal, users or scope), ask the few
  questions that make a first draft possible, then draft and continue as
  above.
- **Immediately, when a contract question blocks the stage.** Scope, API,
  schema, security and personal data are contract questions (rule 2); at
  stage 0 the routing questions come first (rule 3).

Small ambiguities do not become questions: choose the safest assumption, write
it in `Assumptions & Open Questions` with its reason and impact, and continue.

## Shape of a question

Each question is about one decision and carries:

- the decision in plain words, and why it matters for this document;
- two to four options that are real alternatives, each with a short
  consequence, the recommended option first and labelled as recommended with
  a one-line reason;
- a free answer, always allowed (the user may know something better).

Illustrative only, for an SRS of an ordering app:

```text
1. Khách có cần tài khoản để đặt hàng không? (quyết định phạm vi FR xác thực và dữ liệu cá nhân)
   a. Bắt buộc đăng nhập (đề xuất: brief nói khách xem lại đơn cũ, cần gắn đơn với người)
   b. Cho đặt hàng khách vãng lai, tài khoản tùy chọn
   c. Chỉ khách vãng lai, tra đơn bằng mã đơn và email
   Hoặc trả lời theo cách khác.
```

At most five questions go in one round, blocking and contract questions first,
the rest by risk (rule 3). What happens to the rest follows the same rule. At
stage 0, a contract question that does not block routing, including one beyond
the five, is recorded as `BLOCKING: Không` with "trả lời trước Gate 1" in its
reason or impact column; Prompt 1 later turns the unanswered ones into blocking
questions of the SRS. In later stages, a contract question you could not ask
stays in `Assumptions & Open Questions` as `BLOCKING`. A question that does
not touch the contract becomes the safest assumption, recorded.

## Asking in each runtime

Use the runtime's structured question tool when it has one, because the user
can then pick an option with one click and the answer comes back unambiguous:

- Claude Code: `AskUserQuestion`, up to four questions per call, each with
  two to four options; the tool adds the free-answer choice itself. Put a
  fifth question in a second call.
- Other runtimes: use their question or user-input tool when one is
  available in the current mode.
- No such tool: print the numbered questions and lettered options as in the
  example above, say that a short reply such as "1a, 2c, 3: <text>" is
  enough, and end the turn to wait.

Ask in the language the user writes in; keep identifiers (FR IDs, file names)
as they are.

## After the answers

- Put each decision where the template expects it (a scope line, an FR, an
  NFR target, a Routing Decision field) and note the source ("chủ dự án chọn
  ở vòng hỏi ngày …") where the template has a source or reason column.
- Close the answered items in `Assumptions & Open Questions`; keep what is
  still open, with `BLOCKING` where it blocks the gate.
- If an answer changes an approved upstream document, stop and follow change
  management in `specflow/PLAYBOOK.md` section 8 instead of editing it quietly.
- Then complete the document and self-check the exit gate, as SKILL.md step 5
  describes. A second question round in the same stage is fine when an answer
  opens a new contract question; say why it is needed.
