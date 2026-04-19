# Agent Instructions for Odin-Tome

This document provides essential instructions for AI agents operating in the `odin-tome` repository. This repository implements "Tome," a simple text-based data interchange format, written in the [Odin programming language](https://odin-lang.org/). 

**Important Context:** This is an Odin package/library. It does not contain a `main` function. Therefore, the primary way to verify behavior and test changes is by utilizing the `odin test` commands described below.

---

## 1. Build, Test, and Lint Commands

### Testing
Odin features a built-in testing framework. The tests for this repository are located in the `tests/` directory.

- **Run all tests:**
  ```bash
  odin test tests -collection:odeps=./odeps
  ```
  *Note: Always run tests after making code changes to verify parser and tokenizer behavior.*

- **Run a single test:**
  To isolate and run a specific test by its procedure name (e.g., `test_parse_int`), pass the `ODIN_TEST_NAMES` definition:
  ```bash
  odin test tests -collection:odeps=./odeps -define:ODIN_TEST_NAMES="test_parse_int"
  ```
  *Note: Provide the exact procedure name as the argument. Multiple tests can be separated by commas.*

### Building and Checking
Since this is a package, use `odin check` to verify compilation without producing an executable.

- **Check for syntax/type errors (Fastest):**
  ```bash
  odin check src -collection:odeps=./odeps
  odin check tests -collection:odeps=./odeps
  ```

- **Format code:**
  Odin has a built-in code formatter. After writing or modifying code, ensure you format it:
  ```bash
  odin fmt src tests -w
  ```

### Custom Collections
This project utilizes custom Odin collections. Specifically, we have an `odeps` collection defined in `ols.json` that points to the `./odeps` directory.
When running commands like `odin check` or `odin test`, you must include `-collection:odeps=./odeps` if the codebase relies on those external dependencies, though `ols.json` primarily configures the language server.

---

## 2. Code Style and Architectural Guidelines

### Naming Conventions
- **Procedures and Variables**: Use `snake_case`. (e.g., `parse_object_members`, `advance_token`, `curr_token`).
- **Types, Structs, Unions**: Use `Pascal_Case_With_Underscores`. (e.g., `Parser`, `Tome_Error`, `Value`).
- **Enum Members / Constants**: Use `Pascal_Case_With_Underscores` or `PascalCase`. (e.g., `Invalid_Token`, `Expect_Comma`).
- **Packages**: Package names should be lowercase and generally one word (e.g., `package tome`).

### Formatting & Syntax
- **Indentation**: Use **tabs** for indentation and spaces for alignment. The `odin fmt` tool handles this natively. Do not use spaces for indentation.
- **Braces**: The opening brace `{` goes on the same line as the statement (`struct`, `proc`, `switch`, `if`).
- **Switch Statements**: Utilize `#partial switch` when handling enums if not all cases are explicitly managed. This suppresses compiler warnings regarding unhandled cases.
- **Implicit Returns**: Odin supports named return values (e.g., `proc(p: ^Parser) -> (result: Object)`). Ensure `return` statements are clean and correctly populate named returns.
- **Deferred Execution**: Use `defer` heavily for cleanup, closing files, or freeing memory to ensure it happens regardless of how the scope exits.

### Memory Management & Types
- **Allocators**: Never rely exclusively on a global allocator for structures that have variable lifespans. Procedures that perform allocations should accept a `mem.Allocator` as an argument, or use `context.allocator`.
- Use `context.temp_allocator` when allocating temporary data that will not persist beyond the current scope or request cycle. Remember to clear the temp allocator at appropriate boundaries.
- **Arrays**:
  - `[dynamic]Type` for resizable arrays.
  - Return slices `[]Type` when exposing internal dynamic arrays (e.g., `return parser.errors[:]`).
  - Fixed-size arrays: `[N]Type`.
- **Strings**: Odin strings are UTF-8 slice-like structures. Use the `core:strings` package for manipulation.
- **Pointers**: Pass by pointer `^Type` when modifying structs (e.g., `proc(p: ^Parser)`).

### Error Handling
- **No Panics**: Do not heavily rely on `panic` for parser errors or regular control flow. Panics should be reserved for truly unrecoverable programmer errors.
- **Accumulate Errors**: Accumulate errors in a dynamic array and return them to the caller alongside the parsed structure.
  ```odin
  // Example pattern from src/parser.odin:
  Parser :: struct {
      errors: [dynamic]Tome_Error,
      // ...
  }
  ```
- **Error Recovery**: Always ensure the parser gracefully advances tokens (`advance_token(p)`) even upon encountering an error to prevent infinite loops during error recovery.
- **Multiple Returns**: For operations that can fail gracefully, use multiple returns (e.g., `proc(...) -> (Value, bool)` or returning an `Error` enum as the second value).

### Imports and Packages
- Declare `package` at the very top of the file. All files in the same directory must share the same package name.
- Use multiple `import` lines for clarity. Do not group them in a block unless idiomatic.
- Scope core libraries under `core:` (e.g., `import "core:mem"`, `import "core:strconv"`).
- Scope custom collections explicitly. For example, imports from the `odeps` collection should be `import "odeps:package_name"`.

---

## 3. Tool Usage Constraints (For AI Agents)

- **File Modification**: Always use the project's relative `src/`, `tests/`, and `odeps/` directories.
- **Verification**: Once you modify `.odin` files, run `odin check src -collection:odeps=./odeps && odin test tests -collection:odeps=./odeps` via Bash before reporting completion to the user.
- **Context Limit**: Read only the necessary slices of files like `src/tokenizer.odin` or `src/parser.odin` to understand the state machine before generating logic.
- **No `main` Assumption**: Do not try to run `odin run .` or look for a `main` procedure unless the user explicitly asks for an example program. Always rely on `odin test`.
- **Code Generation**: Ensure generated Odin code strictly follows the `odin fmt` style. Never output unformatted code.

---

## 4. Environment and Additional Rules

- Always respect any project-specific settings in `.cursorrules` or `.github/copilot-instructions.md` if they are introduced in the future.
- Leverage the tools provided (e.g., `odin check`, `odin test`, `odin fmt`) as your primary safety net.
