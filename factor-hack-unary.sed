#!/bin/sed -Enf

# Usage: echo <unary_number> | ./factor-hack.sed

s/[^1]/1/g

s/^/>/ # This symbol marks a number we search the factorization for.
s/$/\n/

:factor
    # Try to represent current number as a*b, for a, b > 1.
    # FIXME: It is more efficient to use the t command, but it does not work.
    />(11+)\1+\n/ {
        s/>(11+)(\1+\n)/>\1\n\1\2/ # Find a.
        :divide s/>(1*)\n(_*)\1(1*\n)/>\1\n\2_\3/; tdivide # Find b.
        s/_/1/g
        # Current "factor" is composite; try to factor it [recursively].
        bfactor
    }

    # Current number either 1 or is prime.
    s/>(1*\n)/\1>/ # Select next number if any.

    />$/! bfactor

s/\n>//; p
