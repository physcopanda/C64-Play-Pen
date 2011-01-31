n_of_repeats = [
    1, 0, 0, 0, 1, 0, 0, 0, 1, 0,
    0, 0, 1, 0, 0, 1, 0, 0, 1, 0,
    0, 1, 0, 1, 0, 1, 0, 1, 0, 1,
    0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 2,
    1, 2, 1, 2, 1, 2, 1, 2, 2, 2,
    3, 2, 3, 3, 3, 4
]

chrbase1 = 16384 #$4000
chrbase2 = 16384 + 2048 #$4800

def chaddr(x, y):
    address = chrbase1
    if y > 47:
        address = chrbase2
        y = y - 48
    address = address + (int(y / 8) * 184) + (x * 8) + (y & 7)
    return (address + 768)

def speedcode(texture_base):
    f = open('speedcode.s', 'w')
    print >> f, "render:"
    counter = 0
    for y in range(96):
        if n_of_repeats[y] > 0:
            for x in range(23):
                tex = texture_base + (256 * x) + y
                print >> f, "\tlda " + str(tex) + ",x"
                for i in range(n_of_repeats[y]):
                    print >> f, "\tsta " + str(chaddr(x, counter + i))
            counter += n_of_repeats[y]

#    print >> f, "\n"
    print >> f, "\trts"

speedcode(10496)
