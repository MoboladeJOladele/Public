#ifndef CODE_H
#define CODE_H

#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// All Prototypes stacked alphabetically
static inline char *_case(const char s[]);
static inline bool _islowercase(const char s[]);
static inline bool _isuppercase(const char s[]);
static inline bool look_for_letters(const char s[]);
static inline void _lower(char s[]);
static inline void _upper(char s[]);
static inline void found_no_letters(const char function[]);
static inline void sort_chars_ascending(char array[], const int length);
static inline void sort_strings_ascending(char* array[], const int length);

/*
    ARLEN, Array Length Calculator
*/
#define arlen_others(type, name) \
    static inline int name(type array, int size) { \
        return size / sizeof(array[0]); \
    }

// Other arlen functions
arlen_others(int*, arlen_ints)
arlen_others(long*, arlen_longs)
arlen_others(float*, arlen_floats)
arlen_others(double*, arlen_doubles)
arlen_others(char**, arlen_string_set)

// String (char*) arlen function
static inline int arlen_string(char* s, const int size) {
    int length = 0;
    for (int i = 0; s[i] != '\0'; i++)
    {
        length++;
    }
//
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


/*
    Sort, Multi-Sort C function
*/
#define selector(type, name)  \
    \
    static inline void name##_descending(type array[], int length) { \
        name##_ascending(array, length);  \
        \
        /*Create a duplicate array*/ \
        type copy[length];  \
        for (int i = 0; i < length; i++)  \
        { \
            copy[i] = array[i];  \
        } \
        \
        /*Reverse the array*/ \
        int index = (length - 1);  \
        for (int i = 0; i < length; i++)  \
        { \
            array[i] = copy[index];  \
            index--;  \
        } \
    } \
    \
    static inline void name(type array[], char *format, int size) {  \
        int length = arlen(array, size);  \
        \
        if (strcmp(format, "ascending") == 0) \
        { \
            name##_ascending(array, length);  \
            return;  \
        } \
        \
        else if (strcmp(format, "descending") == 0)  \
        { \
           name##_descending(array, length);  \
           return;  \
        } \
        \
        else  \
        { \
            printf("{++sort() says \"Unknown Format\"++}");  \
            return;  \
        } \
    } 
    
#define sort_others(type, name)  \
    static inline void name##_ascending(type array[], int length) { \
        if (length <= 1)  \
        { \
            return;  \
        } \
        /*Get the length of the left and right half*/ \
        int l_length = length / 2;  \
        int r_length = length - l_length;  \
        \
        /*Create arrays to store the two halves of the list*/ \
        type left_half[l_length], right_half[r_length];  \
        \
        /*Make the left half*/ \
        for (int l = 0; l < l_length; l++)  \
        { \
            left_half[l] = array[l];  \
        } \
        \
        /*Make the right half*/ \
        for (int r = 0; r < r_length; r++)  \
        { \
            right_half[r] = array[(l_length + r)];  \
        } \
        name##_ascending(left_half, l_length);  \
        name##_ascending(right_half, r_length); \
        \
        /*SORT AND MERGE*/ \
        int left = 0, right = 0;  \
        bool skip = false;  \
        for (int index = 0; index < length; index++)  \
        { \
            if (skip)  \
            { \
                skip = false;  \
                continue;  \
            } \
            \
            /*If the elements in the left half have finished*/ \
            if (left == l_length && right < r_length)  \
            { \
                array[index] = right_half[right];  \
                right++;  \
            } \
            \
            /*If the elements in the right half have finished*/ \
            else if (left < l_length && right == r_length)  \
            { \
                array[index] = left_half[left];  \
                left++;  \
            } \
            \
            /*ELSE*/ \
            /*if both halves still have elements*/ \
            else if (left < l_length && right < r_length)  \
            { \
                if (left_half[left] < right_half[right])  \
                { \
                    array[index] = left_half[left];  \
                    left++;  \
                } \
                \
                else if (left_half[left] > right_half[right])  \
                { \
                    array[index] = right_half[right];  \
                    right++;  \
                } \
                \
                /*If the two elements are equal*/ \
                else  \
                { \
                    array[index] = left_half[left];  \
                    array[index + 1] = right_half[right];  \
                    left++, right++;  \
                    skip = true;  \
                } \
            } \
        } \
    }

