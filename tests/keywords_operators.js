// keywords vs identifiers
let x = null;
const flag = true || false;
var variable = 1, letter = 2, constant = 3;   // start with keywords but are identifiers
if (x) { return; } else { break; }
for (let i = 0; i < 10; i++) { continue; }
while (typeof x === "undefined") do { } while (false);
async function f() { await g(); yield* h(); }
class A extends B { static #count = 0; #secret; constructor() { super(); this.#secret = 1; } }
try { throw new Error("x"); } catch (e) { } finally { }
switch (x) { case 1: default: }
import { a as b } from "mod";
export default delete obj.p, void 0, x instanceof A, "k" in obj;

// unicode / $ / _ identifiers
var $el = 1, _private = 2, café = 3, متغير = 4, \u0061bc = 5;

// operators, longest match should win every time
a = b + c - d * e / f % g ** h;
a += 1; a -= 1; a *= 1; a /= 1; a %= 1; a **= 2;
a <<= 1; a >>= 1; a >>>= 1; a &= 1; a |= 1; a ^= 1;
a &&= b; a ||= c; a ??= d;
a == b; a != b; a === b; a !== b; a < b; a > b; a <= b; a >= b;
a << b; a >> b; a >>> b; a & b; a | b; a ^ b; ~a; !a;
a && b || c ?? d;
a++; --b;
let fn = (p, ...rest) => p?.q?.[0]?.(1);
let t = ok ? .5 : 1;
let u = ok?.5:1;          // ? then .5, NOT ?.
