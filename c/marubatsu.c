#include <stdio.h>

#define LEN 3
#define EMPTY 0
#define MARU 1
#define BATSU -1

typedef struct coord {
  int row;
  int col;
} coord;

coord input(int board[LEN][LEN]);
void display(int board[LEN][LEN]);
int whoWin(int board[LEN][LEN]);
void turn(int board[LEN][LEN], int player);
char toChar(int i);

int main(void) {
  int board[LEN][LEN];
  for (int r = 0; r < LEN; r++) {
    for (int c = 0; c < LEN; c++) {
      board[r][c] = EMPTY;
    }
  }

  for (int i = 0; i < LEN * LEN; i++) {
    if (i % 2 == 0) {
      turn(board, MARU);
    } else {
      turn(board, BATSU);
    }

    int win = whoWin(board);
    if (win != 0) {
      printf("%c is win\n", toChar(win));
      display(board);
      break;
    } else {
      printf("\n");
    }

    if (i == LEN * LEN - 1) {
      printf("draw\n");
      display(board);
    }
  }
  return 0;
}

coord input(int board[LEN][LEN]) {
  int r, c;
  printf("row input> ");
  scanf("%d", &r);
  printf("col input> ");
  scanf("%d", &c);
  if ((r < 0 || LEN <= r) && (c < 0 || LEN <= c)) {
    printf("row and col values are invalid numbers. please retry.\n");
    return input(board);
  } else if (r < 0 || LEN <= r) {
    printf("row value is a invalid number. please retry.\n");
    return input(board);
  } else if (c < 0 || LEN <= c) {
    printf("col value is a invalid number. please retry.\n");
    return input(board);
  } else if(board[r][c] != EMPTY) {
    printf("this coordinate is already filled. please retry.\n");
    return input(board);
  }
  coord co;
  co.row = r;
  co.col = c;
  return co;
}

int all(int line[LEN]) {
  for (int i = 0; i < LEN; i++) {
    if (i == LEN - 1) {
      return line[i];
    } else if (line[i] != line[i + 1]) {
      return EMPTY;
    }
  }
  return EMPTY;
}

int whoWin(int board[LEN][LEN]) {
  int line[LEN];
  int win;

  for (int r = 0; r < LEN; r++) {
    win = all(board[r]);
    if (win != EMPTY) {
      return win;
    }
  }

  for (int c = 0; c < LEN; c++) {
    for (int r = 0; r < LEN; r++) {
      line[r] = board[r][c];
    }
    win = all(line);
    if (win != EMPTY) {
      return win;
    }
  }

  for (int r = 0, c = 0; r < LEN; r++, c++) {
    line[r] = board[r][c];
  }
  win = all(line);
  if (win != EMPTY) {
    return win;
  }

  for (int r = 0, c = LEN - 1; r < LEN; r++, c--) {
    line[r] = board[r][c];
  }
  win = all(line);
  if (win != EMPTY) {
    return win;
  }

  return EMPTY;
}

void turn(int board[LEN][LEN], int player) {
  printf("%c's turn\n", toChar(player));
  display(board);
  coord c = input(board);
  board[c.row][c.col] = player;
}

void display(int board[LEN][LEN]) {
  for (int r = 0; r < LEN; r++) {
    for (int c = 0; c < LEN; c++) {
      if (r == 0) {
        printf("+ %d ", c);
      } else {
        printf("+ - ");
      }
    }
    printf("\n");
    for (int c = 0; c < LEN; c++) {
      if (c == 0) {
        printf("%d %c ", r, toChar(board[r][c]));
      } else {
        printf("| %c ", toChar(board[r][c]));
      }
    }
    printf("\n");
  }
}

char toChar(int player) {
  switch (player) {
  case MARU:
    return '@';
  case BATSU:
    return '*';
  case EMPTY:
    return ' ';
  default:
    return '?';
  }
}