static inline void sort_chars_ascending(char array[], const int length)
{
    if (length <= 1)
    {
        return;
    }

    // Get the length of each half
    const int l_length = length / 2;
    const int r_length = length - l_length;

    // Create the two halves
    char left_half[l_length], right_half[r_length];

    // Make the left half
    for (int l = 0; l < l_length; l++)
    {
        left_half[l] = array[l] ;
    }

    // Make the right half
    for (int r = 0; r < r_length; r++)
    {
        right_half[r] = array[r + l_length];
    }

    sort_chars_ascending(left_half, l_length);
    sort_chars_ascending(right_half, r_length);

    int left = 0, right = 0;
    bool skip = false;
    for (int index = 0; index < length; index++)
    {
        if (skip)
        {
            skip = false;
            continue;
        }

        // If the elements in the left half have finished.
        if (left == l_length && right < r_length)
        {
            array[index] = right_half[right];
            right++;
        }

        // If the elements in the right half have finished
        else if (left < l_length && right == r_length)
        {
            array[index] = left_half[left];
            left++;
        }

        // If both halves still have elements
        else if (left < l_length && right < r_length)
        {
            char c1 = left_half[left];
            char c2 = right_half[right];

            // If the two elements aren't equal
            if (tolower(c1) != tolower(c2))
            {
                char l_copy = tolower(c1);
                char r_copy = tolower(c2);

                if (l_copy < r_copy)
                {
                    array[index] = c1;
                    array[index + 1] = c2;
                }

                else if (l_copy > r_copy)
                {
                    array[index] = c2;
                    array[index + 1] = c1;
                }
            }

            else
            {
                // Lowercase letters should be pushed first
                if (islower(c1) && !islower(c2))
                {
                    // Change nothing
                }
                
                else if (!islower(c1) && islower(c2))
                {
                    c1 = right_half[right];
                    c2 = left_half[left]; 
                }

                array[index] = c1;
                array[index + 1] = c2;
            }
            left++, right++;
            skip = true;
        }
    }
}

static inline void sort_strings_ascending(char* array[], const int length)
{
    if (length <= 1)
    {
        return;
    }

    // Get the length of each half
    const int l_length = length / 2;
    const int r_length = length - l_length;

    // Create the two halves
    char* left_half[l_length];
    char* right_half[r_length];

    // Make the left half
    for (int l = 0; l < l_length; l++)
    {
        left_half[l] = array[l] ;
    }

    // Make the right half
    for (int r = 0; r < r_length; r++)
    {
        right_half[r] = array[r + l_length];
    }

    sort_strings_ascending(left_half, l_length);
    sort_strings_ascending(right_half, r_length);

    int left = 0, right = 0;
    bool skip = false;
    for (int index = 0; index < length; index++)
    {
        if (skip)
        {
            skip = false;
            continue;
        }

        // If the elements in the left half have finished.
        if (left == l_length && right < r_length)
        {
            array[index] = right_half[right];
            right++;
        }

        // If the elements in the right half have finished
        else if (left < l_length && right == r_length)
        {
            array[index] = left_half[left];
            left++;
        }

        // If both halves still have elements
        else if (left < l_length && right < r_length)
        {
            char *l_copy = malloc(sizeof(left_half[left]));
            char *r_copy = malloc(sizeof(right_half[right]));
            
            strcpy(l_copy, left_half[left]);
            strcpy(r_copy, right_half[right]);

            // Convert both copies to lower case
            _lower(l_copy);
            _lower(r_copy);

            if (strcmp(l_copy, r_copy) < 0)
            {
                array[index] = left_half[left];
                left++;
            }

            else if (strcmp(l_copy, r_copy) > 0)
            {
                array[index] = right_half[right];
                right++;
            }

            // If the two elements are equal
            else
            {
                char* s1 = left_half[left];
                char* s2 = right_half[right];

                for (int i = 0, n = arlen(s1, sizeof(s1)); i < n; i++)
                {
                    if (s1[i] == s2[i])
                    {
                        continue;
                    }

                    else
                    {
                        // Lowercase words should be pushed first
                        if (islower(s1[i]) && !islower(s2[i]))
                        {
                            // Change nothing
                        }

                        else if (!islower(s1[i]) && islower(s2[i]))
                        {
                            s1 = right_half[right];
                            s2 = left_half[left];
                        }
                    }
                }
                array[index] = s1;
                array[index + 1] = s2;
                left++, right++;
                skip = true;
            }

            free(l_copy);
            free(r_copy);
        }
    }
}

