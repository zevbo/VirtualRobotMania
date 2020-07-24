#include <stdio.h>
#include <stdlib.h>
#include "robot_sim.h"

void test(int x) {
  printf("%d, %d\n",x,double_int(x));
}

int main(int argc, char **argv) {
  test(100);
  test(10000);
  test(323321);
  return 0;
}
