#ifndef CODE_H
#define CODE_H

#include <stdio.h>

#define arlen_others(type, name) \
    int name(type array, int size) { \
        return size / sizeof(array[0]); \
    }

// Other arlen functions
arlen_others(int*, arlen_ints)
arlen_others(long*, arlen_longs)
arlen_others(float*, arlen_floats)
arlen_others(double*, arlen_doubles)
arlen_others(char**, arlen_string_set)

// String (char*) arlen function
int arlen_string(char* s, int size) {
    int length = 0;
    for (int i = 0; s[i] != '\0'; i++)
    {
        length++;
    }

    return length;
}

// _Generic Function Selector
#define arlen(array, size) _Generic((array), \
    int*: arlen_ints, \
    long*: arlen_longs, \
    float*: arlen_floats, \
    double*: arlen_doubles, \
    char*: arlen_string, \
    char**: arlen_string_set \
)(array, size)


#endif