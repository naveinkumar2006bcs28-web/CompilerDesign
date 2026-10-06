#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

bool is_accepting(const char* cs, const char* T[], int T_size) {
    int k;

    for (k = 0; k < T_size; k++) {
        if (strcmp(cs, T[k]) == 0) {
            return true;
        }
    }

    return false;
}

char* dfa_lexer(const char* W, int start_pos, int start_state_idx,
                char*** transition_table, const char* states[], int num_states,
                const char* alphabet,
                const char* T[], int T_size,
                int* out_fp, int* out_accepted,
                int* out_cause, char* out_accepting_state) {

    const char* cs = states[start_state_idx];

    int fp = start_pos;
    int len = strlen(W);
    int char_index;
    const char* pos;
    int s, found;

    *out_cause = 0;
    out_accepting_state[0] = '\0';

    while (fp < len) {

        char ch = W[fp];

        /* Check whether the symbol belongs to the alphabet */
        pos = strchr(alphabet, ch);

        if (pos == NULL) {
            *out_cause = 1;
            break;
        }

        char_index = pos - alphabet;

        /* Find the current state's index */
        found = -1;

        for (s = 0; s < num_states; s++) {
            if (strcmp(states[s], cs) == 0) {
                found = s;
                break;
            }
        }

        if (found == -1) {
            break;
        }

        /* Get the next state from the transition table */
        const char* next_state_label =
            transition_table[found][char_index];

        /* Check for no transition */
        if (strcmp(next_state_label, "-1") == 0) {
            *out_cause = 2;
            break;
        }

        /* Move to the next state */
        cs = next_state_label;
        fp++;
    }

    *out_fp = fp;

    /*
     * Check whether the current state is accepting.
     */
    if (is_accepting(cs, T, T_size) && fp > start_pos) {

        *out_accepted = 1;

        /* Store the accepting state */
        strcpy(out_accepting_state, cs);

        int lexeme_len = fp - start_pos;

        char* lexeme = malloc(lexeme_len + 1);

        if (!lexeme) {
            return NULL;
        }

        strncpy(lexeme, W + start_pos, lexeme_len);
        lexeme[lexeme_len] = '\0';

        return lexeme;
    }

    /*
     * String is not accepted.
     * Still return the consumed portion if any.
     */
    *out_accepted = 0;

    if (fp > start_pos) {

        int lexeme_len = fp - start_pos;

        char* lexeme = malloc(lexeme_len + 1);

        if (!lexeme) {
            return NULL;
        }

        strncpy(lexeme, W + start_pos, lexeme_len);
        lexeme[lexeme_len] = '\0';

        return lexeme;
    }

    return NULL;
}

