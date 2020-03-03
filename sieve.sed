#!/bin/sed -Enf

# The sieve of Eratosthenes (github.com/Circiter/sieve-in-sed).

# (c) Circiter (mailto:xcirciter@gmail.com).
# License: MIT.

# Usage: echo <unary_size> | ./sieve.sed, where <unary_size> is any
# string such that strlen(<unary_size>) is the size of a sieve.

### Part I, Sieving ###

# Transform a given string to the format #01*\n.
s/./1/g; s/^./0/; s/^/#/; s/$/\n/

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
x; s/^/0/; x
:print
    # Increment the content of the hold buffer.
    x
    # Replace all leading 9s by _.
    :replace s/9(_*)$/_\1/; treplace

    # If there are no digits left, append 0.
    s/^(_*)$/0\1/

    s/^/0123456789@/ # Add a lookup table.

    :increment
        s/^(.*)@(.*)$/\1@\2\n\1/ # Backup the lookup table.

        # Increment last digit only.
        s/^.*(.)(.)@(.*)\1(_*\n)/\3\2\4/

        # Restore and update the lookup table.
        s/^.*@//; s/^(.*)\n(.*)$/\2@\1/; s/.@/@/
        /^.*..@/bincrement # Repeat until the lookup table is empty.

    s/^.*@// # There is no need in the lookup table anymore.

    # Replace all _ to 0s.
    s/_/0/g
    x

    /^1/{x; p; x} # Print next prime.
    s/^.//
    /./bprint