// Other Sort functions
sort_others(int, sort_ints)
sort_others(long, sort_longs)
sort_others(float, sort_floats)
sort_others(double, sort_doubles)

// Select appropriate sort function
selector(int, sort_ints)
selector(long, sort_longs)
selector(float, sort_floats)
selector(double, sort_doubles)
selector(char, sort_chars)
selector(char*, sort_strings)


// _Generic Function Selector
#define sort(array, format, size) _Generic((array), \
    int*: sort_ints, \
    long*: sort_longs, \
    float*: sort_floats, \
    double*: sort_doubles, \
    char*: sort_chars, \
    char**: sort_strings \
)(array, format, size)

/*
    Special String Modification Functions
*/

static inline void _lower(char s[])
{
    for (int i = 0; s[i] != '\0'; i++)
    {
        if (!isalpha(s[i]))
        {
            continue;
        }
        else if (isupper(s[i]))
        {
            s[i] = tolower(s[i]);
        }
    }
}

static inline void _upper(char s[])
{
    for (int i = 0; s[i] != '\0'; i++)
    {
        if (!isalpha(s[i]))
        {
            continue;
        }
        else if (islower(s[i]))
        {
            s[i] = toupper(s[i]);
        }
    }
}

static inline bool _islowercase(const char s[])
{
    bool found_a_letter = look_for_letters(s);
    if (!found_a_letter)
    {
        // No Letters Found
        found_no_letters("_islowercase()");
        return false;
    }

    else
    {
        for (int i = 0; s[i] != '\0'; i++)
        {
            if (!isalpha(s[i]))
            {
                continue;
            }

            else if (!islower(s[i]))
            {
                return false;
            }
        }
        return true;
    }
}

static inline bool _isuppercase(const char s[])
{
    bool found_a_letter = look_for_letters(s);
    if (!found_a_letter)
    {
        // No Letters Found
        found_no_letters("_isuppercase()");
        return false;
    }

    else
    {
        for (int i = 0; s[i] != '\0'; i++)
        {
            if (!isalpha(s[i]))
            {
                continue;
            }

            else if (!isupper(s[i]))
            {
                return false;
            }
        }
        return true;
    }
}

static inline char *_case(const char s[])
{
    bool found_a_letter = look_for_letters(s);
    if (!found_a_letter)
    {
        // No Letters Found
        found_no_letters("_case()");
        return "";
    }

    bool is_lower = _islowercase(s);
    bool is_upper = _isuppercase(s);

    if (is_lower)
    {
        return "low";
    }

    else if (is_upper)
    {
        return "upp";
    }

    else
    {
        return "both";
    }
}

static inline bool look_for_letters(const char s[])
{
    for (int i = 0; s[i] != '\0'; i++)
    {
        if (!isalpha(s[i]))
        {
            continue;
        }
        // If we've found at least one letter
        return true;
    }
    return false;
}

static inline void found_no_letters(const char function[])
{
    printf("{++%s says \"Couldn't find any letters\"++}", function);
}

#endif