# Premier

## Program Layout

All programs have two sections: code and data. The code section is the first line, or, if the first line is a number N, the next N lines. Then, everything after that is data. The program simulates loops by appending information to the data section. Control statements are simulated by prepending or appending new operations to the programs section.

The state of a Premier program consists of three primary entities:

 1. The code section
 2. The data section
 3. The stack

The stack is where data from the code and data sections is manipulated. In addition to these main entities, there are some secondary entities:

 1. The data pointer. This keeps track of the index of the current data member being iterated upon.
 2. The instruction pointer. This internally refers to the index of the current token being processed.

## Program tokenization

The code is split into four different categories, which match these regexes:

| Regex   | Description                               |
|---------|-------------------------------------------|
| `\d+`   | Pushes the matched number to the stack    |
| `'.`    | Pushes the character to the stack         |
| `` `.`` | Pushes the character code to the stack    |
| `.`     | Activates the match as an operator        |

## Specific Operations

The following is a table of all operations currently available to a Premier program. All arguments are consumed off the stack in reverse order. For example, an instruction needing arguments `Num: a, Num: b` would expect the stack to look like this:

```
[..., a, b]
```

| Instruction | Arguments        | Effect |
|-------------|------------------|--------|
| `;`         | --               | Waits for user to input a character |
| `_`         | `Num: n`         | Pushes `-n` |
| `_`         | `Str: s`         | Pushes `s.reverse` |
| `"`         | --               | Collects characters until next `"` into code and pushes them as a string |
| `[`, `]`    | --               | Same as `[`, but nested |
| `|`         | --               | Same as `"`, but instead treats each character as a function of the top member of the stack |
| `#`         | `Str: s`         | Sets the program to `s`; continues to next iteration (disables implicit output) |
| `$`         | `Str: s`         | Sets the data to `s` |
| `%`         | `Num: x, Num: y` | Pushes `x mod y` |
| `%`         | `Str: s, Any: a` | (Unintentional) Replaces first occurence of `%s` in `s` with `a` |
| `+`         | `Num: x, Num: y` | Pushes `x + y` |
| `+`         | `Str: s, Str: t` | Pushes the concatenation of `s` and `t` |
| `-`         | `Num: x, Num: y` | Pushes `x - y` |
| `*`         | `Num: x, Num: y` | Pushes `x * y` |
| `*`         | `Str: s, Num: n` | Pushes `s` repeated `n` times |
| `/`         | `Num: x, Num: y` | Pushes `x / y` |
| `=`         | `Any: a, Any: b` | Pushes the equality of `a` and `b` |
| `~`         | `Any: a, Any: b` | Pushes the inequality of `a` and `b` |
| `^`         | --               | Appends all members of the stack, attempting to convert each to a character, to the data |
| `@`         | --               | Pops a value off of the stack |
| `:`         | --               | Duplicates the top value of the stack |
| `\`         | --               | Swaps the top two values of the stack |
| `<`         | --               | Moves the data pointer to the left one |
| `>`         | --               | Moves the data pointer to the right one |
| `A`         | `Str: s`         | Appends `s` to the data |
| `B`         | (Unimplemented)  | |
| `C`         | --               | Clears all members off of the stack |
| `D`         | --               | Debugs the program's state |
| `E`         | (Unimplemented)  | |
| `F`         | (Unimplemented)  | |
| `G`         | --               | Appends a line of STDIN to the data section |
| `H`         | (Unimplemented)  | |
| `I`         | --               | Disables implicit output for the current step |
| `J`         | (Unimplemented)  | |
| `I`         | --               | Disables implicit output for the current step |
| `K`         | (Unimplemented)  | |
| `L`         | `Str: s, Num: n` | Pushes all but the first `n` characters of `s` |
| `M`         | (Unimplemented)  | |
| `N`         | --               | Pushes `"\n"` |
| `O`         | `Any: a`         | Prints `a` with trailing newline |
| `P`         | --               | Pushes the current program |
| `Q`         | --               | Pushes the data |
| `R`         | (Unimplemented)  | |
| `S`         | --               | Appends all of STDIN to the data |
| `T`         | `Str: s`         | Prepends `s` to the program |
| `U`         | --               | Push `10` |
| `V`         | --               | Push `100` |
| `W`         | --               | Push `1000` |
| `X`         | --               | Push `16` |
| `Y`         | --               | Push `64` |
| `Z`         | --               | Push `128` |
| `a`         | `Str: s`         | Appends `s` to the program |
| `b`         | `Num: x, Num: y` | Rotates top `x` members of the stack left `y` times; if `y` is negative, rotate right `-y` times |
| `c`         | `Num: n`         | Converts `n` to a character |
| `d`         | `Num: n`         | Duplicates top `n` members |
| `e`         | `Num: n`         | Exits with exit code `n`, or `-1` if stack is empty |
| `f`         | `Str: s, Num: n` | Pushes first `n` characters of `s` |
| `g`         | --               | Pushes a line of stdin to the stack |
| `h`         | (Unimplemented)  | |
| `i`         | --               | Push the data pointer |
| `j`         | (Unimplemented)  | |
| `k`         | (Unimplemented)  | |
| `l`         | `Str: s`         | Pushes the number of characters in `s` |
| `m`         | (Unimplemented)  | |
| `n`         | `Any: a`         | Prints `a` |
| `o`         | `Str: s`         | Pushes the character code of the first character of `s` |
| `p`         | `Any: a`         | Prints `a`, casting numbers to characters. |
| `q`         | (Unimplemented)  | |
| `r`         | (Unimplemented)  | |
| `s`         | `Str: s`         | Pushes the "next" string after `s` |
| `s`         | `Num: n`         | Pushes `n + 1` |
| `t`         | (Unimplemented)  | |
| `u`         | (Unimplemented)  | |
| `v`         | --               | Appends all members of the stack, attempting to convert each to a character, to the program |
| `w`         | (Unimplemented)  | |
| `x`         | (Unimplemented)  | |
| `y`         | (Unimplemented)  | |
| `z`         | (Unimplemented)  | |