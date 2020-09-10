#!/bin/sed -Enf

# Example: echo listen, silent | ./anagram.sed

s/, *([^ ])/\n\1/

s/$/\n110010000/ # 400 (make the sieve large enough).

########################### Sieve ###########################

# Convert a given binary number to unary notation.

:decrement
    :replace_zero s/0(_*)$/_\1/; treplace_zero
    s/1(_*)$/0\1/
    s/_/1/g
    s/\n0([^\n][^\n]*)$/\n\1/
    x; s/^1*$/&1/; x # Increment the unary counter in the hold space.
    /\n0$/!bdecrement

# Now the base-2 number is converted to the base-1.

s/\n0$//
x

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

### Part II, Collecting ###

# Collect the prime numbers in the hold space.
x; s/$/\n0/; x
:next_prime
    # Increment the last number in the hold buffer.
    x
    :replace s/1(_*)$/_\1/; treplace
    s/\n(_*)$/\n0\1/
    s/0(_*)$/1\1/
    s/_/0/g
    x

    # Copy the last number in the hold buffer.
    /^1/{x; s/\n[01]*$/&&/; x}

    s/^.//
    /./bnext_prime

x; s/\n[01]*$//; x # Remove the working number/counter.

# We do not need the sieve anymore, just
# the input data and the prime numbers.
g

# Pattern space: <string1>\n<string2>\n<primes>

########################### End of sieve ###########################

# Build the dictionary.

s/^[^\n]*\n[^\n]*\n/&>/
s/^/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\n/

:build_lookup_table
    s/^(.)(.*>)/\2\1/
    s/>([^\n]*\n)/\1>/
    /^\n/! bbuild_lookup_table

s/^\n//
s/>.*$//

h # Backup

:build_first_signature
    s/^([^\n]*\n)[^\n]*\n/\1/ # Remove the <string2>.
    bbranch_selected
:build_second_signature
    s/^[^\n]*\n// # Remove the <string1>.
:branch_selected

# Replace the alphabetical characters by corresponding
# prime numbers from the lookup table.

s/$/\n/
s/^/@/
:encode
    s/@(.)([^\n]*\n.*)\1([^\n]*)(\n.*)$/\3\n@\2\1\3\4/
    /@\n/! bencode

s/@.*$//

# Now we need to multiply all the numbers we have.

:multiply_pair

    /^[01]*\n$/ bend_multiply

    # Multiply the first two numbers and
    # replace them both by the result.

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
:end_multiply

# Ok, we have one of the two signatures.

x
/^[01]*\n$/! bbuild_second_signature
s/\n$//
G

# Compare the signatures.
s/^[01]*\n/>&!/

:compare_signatures
    />(.).*!\1/! bdiffer
    s/>(.)/\1>/; s/!(.)/\1!/
    /\n>.*\n!/! bcompare_signatures
s/^.*$/anagrams!/; p; q
:differ
    s/^.*$/not anagrams.../; p
