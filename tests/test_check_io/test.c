#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
  int i;
  FILE * f = fopen("out", "w+");

  for(i = 0; i < 2; i ++) {
    printf("I wrote Forbidden IO\n");
    fprintf(f, "Forbidden IO\n");
    fflush(f);
  }
  rewind(f);
  char str[256];
  for(i = 0; i < 2; i ++) {
    fscanf(f, "%s", str);
    printf("I read %s\n", str);
  }
  for(i = 0; i < 2; i ++) {
    printf("Correct IO\n");
    fprintf(stderr, "Correct IO\n");
  }
  return 0;
}
