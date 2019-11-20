#include <stdio.h>

// char = 1 byte (256 options)
// int  = 4 bytes 
int main(void) {
  char l = 'l';
  char *fake_string = &l;
  printf("%s\n", fake_string);
  return 0;
}
