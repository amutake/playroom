bool in_use = false;
int ncs = 0; /* the number of processes in the CS */

active[2] proctype P () {
  do
    :: atomic {
         in_use == false;
         in_use = true;
       }
       ncs++;
       assert (ncs == 1);
       ncs--;
       in_use = false;
  od
}