int main() {

    int num_states, alphabet_size;

    char alphabet[256];
    char states[100][10];

    char*** transition_table;

    char* T[100];
    int T_size;

    char W[1000];

    int s, c, k;
    int num_strings;
    int str_idx;

    /*
     * Read alphabet
     */
    printf("Enter the input symbols : (a , b / 0, 1) ");
    fflush(stdout);

    scanf("%s", alphabet);

    alphabet_size = strlen(alphabet);

    /*
     * Read number of states
     */
    printf("Enter number of states: ");
    fflush(stdout);

    scanf("%d", &num_states);

    /*
     * Read states
     */
    printf("Enter state (A , B , C ...): ");
    fflush(stdout);

    for (s = 0; s < num_states; s++) {
        scanf("%s", states[s]);
    }

    /*
     * Allocate transition table
     */
    transition_table =
        malloc(num_states * sizeof(char**));

    for (s = 0; s < num_states; s++) {

        transition_table[s] =
            malloc(alphabet_size * sizeof(char*));

        for (c = 0; c < alphabet_size; c++) {

            transition_table[s][c] =
                malloc(10 * sizeof(char));
        }
    }

    /*
     * Read transition table
     */
    printf("\nEnter the transition table (%d rows x %d columns '%s'):\n",
           num_states, alphabet_size, alphabet);

    printf("Use '-1' for no transition.\n");
    printf("Enter data:\n\n");

    fflush(stdout);

    for (s = 0; s < num_states; s++) {

        for (c = 0; c < alphabet_size; c++) {

            scanf("%s", transition_table[s][c]);
        }
    }

    /*
     * Read accepting states
     */
    printf("\nEnter number of accepting states: ");
    fflush(stdout);

    scanf("%d", &T_size);

    printf("Enter accepting state: ");
    fflush(stdout);

    for (k = 0; k < T_size; k++) {

        T[k] = malloc(10 * sizeof(char));

        scanf("%s", T[k]);
    }

    /*
     * Create state pointers
     */
    const char* state_ptrs[100];

    for (s = 0; s < num_states; s++) {
        state_ptrs[s] = states[s];
    }

    /*
     * Read number of input strings
     */
    printf("\nEnter number of strings: ");
    fflush(stdout);

    scanf("%d", &num_strings);

    /*
     * Process each input string
     */
    for (str_idx = 0; str_idx < num_strings; str_idx++) {

        printf("Enter string: ");
        fflush(stdout);

        scanf("%s", W);

        int len = strlen(W);
        int pos = 0;

        while (pos < len) {

            int stopped_pos;
            int accepted_flag;
            int cause;

            /*
             * This stores the accepting state
             * when the string is accepted.
             */
            char accepting_state[10];

            char* lexeme =
                dfa_lexer(
                    W,
                    pos,
                    0,
                    transition_table,
                    state_ptrs,
                    num_states,
                    alphabet,
                    (const char**)T,
                    T_size,
                    &stopped_pos,
                    &accepted_flag,
                    &cause,
                    accepting_state
                );

            /*
             * ACCEPTED
             */
            if (accepted_flag) {

                /*
                 * Required output format:
                 * <accepted string, accepting state>
                 */
                printf("<%s,%s>\n",
                       lexeme,
                       accepting_state);

                pos = stopped_pos;

                free(lexeme);
            }

            /*
             * NOT ACCEPTED
             */
            else if (lexeme) {

                if (cause == 1) {

                    printf("Lexeme not accepted, unknown symbol '%c' at position %d\n",
                           W[stopped_pos],
                           stopped_pos + 1);

                }

                else if (cause == 2) {

                    printf("Lexeme not accepted, no transition at position %d\n",
                           stopped_pos + 1);

                }

                else {

                    printf("Lexeme not accepted\n");
                }

                /*
                 * Move past the processed characters.
                 */
                if (stopped_pos > pos) {
                    pos = stopped_pos;
                }
                else {
                    pos++;
                }

                free(lexeme);
            }

            /*
             * No lexeme was produced
             */
            else {

                if (cause == 1) {

                    printf("Lexeme not accepted, unknown symbol '%c' at position %d\n",
                           W[stopped_pos],
                           stopped_pos + 1);

                    pos = stopped_pos + 1;
                }

                else if (cause == 2) {

                    printf("Lexeme not accepted, no transition at position %d\n",
                           stopped_pos + 1);

                    pos = stopped_pos + 1;
                }

                else {

                    printf("Lexeme not accepted\n");

                    pos++;
                }
            }
        }
    }

    /*
     * Free transition table memory
     */
    for (s = 0; s < num_states; s++) {

        for (c = 0; c < alphabet_size; c++) {

            free(transition_table[s][c]);
        }

        free(transition_table[s]);
    }

    free(transition_table);

    /*
     * Free accepting-state memory
     */
    for (k = 0; k < T_size; k++) {

        free(T[k]);
    }

    return 0;
}


[24bcs053@mepcolinux ex2]$gcc dfa6.c -o lexer
[24bcs053@mepcolinux ex2]$./lexer
Enter the input symbols : (a , b / 0, 1) a b
Enter number of states: Enter state (A , B , C ...):
Enter the transition table (0 rows x 1 columns 'a'):
Use '-1' for no transition.
Enter data:


Enter number of accepting states: Enter accepting state:
Enter number of strings: [24bcs053@mepcolinux ex2]$./lexer
Enter the input symbols : (a , b / 0, 1) ab
Enter number of states: 5
Enter state (A , B , C ...): A B C D E

Enter the transition table (5 rows x 2 columns 'ab'):
Use '-1' for no transition.
Enter data:

B D
B C
B -1
D E
B -1

Enter number of accepting states: abcaabbabba
Enter accepting state:
Enter number of strings: [24bcs053@mepcolinux ex2]$./lexer
Enter the input symbols : (a , b / 0, 1) ab
Enter number of states: 5
Enter state (A , B , C ...): A B C D E

Enter the transition table (5 rows x 2 columns 'ab'):
Use '-1' for no transition.
Enter data:

B D
B C
B -1
D E
B -1

Enter number of accepting states: 2
Enter accepting state: C E

Enter number of strings: 10
Enter string: abcaabbabba
<ab,C>
Lexeme not accepted, unknown symbol 'c' at position 3
<aab,C>
<bab,E>
Lexeme not accepted
Enter string: aaabab
<aaabab,C>
