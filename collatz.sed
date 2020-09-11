#!/bin/sed -Enf

# 3x+1 iterations (the Collatz conjecture) in sed.
# By Circiter (mailto:xcirciter@gmail.com).

# echo <starting_number> | ./collatz.sed
# A <starting_number> has to be written in binary.

# Pseudocode:
# 01.  read a number;
# 02.    print the number;
# 03.    factor the number;
# 04.    remove all the 2s from the factorization;
# 05.    if factorization is empty then goto 10;
# 06.    append 3 to the factorization;
# 07.    multiply all the factors;
# 08.    increment the number;
# 09.  goto 02;
# 10.  end.

:loop

h; x; p; s/^.*$//; x # Print current number.

# Convert a given binary number to unary notation.

:decrement
    :replace_zero s/0(_*)$/_\1/; treplace_zero
    s/1(_*)$/0\1/
    s/_/1/g
    s/^0(.)/\1/
    x; s/^1*$/&1/; x # Increment the unary counter in the hold space.
    /^0$/!bdecrement
g # Now to the base-2 number is converted to the base-1.

##############################################
### Factorization.

# Transform the unary number to the format #01*\n.
s/^./0/; s/^/#/; s/$/\n\$/

# @, :, # -- are auxiliary markers (pointers).
# The # is used to mark the current prime,
# the : is used to locate a next multiple of the prime,
# the @ is used to mark the found multiple of the prime.
:sieve
    # Find next prime.
    s/#(0*1)/\1#@/
    # Copy the prefix to the second row.
    s/^(.*)@(.*\n).*\$/\1@\2:\1\$/
    # Remove illegal symbols from the second row.
    :clear s/(\n.*)([^01:])(.*)\$/\1\3\$/; tclear

    x; s/^.*$/x/; x
    :exclude
        # Find next composite to be excluded.
        :composite
            # Move the @ and : markers to the right
            # synchronously one character at a time.
            s/@([^\n])/\1@/; s/:(.)/\1:/
            /:[^\$]/ s/@\n/\n/ # Ensure that the last cell in sieve can be excluded.
            /@.*:[^\$]/ bcomposite # Repeat if it's possible to move the pointers further.

        # Exclude the composite number founded.
        s/.@/0@/

        /:\$/ {x; s/^x*$/&x/; x} # Increment the counter in the hold space.

        # Reinitialize the : pointer.
        s/://; s/\n/\n:/

        /@[^\n]/bexclude # Keep excluding a multiples of the current prime.

    # Pattern space: sieve\nprime_number$list_of_factors
    # The hold space now contains the result of dividing
    # the given number by the current prime.

    # If we are factoring a prime number then
    # due to the fact that the code above
    # prematurely removed the @ marker after
    # the last 1 in the sieve, we can not print
    # this "trivial" prime factor. So we need
    # a workaround here.
    /1#\n/ s/#/@/ # Insert @ again.

    # If a prime factor found.
    /@/{ :prime_exponent

        # Print in binary.
        s/$/|0/
        :print_binary
            s/:([^\$])/\1:/

            # Increment the binary number
            :digit s/1(_*)$/_\1/; tdigit
            s/\|(_*)$/\|0\1/
            s/0(_*)$/1\1/
            s/_/0/g

            /:[^\$]/bprint_binary

        s/://; s/^[^\n]*\n/&:/

        # OK, it was easy; but to determine
        # the exponent of the prime factor is
        # much harder.

        # We need to keep dividing the content of the hold space
        # by the current prime.
        H # Copy the prime number to the hold space.
        x
        s/^([^\n]*\n)[^\n]*\n([^\n]*)\$.*$/\1\2/ # Remove the sieve from the hold space.
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
            # Hold space: <number_divided_by_prime>
            x
            bprime_exponent
        }
        x # Return from the hold space.
    }

    # Remove the @ marker.
    s/@//

    # Keep sieving while there are any primes to the right of #.
    /#0*1/bsieve

s/^.*\$\|//; s/\|/\n/g # Leave only the list of prime factors.

/\n$/! s/$/\n/

# Remove all 2s (10 in binary).
s/^/\n/
:remove_two s/\n10\n/\n/; tremove_two

# Check for convergence.
/^\n$/ {s/^.*$/1/; p; q}

# Then append 3 (=11 in binary).
s/^/11/

# Multiply all the factors together.

:multiply_pair
    /^[01]*\n$/ bend
    s/^([01]*)\n([01]*)\n/\1*\2:\$\n/

    :multiplication
        /1:/ { # accumulator+=x
            s/^(.*)(\*.*)\$/\1\2+\1=.\$/
            :addition
                /1\+/ s/=/=1/; /1=/ s/=/=1/ # Produce next digit.
                s/[01]\+/+/; s/[01]=/=/ # Shift numbers.
                /=11/! s/=/=./; /=11/ s/=11/=1./ # Carry.
                /[01]\+/ baddition
                /[01]=/ baddition
            s/:.*=/:/;
            :z s/\.\./.0./; tz
            s/\.//g
        }
        s/\*/0*/; s/[01]:/:/ # Shift numbers.
        /[01]:/ bmultiplication

    s/^.*://; s/\$//
    bmultiply_pair
:end
s/\n//;

# Increment the number.
:d s/1(_*)$/_\1/; td
s/^(_*)$/0\1/
s/0(_*)$/1\1/
s/_/0/g

bloop # Jump to the begining.
