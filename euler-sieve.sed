#!/bin/sed -Enf

# The sieve of Euler (the part of github.com/Circiter/sieve-in-sed).

# Usage: echo <sieve_size> | ./euler-sieve.sed

# (c) Circiter (mailto:xcirciter@gmail.com).
# License: MIT.

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

# #_@:, -- are auxiliary markers (pointers).
:sieve
    # Find next prime.
    s/#(0*1)/\1#_/

    :scan_multiples
        # Copy the prefixes to the second and third row.
        s/^([^#]*)#([^_]*)_([^\n]*\n).*$/\1#\2_\3:\1\2\n,\1/

        # Find next composite to be "crossed out".
        s/^/@/
        :multiplication
            # Move the @ and : markers.
            s/@([^\n])/\1@/; s/:([^\n])/\1:/

            /:./s/@\n/\n/ # Ensure that the last cell in sieve can be excluded.
            /@.*:[^\n]/bmultiplication # Repeat if it's possible to move the pointers further.

            # Reinitialize the : pointer.
            s/://; s/^([^\n]*\n)/\1:/

            # Move the , marker.
            s/,([^\n])/\1,/

            /@.*:.*,./bmultiplication

        # Do not exclude founded composite number right now
        # but only mark it for deletion (write x instead of 0
        # at its position).
        s/@([^\n])[^\n]/\1x@/

        # Reinitialize the , pointer.
        s/,//; s/^([^\n]*\n[^\n]*\n)/\1,/

        # Select next multiple.
        s/@//
        s/_(0*[1x])/\1_/

        /_0*[1x]/bscan_multiples # Keep excluding a multiples of the current prime.

    s/_//; s/@// # Remove the @ and _ markers.
    s/x/0/g # Actually exclude all the marked digits.

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
