# sieve-in-sed
An attempt to implement the sieve of Eratosthenes in sed.

See the files `*.sed` (mainly `sieve.sed`) for details.

List of files:
- `sieve.sed` -- generates primes upto a given number;
- `plain-sieve.sed` -- generates a binary string in which 0s and 1s indicate
  composites and primes, respectively;
- `binary-sieve.sed` -- equivalent to the `sieve.sed` but works in base-2
  instead of base-10;
- `factor.sed` -- factorization of a given number;
- `anagram.sed` -- detects anagrams, i.e. determines if a two given strings
  are permutations of each other; the present script does it in somewhat unusual
  way (using the fundamental theorem of arithmetic).
- `collatz.sed` -- the well-known 3x-1 dynamical system from the Collatz conjecture.