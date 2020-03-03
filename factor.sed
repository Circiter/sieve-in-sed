#!/bin/sed -Enf

# Factoring numbers using the sieve of Eratosthenes.

# (c) Circiter (mailto:xcirciter@gmail.com)
# Repository: "github.com/Circiter/sieve-in-sed".

# Usage: echo <number> | ./sieve.sed.
# E.g., echo 770 | ./sieve.sed # N.B., 2*5*7*11=770.

# Convert a given number from decimal to unary notation.

:decrement
    # Decrement (adaptation of Bruno's incrementation
    # algorithm but with a lookup table).
    :replace s/0(_*)$/_\1/; treplace

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
    x; s/^x*$/&x/; x # Increment the unary counter in the hold space.
    /^0$/!bdecrement
g # Now the base-10 number is converted to the base-1.

# Sieving.

# Transform a given string to the format #01*\n.
s/./1/g; s/^./0/; s/^/#/; s/$/\n/

# @, :, # -- are auxiliary markers (pointers).
# The # is used to mark the current prime,
# the : is used to locate a next multiple of the prime,
# the @ is used to mark the found multiple of the prime.
:sieve
    # Find next prime.
    s/#(0*1)/\1#@/
    # Copy the prefix to the second row.
    s/^(.*)@(.*\n).*$/\1@\2:\1/
    # Remove illegal symbols from the second row.
    :clear s/(\n.*)([^01:])(.*)$/\1\3/; tclear

    x; s/^.*$/x/; x
    :exclude
        # Find next composite to be excluded.
        :composite
            # Move the @ and : markers to the right
            # synchronously one character at a time.
            s/@([^\n])/\1@/; s/:(.)/\1:/
            /:./s/@\n/\n/ # Ensure that the last cell in sieve can be excluded.
            /@.*:./bcomposite # Repeat if it's possible to move the pointers further.

        # Exclude the composite number founded.
        s/.@/0@/

        /:$/{x; s/^x*$/&x/; x} # Increment the counter in the hold space.

        # Reinitialize the : pointer.
        s/://; s/\n/\n:/

        /@[^\n]/bexclude # Keep excluding a multiples of the current prime.

    # Prime space: sieve\nprime_number.
    # The hold space now contains the result of dividing
    # the given number by the current prime.

    # If we are factoring a prime number then
    # due to the fact that the code above
    # prematurely removed the @ marker after
    # the last 1 in the sieve, we can not print
    # this "trivial" prime factor. So we need
    # a workaround here.

    /1#\n/s/#/@/ # Insert @ again.

    # If a prime factor found.
    /@/{ :prime_exponent
        H # Backup two first lines to the hold space.

        # TODO: Print in decimal.
        s/$/\n0/
        :print_decimal
            s/:([^\n])/\1:/

            # Increment the decimal number
            :digit s/9(_*)$/_\1/; tdigit
            s/\n(_*)$/\n0\1/

            s/\n([^\n]*)$/\n0123456789,\1/
            :increment_digit
                s/([^\n])([^\n])(,.*)\1(_*)$/\1\3\2\4/
                tok
                s/.,/,/
                :ok
                /[^\n][^\n],/bincrement_digit
            s/\n[^\n]*,/\n/

            s/_/0/g

            /:[^\n]/bprint_decimal
        s/://; s/^[^\n]*\n/&:/

        s/^.*\n([^\n]*)$/\1/ # Temporarily leave only the decimal number.
        p

        # Restore two first lines.
        G
        s/^.*\n([^\n]*\n[^\n]*)$/\1/
        x
        s/^(.*)\n[^\n]*\n[^\n]*$/\1/
        x

        # OK, it was easy; but to determine
        # the exponent of the prime factor is
        # much harder.

        # We need to keep dividing the content of the hold space
        # by the current prime.
        H # Copy the prime number to the hold space.
        x
        s/^([^\n]*\n)[^\n]*\n([^\n]*)$/\1\2/ # Remove the sieve from the hold space.
        s/^/@/ # We need some markers.
        # The logic below is the same as above in
        # the "composite" and "exclude" routines,
        # therefore it's possible to remove a code
        # duplication, but the code already somewhat
        # knotted so I prefer to repeat myself here.
        s/$/\n/ # Append counter.
        # Hold space: <number>\n<prime_number>\n<counter>
        :divide
            :multiple
                s/@([^\n])/\1@/; s/:(.)/\1:/ # Move the markers.
                /:[^\n]/s/@\n/\n/ # Treat the boundary properly.
                /@.*:[^\n]/bmultiple

                /@/s/\nx*$/&x/ # Increment the counter for each multiple.

                s/://; s/^[^\n]*\n/&:/
            /@[^\n]/bdivide

        /@/{
            # Hold space: <number>\n<prime_number>\n<number_divided_by_prime>.
            s/^.*\n([^\n]*)$/\1/ # Leave only number/prime_number.
            # Hold space: <number>
            x
            bprime_exponent
        }
        x # Return from the hold space.
    }

    # Remove the @ marker.
    s/@//

    # Keep sieving while there are any primes to the right of #.
    /#0*1/bsieve
