def close_object():
    return "]#"

def open_object():
    return "#["

Links = ['<"1_to_2", <1>, <2>, 30, 5>',
 	'<"1_to_3", <1>, <3>, 90, 5>',
 	'<"2_to_3", <2>, <3>, 10, 5>',
 	'<"2_to_5", <2>, <5>, 40, 5>',
 	'<"2_to_6", <2>, <6>, 35, 5>',
 	'<"3_to_6", <3>, <6>, 30, 5>',
 	'<"3_to_4", <3>, <4>, 10, 5>',
 	'<"4_to_6", <4>, <6>, 10, 5>',
 	'<"5_to_7", <5>, <7>, 10, 5>',
 	'<"5_to_8", <5>, <8>, 30, 5>',
 	'<"6_to_7", <6>, <7>, 15, 5>',
 	'<"6_to_9", <6>, <9>, 50, 5>',
 	'<"7_to_9", <7>, <9>, 45, 5>',
 	'<"7_to_10", <7>, <10>, 25, 5>',
 	'<"8_to_10", <8>, <10>, 35, 5>',
 	'<"9_to_10", <9>, <10>, 90, 5>']

Demands = [
    '<"blue", <1>, <10>, 10>',
 	'<"green", <2>, <8>, 10>'
]

Paths = [
 	'<"first">',
 	'<"second">',
]

filename = "generated_delta.dat"


delta = ''
tab = '  '

for link in Links:
    delta += tab + link + ' : #[\n'
    for demand in Demands:
        delta += 2 * tab + demand + ' : #[\n'
        for path in Paths:
            delta += 3 * tab + path + ' : 1\n'
        delta += 2 * tab + close_object()
        delta += '\n'
    delta += 1 * tab + close_object()
    delta += '\n'

delta += close_object()

with open(filename, 'w') as model:
    model.write(delta);
