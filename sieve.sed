#!/bin/sed -Enf

# The sieve of Eratosthenes (github.com/Circiter/sieve-in-sed).

# (c) Circiter (mailto:xcirciter@gmail.com).
# License: MIT.

# Usage: echo <sieve_size> | ./sieve.sed

# Convert a given number from decimal to unary notation.

:decrement
    :replace_zero s/0(_*)$/_\1/; treplace_zero

    s/^/9876543210,/ # Append the lookup table.
    :decrement_digit
        s/(.)(.)(,.*)\1(_*)$/\1\3\2\4/
        tmatched
        s/.,/,/
        :matched
        /..,/bdecrement_digit
    s/^.*,//
    s/_/9/g
    s/^0(.)/\1/
    x; s/^1*$/&1/; x # Increment the unary counter in the hold space.
    /^0$/!bdecrement
g # Now to the base-10 number is converted to the base-1.

### Part I, Sieving ###

# Transform the base-1 number to the format #01*\n.
s/^./0/; s/^/#/; s/$/\n/

# @, :, # -- are auxiliary markers (pointers).
:sieve
    # Find next prime.
    s/#(0*1)/\1#@/
    # Copy the prefix to the second row.
    s/^(.*)@(.*\n).*$/\1@\2:\1/
    # Remove illegal symbols from the second row.
    :clear s/(\n.*)([^01:])(.*)$/\1\3/; tclear

    :exclude
        # Find next composite to be excluded.
        :composite
            # Move the @ and : markers.
            s/@([^\n])/\1@/; s/:(.)/\1:/
            /:./s/@\n/\n/ # Ensure that the last cell in sieve can be excluded.
            /@.*:./bcomposite # Repeat if it's possible to move the pointers further.

        # Exclude the composite number founded.
        s/.@/0@/

        # Reinitialize the : pointer.
        s/://; s/\n/\n:/

        # FIXME: /@./ or /@[^\n]/?
        /@./bexclude # Keep excluding a multiples of the current prime.

    # Remove the @ marker.
    s/@//

    # Keep sieving while there are any primes to the right of #.
    /#0*1/bsieve

s/\n.*$//; s/#// # Leave only the complete sieve.

### Part II, Printing ###

# Print prime numbers from the sieve.
# Based on the incrementation algorithm by Bruno
# (Haible@ma2s2.mathematik.uni-karlsruhe.de)
# but extended by a lookup table.
x; s/^.*$/0/; x
:print
    # Increment the content of the hold buffer.
    x
    # Replace all leading 9s by _.
    :replace s/9(_*)$/_\1/; treplace

    # If there are no digits left, append 0.
    s/^(_*)$/0\1/

    s/^/0123456789@/ # Add a lookup table.
    :increment
        # Increment last digit only.
        s/(.)(.)(@.*)\1(_*)$/\1\3\2\4/
        tok
        s/.@/@/
        :ok
        /..@/bincrement # Repeat until the lookup table is empty.

    s/^.*@// # There is no need in the lookup table anymore.

    # Replace all _ to 0s.
    s/_/0/g
    x

    /^1/{x; p; x} # Print next prime.
    s/^.//
    /./bprint
