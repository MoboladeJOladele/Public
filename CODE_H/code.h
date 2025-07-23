#ifndef CODE_H
#define CODE_H

#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// All Prototypes stacked together
char *_case(char *s);
char *_lower(char *s, int size);
char *_upper(char *s, int size);
bool _islowercase(char *s);
bool _isuppercase(char *s);
bool look_for_letters(char *s);
void found_no_letters(char *function);
void sort_chars_ascending(char *array, int length);
void sort_strings_ascending(char* array[], int length);

/*
    ARLEN, Array Length Calculator
*/
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
    void name##_descending(type array[], int length) { \
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
    void name(type array[], char *format, int size) {  \
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
            printf("sort() says {Unknown Format}\n");  \
            return;  \
        } \
    } 
    
#define sort_others(type, name)  \
    void name##_ascending(type array[], int length) { \
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

void sort_chars_ascending(char *array, int length)
{
    if (length <= 1)
    {
        return;
    }

    // Length of each half
    int l_length = length / 2;
    int r_length = length - l_length;

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
            char l_char = tolower(left_half[left]);
            char r_char = tolower(right_half[right]);

            if (l_char < r_char)
            {
                array[index] = left_half[left];
                left++;
            }

            else if (l_char > r_char)
            {
                array[index] = right_half[right];
                right++;
            }

            // If the two elements are equal
            else
            {
                char char1 = left_half[left];
                char char2 = right_half[right];

                // Lowercase letters should be first
                if (islower(left_half[left]) && !islower(right_half[right]))
                {
                    char1 = left_half[left];
                    char2 = right_half[right];
                }

                else if (!islower(left_half[left]) && islower(right_half[right]))
                {
                    char1 = right_half[right];
                    char2 =  left_half[left];
                }

                array[index] = char1;
                array[index + 1] = char2;
                left++, right++;
                skip = true;
            }
        }
    }
}

void sort_strings_ascending(char* array[], int length)
{
    if (length <= 1)
    {
        return;
    }

    // Length of each half
    int l_length = length / 2;
    int r_length = length - l_length;

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
            char *l_copy = _lower(left_half[left], sizeof(left_half[left]));
            if (l_copy == NULL)
            {
                printf("malloc() says {Failed Memory Allocation}\n");
                return;
            }

            char *r_copy = _lower(right_half[right], sizeof(right_half[right]));;
            if (r_copy == NULL)
            {
                printf("malloc() says {Failed Memory Allocation}\n");
                free(l_copy);
                return;
            }
            
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
                char* word1 = left_half[left];
                char* word2 = right_half[right];

                // Lowercase words should be first
                if (_islowercase(left_half[left]) && !_islowercase(right_half[right]))
                {
                    word1 = left_half[left];
                    word2 = right_half[right];
                }

                else if (!_islowercase(left_half[left]) && _islowercase(right_half[right]))
                {
                    word1 = right_half[right];
                    word2 = left_half[left];
                }

                array[index] = word1;
                array[index + 1] = word2;
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

char *_lower(char *s, int size)
{
    // Counts all characters (including the NULL character)
    int length = arlen(s, size);

    char *copy = malloc(length);
    if (copy == NULL)
    {
        return NULL;
    }

    for (int i = 0; i < length; i++)
    {
        if (!isalpha(s[i]))
        {
            copy[i] = s[i];
        }
        else if (!islower(s[i]))
        {
            copy[i] = tolower(s[i]);
        }
        else
        {
            copy[i] = s[i];
        }
    }
    return copy;
}

char *_upper(char *s, int size)
{
    // Counts all characters (including the NULL character)
    int length = arlen(s, size);

    char *copy = malloc(length);
    if (copy == NULL)
    {
        return NULL;
    }

    for (int i = 0; i < length; i++)
    {
        if (!isalpha(s[i]))
        {
            copy[i] = s[i];
        }
        else if (!isupper(s[i]))
        {
            copy[i] = toupper(s[i]);
        }
        else
        {
            copy[i] = s[i];
        }
    }
    return copy;
}

bool _islowercase(char *s)
{
    bool found_a_letter = look_for_letters(s);
    if (!found_a_letter)
    {
        // No Letters Found
        found_no_letters("_islowercase()");
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

bool _isuppercase(char *s)
{
    bool found_a_letter = look_for_letters(s);
    if (!found_a_letter)
    {
        // No Letters Found
        found_no_letters("_isuppercase()");
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

char *_case(char *s)
{
    bool found_a_letter = look_for_letters(s);
    if (!found_a_letter)
    {
        // No Letters Found
        found_no_letters("_case()");
        return "None";
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

bool look_for_letters(char *s)
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

void found_no_letters(char *function)
{
    printf("%s says {Couldn't find any letters}\n", function);
}

#endif